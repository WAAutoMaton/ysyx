import Chisel.MuxLookup
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
  })
  val state = RegInit(UInt(4.W), STATE_IDLE)
  val imm_type = Wire(UInt(3.W))
  val instruction = Wire(UInt(7.W))
  io.PC_sel := Mux(state=/=STATE_WRITE_BACK, PCSelValue.KEEP, Mux(
    imm_type === ImmediateType.J_TYPE, PCSelValue.OVERWRITE, PCSelValue.INC4
  ))
  io.imm_type := imm_type
  io.imem_en := state===STATE_FETCH_INST
  io.reg_read_en := state===STATE_EXECUTE || state===STATE_WRITE_BACK
  io.reg_write_en := Mux(state===STATE_WRITE_BACK, true.B,
    MuxLookup(instruction, false.B, Seq(
      Instruction.ADDI -> true.B,
      Instruction.SW -> false.B,
      Instruction.JAL -> true.B,
      Instruction.JALR -> true.B,
      Instruction.LUI -> true.B,
    )))
  state := MuxLookup(state, STATE_IDLE, Seq(
    STATE_IDLE -> STATE_FETCH_INST,
    STATE_FETCH_INST -> STATE_EXECUTE,
    STATE_EXECUTE -> STATE_WRITE_BACK,
    STATE_WRITE_BACK -> STATE_FETCH_INST,
  ))

  imm_type := MuxLookup(io.inst(6,0), ImmediateType.INVALID_TYPE, Seq(
    0x33.U -> ImmediateType.R_TYPE,
    0x13.U -> ImmediateType.I_TYPE,
    0x3.U  -> ImmediateType.I_TYPE,
    0x23.U -> ImmediateType.S_TYPE,
    0x63.U -> ImmediateType.B_TYPE,
    0x6F.U -> ImmediateType.J_TYPE,
    0x67.U -> ImmediateType.I_TYPE,
    0x37.U -> ImmediateType.U_TYPE,
    0x17.U -> ImmediateType.U_TYPE,
    0x73.U -> ImmediateType.I_TYPE,
  ))
  instruction := MuxLookup(io.inst(6,0), Instruction.INVALID, Seq(
    0x13.U -> Instruction.ADDI,
    0x23.U -> Instruction.SW,
    0x6F.U -> Instruction.JAL,
    0x67.U -> Instruction.JALR,
    0x37.U -> Instruction.LUI,
    0x73.U -> Instruction.EBREAK,
  ))
  io.A_sel := MuxLookup(instruction, ASelValue.ZERO, Seq(
    Instruction.ADDI -> ASelValue.REG,
    Instruction.SW -> ASelValue.REG,
    Instruction.JAL -> ASelValue.PC,
    Instruction.JALR -> ASelValue.REG,
    Instruction.LUI -> ASelValue.ZERO,
  ))
  io.B_sel := MuxLookup(instruction, BSelValue.REG, Seq(
    Instruction.ADDI -> BSelValue.IMM,
    Instruction.SW -> BSelValue.IMM,
    Instruction.JAL -> BSelValue.IMM,
    Instruction.JALR -> BSelValue.IMM,
    Instruction.LUI -> BSelValue.IMM,
  ))
  io.WB_sel := MuxLookup(instruction, WBSelValue.ALU, Seq(
    Instruction.ADDI -> WBSelValue.ALU,
    Instruction.SW -> WBSelValue.NOT_APPLY,
    Instruction.JAL -> WBSelValue.PC4,
    Instruction.JALR -> WBSelValue.PC4,
    Instruction.LUI -> WBSelValue.ALU,
  ))
}
