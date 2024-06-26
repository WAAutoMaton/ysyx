import chisel3._
import chisel3.util._

class SRAM extends Module{
  val io = IO(new Bundle{
    val araddr = Input(UInt(Constant.BitWidth))
    val arvalid = Input(Bool())
    val arready = Output(Bool())

    val rdata = Output(UInt(Constant.BitWidth))
    val rresp = Output(UInt(2.W))
    val rvalid = Output(Bool())
    val rready = Input(Bool())

    val awaddr = Input(UInt(Constant.BitWidth))
    val awvalid = Input(Bool())
    val awready = Output(Bool())

    val wdata = Input(UInt(Constant.BitWidth))
    val wstrb = Input(UInt(4.W))
    val wvalid = Input(Bool())
    val wready = Output(Bool())

    val bresp = Output(UInt(2.W))
    val bvalid = Output(Bool())
    val bready = Input(Bool())
  })

  val pmem = Module(new PMem())
  val read_delay_cnt = RegInit(UInt(32.W), 0.U)
  val write_delay_cnt = RegInit(UInt(32.W), 0.U)
  val read_delay = RegInit(UInt(32.W), 0.U)
  val write_delay = RegInit(UInt(32.W), 0.U)
  val random = Module(new LFSR())

  private val state_r_idle :: state_r_read :: state_r_read_delay :: state_r_wait_ready :: Nil = Enum(4)


  val state_r = RegInit(state_r_idle)
  state_r := MuxLookup(state_r, state_r_idle, List(
    state_r_idle -> Mux(io.arvalid, state_r_read, state_r_idle),
    state_r_read -> state_r_read_delay,
    state_r_read_delay -> Mux(read_delay_cnt >= read_delay, state_r_wait_ready, state_r_read_delay),
    state_r_wait_ready -> Mux(io.rready, state_r_idle, state_r_wait_ready)
  ))

  read_delay := Mux(state_r === state_r_read, random.io.out, read_delay)
  read_delay_cnt := Mux(state_r === state_r_read_delay, read_delay_cnt + 1.U, 0.U)

  io.arready := state_r === state_r_idle
  val rdata = RegInit(UInt(Constant.BitWidth), 0.U)
  rdata := Mux(state_r === state_r_read, pmem.io.rdata, rdata)
  io.rdata := rdata
  io.rresp := 0.U
  io.rvalid := state_r === state_r_wait_ready

  private val state_w_idle :: state_w_wait_data :: state_w_wait_addr :: state_w_write :: state_w_write_delay :: state_w_wait_ready :: Nil = Enum(6)

  val state_w = RegInit(state_w_idle)
  state_w := MuxLookup(state_w, state_w_idle, List(
    state_w_idle -> Mux(io.awvalid && io.wvalid, state_w_write,
      Mux(io.awvalid, state_w_wait_data,
        Mux(io.wvalid, state_w_wait_addr, state_w_idle))),
    state_w_wait_data -> Mux(io.wvalid, state_w_write, state_w_wait_data),
    state_w_wait_addr -> Mux(io.awvalid, state_w_write, state_w_wait_addr),
    state_w_write -> state_w_write_delay,
    state_w_write_delay -> Mux(write_delay_cnt>= write_delay, state_w_wait_ready, state_w_write_delay),
    state_w_wait_ready -> Mux(io.bready, state_w_idle, state_w_wait_ready),
  ))

  write_delay := Mux(state_w === state_w_write, random.io.out, write_delay)
  write_delay_cnt := Mux(state_w === state_w_write_delay, write_delay_cnt + 1.U, 0.U)

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

  pmem.io.valid := state_r === state_r_read || state_w === state_w_write
  pmem.io.raddr := io.araddr
  pmem.io.waddr := waddr
  pmem.io.wdata := wdata
  pmem.io.wmask := wstrb
  pmem.io.wen := state_w === state_w_write
}
