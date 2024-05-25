import chisel3._
import Chisel.{Cat, MuxLookup}

class ImmediateGenerator extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))
    val imm = Output(UInt(32.W))
    val imm_type = Input(UInt(3.W))
  })
  io.imm := MuxLookup(io.imm_type, 0.U, Seq(
    ImmType.I -> io.inst(31, 20).asSInt.pad(32).asUInt,
    ImmType.U -> Cat(io.inst(31,12).asSInt.pad(20).asUInt, 0.U(12.W)),
    ImmType.J -> Cat(io.inst(31,31), io.inst(19,12), io.inst(20,20), io.inst(30,21), 0.U(1.W))
                              .asSInt.pad(32).asUInt,
    ImmType.S -> Cat(io.inst(31,25), io.inst(11,7)).asSInt.pad(32).asUInt,
    ImmType.B -> Cat(io.inst(31,31), io.inst(7,7), io.inst(30,25), io.inst(11,8), 0.U(1.W))
                              .asSInt.pad(32).asUInt,
  ))
}
