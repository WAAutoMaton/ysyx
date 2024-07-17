import chisel3._
import chisel3.util._

class AxiLiteIO extends Bundle{
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
}

class AxiArbiter extends Module{
    val io = IO(new Bundle {
      val in1 = new AxiLiteIO()
      val in2 = new AxiLiteIO()
      val out = Flipped(new AxiLiteIO())
    })

  val state_r_idle :: state_r_master_1 :: state_r_master_2 :: Nil = Enum(3)

  val state_r = RegInit(state_r_idle)

  state_r := MuxLookup(state_r, state_r_idle, List(
    state_r_idle -> Mux(io.in1.arvalid, state_r_master_1,
      Mux(io.in2.arvalid, state_r_master_2, state_r_idle)),
    state_r_master_1 -> Mux(io.in1.rready && io.out.rvalid, state_r_idle, state_r_master_1),
    state_r_master_2 -> Mux(io.in2.rready && io.out.rvalid, state_r_idle, state_r_master_2)
  ))

  io.out.araddr := Mux(state_r === state_r_master_1, io.in1.araddr, io.in2.araddr)
  io.out.arvalid := MuxLookup(state_r, false.B, Seq(
    state_r_master_1 -> io.in1.arvalid,
    state_r_master_2 -> io.in2.arvalid
  ))
  io.in1.arready := state_r === state_r_master_1 && io.out.arready
  io.in2.arready := state_r === state_r_master_2 && io.out.arready
  io.in1.rdata := io.out.rdata
  io.in2.rdata := io.out.rdata
  io.in1.rresp := io.out.rresp
  io.in2.rresp := io.out.rresp
  io.in1.rvalid := io.out.rvalid && state_r === state_r_master_1
  io.in2.rvalid := io.out.rvalid && state_r === state_r_master_2
  io.out.rready := MuxLookup(state_r, false.B, Seq(
    state_r_master_1 -> io.in1.rready,
    state_r_master_2 -> io.in2.rready
  ))

  val state_w_idle :: state_w_master_1 :: state_w_master_2 :: Nil = Enum(3)
  val state_w = RegInit(state_w_idle)

  state_w := MuxLookup(state_w, state_w_idle, List(
    state_w_idle -> Mux(io.in1.wvalid || io.in1.awvalid, state_w_master_1,
      Mux(io.in2.wvalid || io.in2.awvalid, state_w_master_2, state_w_idle)),
    state_w_master_1 -> Mux(io.in1.bready && io.out.bvalid, state_w_idle, state_w_master_1),
    state_w_master_2 -> Mux(io.in2.bready && io.out.bvalid, state_w_idle, state_w_master_2)
  ))

  io.out.awaddr := Mux(state_w === state_w_master_1, io.in1.awaddr, io.in2.awaddr)
  io.out.awvalid := MuxLookup(state_w, false.B, Seq(
    state_w_master_1 -> io.in1.awvalid,
    state_w_master_2 -> io.in2.awvalid
  ))
  io.out.wdata := Mux(state_w === state_w_master_1, io.in1.wdata, io.in2.wdata)
  io.out.wstrb := Mux(state_w === state_w_master_1, io.in1.wstrb, io.in2.wstrb)
  io.out.wvalid := MuxLookup(state_w, false.B, Seq(
    state_w_master_1 -> io.in1.wvalid,
    state_w_master_2 -> io.in2.wvalid
  ))
  io.in1.awready := state_w === state_w_master_1 && io.out.awready
  io.in2.awready := state_w === state_w_master_2 && io.out.awready
  io.in1.wready := state_w === state_w_master_1 && io.out.wready
  io.in2.wready := state_w === state_w_master_2 && io.out.wready
  io.in1.bresp := io.out.bresp
  io.in2.bresp := io.out.bresp
  io.in1.bvalid := io.out.bvalid && state_w === state_w_master_1
  io.in2.bvalid := io.out.bvalid && state_w === state_w_master_2
  io.out.bready := MuxLookup(state_w, false.B, Seq(
    state_w_master_1 -> io.in1.bready,
    state_w_master_2 -> io.in2.bready
  ))
}
