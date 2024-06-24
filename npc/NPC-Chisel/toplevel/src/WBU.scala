import chisel3._
import chisel3.util._

class WBU extends Module{
  val io = IO(new Bundle{
    val in = Flipped(Decoupled(new EXU_Output))
    val out = Decoupled(new IFU_Input)
    val wb_data = Output(UInt(Constant.BitWidth))
    val wb_addr = Output(UInt(Constant.RegAddrLen))
    val wb_en = Output(Bool())
  })

  private val state_idle :: state_execute :: state_mem_read :: state_wait_ready :: Nil = Enum(4)
  val state = RegInit(state_idle)
  state := MuxLookup(state, state_idle, List(
    state_idle -> Mux(io.in.valid, state_execute, state_idle),
    state_execute -> state_mem_read,
    state_mem_read -> state_wait_ready,
    state_wait_ready -> Mux(io.out.ready, state_idle, state_wait_ready)
  ))

  val dmem = Module(new SRAM())

  val imm = RegInit(UInt(Constant.BitWidth), 0.U)
  imm := Mux(io.in.valid && io.in.ready, io.in.bits.imm, imm)
  val pc = RegInit(UInt(Constant.BitWidth), 0.U)
  pc := Mux(io.in.ready && io.in.valid, io.in.bits.pc, pc)
  val input = Reg(new EXU_Output())
  input := Mux(io.in.ready && io.in.valid, io.in.bits, input)
  val csig = input.control_signal
  val alu_result = input.alu_result
  val csr_pc_result = input.csr_pc_result
  val csr_rdata = input.csr_rdata

  val new_pc = RegInit(UInt(Constant.BitWidth), 0.U)
  new_pc := MuxLookup(csig.PC_sel, pc, Seq(
    PCSelV.KEEP -> pc,
    PCSelV.INC4 -> (pc + 4.U),
    PCSelV.OVERWRITE -> alu_result,
    PCSelV.BRANCH -> Mux(alu_result(0), (pc + imm), (pc + 4.U)),
    PCSelV.ECALL  -> csr_pc_result,
    PCSelV.MRET   -> csr_pc_result
  ))

  // 内存访问需要4字节对齐，非4字节对齐的 lb/lh 指令需要对结果进行偏移
  val roffset = (alu_result(1,0)<<3.U)
  val shift_rdata = Wire(UInt(Constant.BitWidth))
  shift_rdata := dmem.io.rdata >> roffset
  io.wb_addr := input.inst(11, 7)
  io.wb_en := state===state_mem_read && csig.WB_sel=/=WBSelV.NO_WB
  io.wb_data := MuxLookup(csig.WB_sel, 0.U, Seq(
    WBSelV.ALU -> alu_result,
    WBSelV.PC4 -> (pc+4.U),
    WBSelV.LW -> shift_rdata,
    WBSelV.LBU -> shift_rdata(7, 0),
    WBSelV.LHU -> shift_rdata(15, 0),
    WBSelV.LB -> shift_rdata(7, 0).asSInt.pad(32).asUInt,
    WBSelV.LH -> shift_rdata(15, 0).asSInt.pad(32).asUInt,
    WBSelV.CSR -> csr_rdata,
  ))

  val dmem_write_data = Wire(UInt(Constant.BitWidth))
  // 内存访问需要4字节对齐，非4字节对齐的 sb/sw 指令需要对数据进行偏移
  val woffset = alu_result(1,0)<<3.U
  dmem_write_data := input.reg2_data << woffset
  dmem.io.valid := state === state_execute && (csig.dmem_read_en || csig.dmem_write_en)
  dmem.io.raddr := alu_result >> 2.U << 2.U
  dmem.io.wen := state === state_execute && csig.dmem_write_en
  dmem.io.waddr := alu_result >> 2.U << 2.U
  dmem.io.wdata := dmem_write_data
  dmem.io.wmask := MuxLookup(csig.dmem_write_type, "b0000".U, Seq(
    StValue.SW -> "b1111".U,
    StValue.SH -> ("b11".U << alu_result(1,0)),
    StValue.SB -> ("b1".U << alu_result(1,0)),
  ))

  io.out.valid := state === state_wait_ready
  io.in.ready := state === state_idle
  io.out.bits.pc := new_pc

}
