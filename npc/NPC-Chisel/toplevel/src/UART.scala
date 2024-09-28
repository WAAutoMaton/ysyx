import chisel3._
import chisel3.util._

class UART extends Module{
  val io = IO(new Axi4IO())
  val uart = Module(new UART_V())

  private val state_w_idle :: state_w_wait_data :: state_w_wait_addr :: state_w_write :: state_w_wait_ready :: Nil = Enum(5)

  val state_w = RegInit(state_w_idle)
  state_w := MuxLookup(state_w, state_w_idle, List(
    state_w_idle -> Mux(io.awvalid && io.wvalid, state_w_write,
      Mux(io.awvalid, state_w_wait_data,
        Mux(io.wvalid, state_w_wait_addr, state_w_idle))),
    state_w_wait_data -> Mux(io.wvalid, state_w_write, state_w_wait_data),
    state_w_wait_addr -> Mux(io.awvalid, state_w_write, state_w_wait_addr),
    state_w_write -> state_w_wait_ready,
    state_w_wait_ready -> Mux(io.bready, state_w_idle, state_w_wait_ready),
  ))

  val waddr = RegInit(UInt(Constant.BitWidth), 0.U)
  val wdata = RegInit(UInt(Constant.BitWidth), 0.U)
  val wstrb = RegInit(UInt(4.W), 0.U)
  waddr := Mux(io.awvalid, io.awaddr, waddr)
  wdata := Mux(io.wvalid, io.wdata, wdata)
  wstrb := Mux(io.wvalid, io.wstrb, wstrb)

  io.awready := state_w === state_w_idle || state_w === state_w_wait_addr
  io.wready := state_w === state_w_idle || state_w === state_w_wait_data
  io.bresp := 0.U
  io.bvalid := state_w === state_w_wait_ready

  io.rresp := 0.U
  io.rvalid := false.B
  io.arready := false.B
  io.rdata := 0.U

  uart.io.valid := state_w === state_w_write
  uart.io.wdata := wdata(7,0)
}
