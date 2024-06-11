import Chisel.{ListLookup, MuxLookup}
import chisel3._

object ControllerState extends Enumeration {
  val STATE_IDLE: UInt = 0.U
  val STATE_FETCH_INST: UInt = 1.U
  val STATE_EXECUTE: UInt = 2.U
  val STATE_WRITE_BACK: UInt = 3.U
}

import ControllerState._

class Controller extends Module{
  val io = IO(new Bundle{
    val PC_sel = Output(UInt(Constant.PCSelLen))
    val imem_en = Output(Bool())
    val reg_read_en = Output(Bool())
    val reg_write_en = Output(Bool())
    val inst = Input(UInt(Constant.InstLen))
    val imm_type = Output(UInt(Constant.ImmTypeLen))
    val A_sel = Output(UInt(Constant.ASelLen))
    val B_sel = Output(UInt(Constant.BSelLen))
    val WB_sel = Output(UInt(Constant.WBSelLen))
    val ALU_sel = Output(UInt(Constant.ALUSelLen))
    val ebreak_en = Output(UInt(8.W))
    val ebreak_code = Output(UInt(8.W))
    val dmem_read_en = Output(Bool())
    val dmem_read_type = Output(UInt(Constant.LdValueLen))
    val dmem_write_en = Output(Bool())
    val dmem_write_type = Output(UInt(Constant.StValueLen))
    val csr_sel = Output(UInt(Constant.CsrValLen))
    val state = Output(UInt(4.W))
  })
  import Instruction._
  val state = RegInit(UInt(4.W), STATE_IDLE)
  io.state := state
  val imm_type = Wire(UInt(3.W))
  io.imm_type := imm_type
  io.imem_en := state===STATE_FETCH_INST
  io.reg_read_en := state===STATE_EXECUTE || state===STATE_WRITE_BACK
  io.reg_write_en := state===STATE_WRITE_BACK && io.WB_sel=/=WBSelV.NO_WB
  state := MuxLookup(state, STATE_IDLE, Seq(
    STATE_IDLE -> STATE_FETCH_INST,
    STATE_FETCH_INST -> STATE_EXECUTE,
    STATE_EXECUTE -> STATE_WRITE_BACK,
    STATE_WRITE_BACK -> STATE_FETCH_INST,
  ))

