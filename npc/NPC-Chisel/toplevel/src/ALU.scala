import chisel3._
class ALU extends Module{
  val io = IO(new Bundle{
    val src1 = Input(UInt(32.W))
    val src2 = Input(UInt(32.W))
    val result = Output(UInt(32.W))
  })
  io.result := io.src1 + io.src2
}
