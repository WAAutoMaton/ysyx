import chisel3._

class PMem extends BlackBox{
  val io = IO(new Bundle{
    val valid = Input(Bool())
    val raddr = Input(UInt(32.W))
    val rdata = Output(UInt(32.W))
    val waddr = Input(UInt(32.W))
    val wdata = Input(UInt(32.W))
    val wmask = Input(UInt(8.W))
    val wen = Input(Bool())
  })
}
