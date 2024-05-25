import chisel3._

class EBreak extends BlackBox{
  val io = IO(new Bundle{
    val enable = Input(Bool())
    val code   = Input(UInt(8.W))
  })
}
