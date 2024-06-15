import chisel3._
import chisel3.util._
import Instruction._

class ControlSignal extends Bundle {
  val PC_sel = UInt(Constant.PCSelLen)
  val A_sel = UInt(Constant.ASelLen)
  val B_sel = UInt(Constant.BSelLen)
  val WB_sel = UInt(Constant.WBSelLen)
  val ALU_sel = UInt(Constant.ALUSelLen)
  val csr_sel = UInt(Constant.CsrValLen)
  val ebreak_en = UInt(8.W)
  val ebreak_code = UInt(8.W)
  val dmem_read_en = Bool()
  val dmem_read_type = UInt(Constant.LdValueLen)
  val dmem_write_en = Bool()
  val dmem_write_type = UInt(Constant.StValueLen)
}

class IDU_Output extends Bundle{
  val control_signal = new ControlSignal
  val imm = UInt(Constant.BitWidth)
}

class IDU extends Module{
  val io = IO(new Bundle{
    val in = Flipped(Decoupled(new IFU_Output))
    val out = Decoupled(new IDU_Output)
  })
  private val state_idle :: state_decode :: state_wait_ready :: Nil = Enum(3)
  val state = RegInit(state_idle)
  state := MuxLookup(state, state_idle, List(
    state_idle -> Mux(io.in.valid, state_decode, state_idle),
    state_decode -> state_wait_ready,
    state_wait_ready -> Mux(io.out.ready, state_idle, state_wait_ready)
  ))
  val imm_gen = Module(new ImmediateGenerator)
  val inst = RegInit(UInt(Constant.InstLen), 0.U)
  inst := Mux(io.in.ready && io.in.valid, io.in.bits.inst, inst)

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
  val signals = ListLookup(inst, invalid_signal, map)
  val csig = Wire(new ControlSignal)
  csig.PC_sel := signals(0)
  csig.A_sel := signals(1)
  csig.B_sel := signals(2)
  csig.WB_sel := signals(4)
  val imm_type = signals(3)
  csig.ebreak_en := signals(5)=/=0.U
  csig.ebreak_code := signals(5)
  csig.dmem_read_en := signals(6)=/=LdValue.INV
  csig.dmem_read_type := signals(6)
  csig.dmem_write_en := signals(7)=/=StValue.INV
  csig.dmem_write_type := signals(7)
  csig.ALU_sel := signals(8)
  csig.csr_sel := signals(9)

  imm_gen.io.inst := inst
  imm_gen.io.imm_type := imm_type

  io.out.bits.imm := imm_gen.io.imm
  io.out.bits.control_signal := csig
  io.out.valid := state === state_wait_ready
  io.in.ready := state === state_idle

}
