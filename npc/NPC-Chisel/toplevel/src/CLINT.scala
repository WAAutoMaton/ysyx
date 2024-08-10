import chisel3._
import chisel3.util._

class CLINT extends Module{
  val io = IO(new AxiLiteIO())
  private val state_r_idle :: state_r_read :: state_r_wait_ready :: Nil = Enum(3)

  val state_r = RegInit(state_r_idle)
  state_r := MuxLookup(state_r, state_r_idle, List(
    state_r_idle -> Mux(io.arvalid, state_r_read, state_r_idle),
    state_r_read -> state_r_wait_ready,
    state_r_wait_ready -> Mux(io.rready, state_r_idle, state_r_wait_ready)
  ))

  private val time = RegInit(UInt(64.W), 0.U)
  time := time+1.U

  io.arready := state_r === state_r_idle
  val rdata = RegInit(UInt(Constant.BitWidth), 0.U)
  rdata := Mux(state_r === state_r_read, Mux(io.araddr===0xa0000048L.U, time(31,0), time(63,32)), rdata)
  io.rdata := rdata
  io.rresp := 0.U
  io.rvalid := state_r === state_r_wait_ready

  io.awready := false.B
  io.wready := false.B
  io.bresp := 0.U
  io.bvalid := false.B
}
