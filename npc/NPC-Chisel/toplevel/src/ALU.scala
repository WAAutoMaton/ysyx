import chisel3._
import Chisel.MuxLookup
import ALUSelV._
class ALU extends Module{
  val io = IO(new Bundle{
    val src1 = Input(UInt(32.W))
    val src2 = Input(UInt(32.W))
    val result = Output(UInt(32.W))
    val sel = Input(UInt(6.W))
  })
  io.result := MuxLookup(io.sel, 0.U, Seq(
    ADD -> (io.src1 + io.src2),
    SUB -> (io.src1 - io.src2),
    GEU -> (io.src1 >= io.src2),
  ))
}
