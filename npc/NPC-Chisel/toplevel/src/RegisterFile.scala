import chisel3._
import chisel3.internal.firrtl.Width
import chisel3.util.MuxLookup


class RegisterFile extends Module {
  private val REG_ADDR_LEN: Width = Constant.RegAddrLen

  val io = IO(new Bundle{
    val write_address = Input(UInt(REG_ADDR_LEN))
    val write_data = Input(UInt(Constant.BitWidth))
    val write_enable = Input(Bool())
    val reg1_addr = Input(UInt(REG_ADDR_LEN))
    val reg1_data = Output(UInt(Constant.BitWidth))
    val reg2_addr = Input(UInt(REG_ADDR_LEN))
    val reg2_data = Output(UInt(Constant.BitWidth))
    val test_reg_out = Output(Vec(Constant.RegisterNum, UInt(Constant.BitWidth)))
    val csr_rw_enable = Input(Bool())
    val csr_rs_enable = Input(Bool())
    val csr_addr = Input(UInt(Constant.BitWidth))
    val csr_wdata = Input(UInt(Constant.BitWidth))
    val csr_rdata = Output(UInt(Constant.BitWidth))
    val csr_ecall_enable = Input(Bool())
    val pc = Input(UInt(Constant.BitWidth))
    val csr_ecall_ret = Output(UInt(Constant.BitWidth))
    val csr_mret_enable = Input(Bool())
    val csr_mret_ret = Output(UInt(Constant.BitWidth))
    val test_csr_out = Output(Vec(Constant.CSRNum, UInt(Constant.BitWidth)))
  })
  private val registers = RegInit(VecInit(Seq.fill(Constant.RegisterNum)(0.U(Constant.BitWidth))))
  private val csr = RegInit(VecInit(Seq.fill(Constant.CSRNum)(0.U(Constant.BitWidth))))
  csr(4) := 0x79737978.U
  csr(5) := 23060255.U
  when(io.write_enable && io.write_address=/=0.U){
    registers(io.write_address) := io.write_data
  }
  private val csr_id = Wire(UInt(5.W))
  csr_id := MuxLookup(io.csr_addr(11,0), 7.U, Seq(
    0x300.U -> 0.U, // mstatus
    0x341.U -> 1.U, // mepc
    0x342.U -> 2.U, // mcause
    0x305.U -> 3.U, // mtvec
    0xf11.U -> 4.U, // mvendorid
    0xf12.U -> 5.U, // marchid
  ))

  io.csr_rdata := Mux(io.csr_rs_enable || io.csr_rw_enable, csr(csr_id), 0.U)
  io.csr_ecall_ret := csr(3)
  io.csr_mret_ret := csr(1)
  when(io.csr_rw_enable && csr_id=/=7.U){
    csr(csr_id) := io.csr_wdata
  }
  when(io.csr_rs_enable && csr_id=/=7.U){
    csr(csr_id) := csr(csr_id) | io.csr_wdata
  }
  when(io.csr_ecall_enable) {
    csr(2) := 11.U
    csr(1) := io.pc
    csr(0) := 0x1800.U
  }
  when(io.csr_mret_enable) {
    csr(0) := 0x80.U
  }
  io.reg1_data := registers(io.reg1_addr)
  io.reg2_data := registers(io.reg2_addr)
  io.test_reg_out := registers
  io.test_csr_out := csr
}
