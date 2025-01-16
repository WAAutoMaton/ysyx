import chisel3._

class Print extends BlackBox{
  val io = IO(new Bundle{
    val enable = Input(Bool())
    val data   = Input(UInt(32.W))
  })
}