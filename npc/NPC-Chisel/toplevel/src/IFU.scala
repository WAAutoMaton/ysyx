import chisel3._
import chisel3.util.{Decoupled, Enum, MuxLookup}

class IFU_Input extends Bundle{
  val pc = UInt(Constant.BitWidth)
}

class IFU_Output extends Bundle{
  val inst = UInt(Constant.InstLen)
  val pc = UInt(Constant.BitWidth)
}

class IFU extends Module{
  val io = IO(new Bundle{
    val in = Flipped(Decoupled(new IFU_Input))
    val out = Decoupled(new IFU_Output)
    val test_imem_en = Output(Bool())
    val test_pc = Output(UInt(Constant.BitWidth))
  })
  private val state_idle :: state_read :: state_wait_ready :: Nil = Enum(3)
  val state = RegInit(state_idle)
  state := MuxLookup(state, state_idle, List(
    state_idle -> Mux(io.in.valid, state_read, state_idle),
    state_read -> state_wait_ready,
    state_wait_ready -> Mux(io.out.ready, state_idle, state_wait_ready)
  ))
  val pc = RegInit(UInt(Constant.BitWidth), 0x80000000L.U)
  val inst = RegInit(UInt(Constant.InstLen), 0.U)
  val imem = Module(new PMem())
  imem.io.raddr := pc
  imem.io.wen := false.B
  imem.io.waddr := 0.U
  imem.io.wdata := 0.U
  imem.io.wmask := 0.U
  imem.io.valid := state === state_read
  pc := Mux(io.in.valid && io.in.ready, io.in.bits.pc, pc)
  inst := Mux(state === state_read, imem.io.rdata, inst)

  io.in.ready := state === state_idle
  io.out.valid := state === state_wait_ready
  io.out.bits.inst := inst
  io.out.bits.pc := pc

  io.test_imem_en := imem.io.valid
  io.test_pc := pc
}
