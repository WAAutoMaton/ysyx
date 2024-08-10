import chisel3._

class UART_V extends BlackBox {
  val io = IO(new Bundle{
    val valid = Input(Bool())
    val wdata = Input(UInt(8.W))
  })
}
