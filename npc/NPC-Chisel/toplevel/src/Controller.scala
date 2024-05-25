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
    val PC_sel = Output(UInt(2.W))
    val imem_en = Output(Bool())
    val reg_read_en = Output(Bool())
    val reg_write_en = Output(Bool())
    val inst = Input(UInt(32.W))
    val imm_type = Output(UInt(3.W))
    val A_sel = Output(UInt(2.W))
    val B_sel = Output(UInt(2.W))
    val WB_sel = Output(UInt(2.W))
    val ebreak_en = Output(UInt(8.W))
    val ebreak_code = Output(UInt(8.W))
    val dmem_read_en = Output(Bool())
    val dmem_read_type = Output(UInt(4.W))
    val dmem_write_en = Output(Bool())
    val dmem_write_mask = Output(UInt(8.W))
  })
  import Instruction._
  val state = RegInit(UInt(4.W), STATE_IDLE)
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

  val invalid_signal = List(PCSelV.KEEP, ASelV.ZERO, BSelV.IMM, ImmType.INVALID_TYPE, WBSelV.NO_WB, 255.U, LdValue.INV, StValue.INV)
  val map = Array(

    ADDI  -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV),

    LW    -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.DMEM , 0.U, LdValue.LW,  StValue.INV),

    SW    -> List(PCSelV.INC4,      ASelV.REG,  BSelV.IMM, ImmType.S, WBSelV.NO_WB, 0.U, LdValue.INV, StValue.SW),

    JAL   -> List(PCSelV.OVERWRITE, ASelV.PC,   BSelV.IMM, ImmType.J, WBSelV.PC4  , 0.U, LdValue.INV, StValue.INV),
    JALR  -> List(PCSelV.OVERWRITE, ASelV.REG,  BSelV.IMM, ImmType.I, WBSelV.PC4  , 0.U, LdValue.INV, StValue.INV),
    LUI   -> List(PCSelV.INC4,      ASelV.ZERO, BSelV.IMM, ImmType.U, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV),
    AUIPC -> List(PCSelV.INC4,      ASelV.PC,   BSelV.IMM, ImmType.U, WBSelV.ALU  , 0.U, LdValue.INV, StValue.INV),

    EBREAK-> List(PCSelV.KEEP,      ASelV.ZERO, BSelV.IMM, ImmType.INVALID_TYPE, WBSelV.NO_WB, 1.U, LdValue.INV, StValue.INV),
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
  io.dmem_write_mask := MuxLookup(signals(7), 0.U, Seq(
    StValue.SB -> "b1".U,
    StValue.SH -> "b11".U,
    StValue.SW -> "b1111".U,
  ))
}