  val invalid_signal = List(PCSelV.KEEP, ASelV.ZERO, BSelV.IMM, ImmType.INVALID_TYPE, WBSelV.NO_WB, 255.U, LdValue.INV, StValue.INV, ALUSelV.ZERO, CsrVal.INV)
  val map = Array(
    ADD   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.ADD , CsrVal.INV),
    SUB   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.SUB , CsrVal.INV),
    XOR   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.XOR , CsrVal.INV),
    OR    -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.OR  , CsrVal.INV),
    AND   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.AND , CsrVal.INV),
    SLL   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.SLL , CsrVal.INV),
    SRL   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.SRL , CsrVal.INV),
    SRA   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.SRA , CsrVal.INV),
    SLT   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.SLT , CsrVal.INV),
    SLTU  -> List(PCSelV.INC4,      ASelV.REG,  BSelV.REG, ImmType.R, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.SLTU, CsrVal.INV),

    ADDI  -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.ADD , CsrVal.INV),
    ANDI  -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.AND , CsrVal.INV),
    ORI   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.OR  , CsrVal.INV),
    XORI  -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.XOR , CsrVal.INV),
    SLLI  -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU,   0.U, LdValue.INV, StValue.INV, ALUSelV.SLL , CsrVal.INV),
    SRLI  -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU,   0.U, LdValue.INV, StValue.INV, ALUSelV.SRL , CsrVal.INV),
    SRAI  -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU,   0.U, LdValue.INV, StValue.INV, ALUSelV.SRA , CsrVal.INV),
    SLTI  -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU,   0.U, LdValue.INV, StValue.INV, ALUSelV.SLT , CsrVal.INV),
    SLTIU -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU,   0.U, LdValue.INV, StValue.INV, ALUSelV.SLTU, CsrVal.INV),

    LW    -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.LW ,   0.U, LdValue.LW,  StValue.INV, ALUSelV.ADD , CsrVal.INV),
    LB    -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.LB ,   0.U, LdValue.LB,  StValue.INV, ALUSelV.ADD , CsrVal.INV),
    LBU   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.LBU,   0.U, LdValue.LBU, StValue.INV, ALUSelV.ADD , CsrVal.INV),
    LH    -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.LH ,   0.U, LdValue.LH,  StValue.INV, ALUSelV.ADD , CsrVal.INV),
    LHU   -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.LHU,   0.U, LdValue.LHU, StValue.INV, ALUSelV.ADD , CsrVal.INV),

    SW    -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.S, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.SW,  ALUSelV.ADD , CsrVal.INV),
    SH    -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.S, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.SH,  ALUSelV.ADD , CsrVal.INV),
    SB    -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.S, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.SB,  ALUSelV.ADD , CsrVal.INV),

    BEQ   -> List(PCSelV.BRANCH,    ASelV.REG,  BSelV.REG, ImmType.B, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.INV, ALUSelV.EQ  , CsrVal.INV),
    BNE   -> List(PCSelV.BRANCH,    ASelV.REG,  BSelV.REG, ImmType.B, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.INV, ALUSelV.NEQ , CsrVal.INV),
    BLT   -> List(PCSelV.BRANCH,    ASelV.REG,  BSelV.REG, ImmType.B, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.INV, ALUSelV.LT  , CsrVal.INV),
    BGE   -> List(PCSelV.BRANCH,    ASelV.REG,  BSelV.REG, ImmType.B, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.INV, ALUSelV.GE  , CsrVal.INV),
    BLTU  -> List(PCSelV.BRANCH,    ASelV.REG,  BSelV.REG, ImmType.B, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.INV, ALUSelV.LTU , CsrVal.INV),
    BGEU  -> List(PCSelV.BRANCH,    ASelV.REG,  BSelV.REG, ImmType.B, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.INV, ALUSelV.GEU , CsrVal.INV),

    JAL   -> List(PCSelV.OVERWRITE, ASelV.PC,   BSelV.IMM, ImmType.J, WBSelV.PC4  , 0.U, LdValue.INV, StValue.INV, ALUSelV.ADD , CsrVal.INV),
    JALR  -> List(PCSelV.OVERWRITE, ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.PC4  , 0.U, LdValue.INV, StValue.INV, ALUSelV.ADD , CsrVal.INV),
    LUI   -> List(PCSelV.INC4,      ASelV.ZERO, BSelV.IMM, ImmType.U, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.ADD , CsrVal.INV),
    AUIPC -> List(PCSelV.INC4,      ASelV.PC,   BSelV.IMM, ImmType.U, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV, ALUSelV.ADD , CsrVal.INV),

    EBREAK-> List(PCSelV.KEEP,      ASelV.ZERO, BSelV.IMM, ImmType.I, WBSelV.NO_WB, 1.U, LdValue.INV, StValue.INV, ALUSelV.ZERO, CsrVal.INV),
    ECALL -> List(PCSelV.ECALL,     ASelV.ZERO, BSelV.IMM, ImmType.I, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.INV, ALUSelV.ZERO, CsrVal.INV),
    MRET  -> List(PCSelV.MRET,      ASelV.ZERO, BSelV.IMM, ImmType.I, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.INV, ALUSelV.ZERO, CsrVal.INV),
    CSRRW -> List(PCSelV.INC4,      ASelV.ZERO, BSelV.IMM, ImmType.I, WBSelV.CSR  , 0.U, LdValue.INV, StValue.INV, ALUSelV.ZERO, CsrVal.RW),
    CSRRS -> List(PCSelV.INC4,      ASelV.ZERO, BSelV.IMM, ImmType.I, WBSelV.CSR  , 0.U, LdValue.INV, StValue.INV, ALUSelV.ZERO, CsrVal.RS),
  )
  val signals = ListLookup(io.inst, invalid_signal, map)
  io.PC_sel := Mux(state=/=STATE_WRITE_BACK, PCSelV.KEEP, signals(0))
  io.A_sel := signals(1)
  io.B_sel := signals(2)
  io.WB_sel := signals(4)
  imm_type := signals(3)
  io.ebreak_en := state===STATE_EXECUTE && signals(5)=/=0.U
  io.ebreak_code := signals(5)
  io.dmem_read_en := state===STATE_WRITE_BACK && signals(6)=/=LdValue.INV
  io.dmem_read_type := signals(6)
  io.dmem_write_en := state===STATE_WRITE_BACK && signals(7)=/=StValue.INV
  io.dmem_write_type := signals(7)
  io.ALU_sel := signals(8)
  io.csr_sel := signals(9)
}
