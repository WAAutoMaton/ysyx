/*
import chisel3.util._
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

}*/
