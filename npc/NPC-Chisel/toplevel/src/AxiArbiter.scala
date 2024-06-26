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

  
}
