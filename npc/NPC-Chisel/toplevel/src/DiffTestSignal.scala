import chisel3._

class DiffTestSignal extends BlackBox{
  val io = IO(new Bundle{
    val enable = Input(Bool())
    val pc = Input(UInt(Constant.BitWidth))
    val regs = Input(Vec(Constant.RegisterNum, UInt(Constant.BitWidth)))
    val csr = Input(Vec(Constant.CSRNum, UInt(Constant.BitWidth)))
  })
}
