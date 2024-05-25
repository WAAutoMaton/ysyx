import chisel3._
import chisel3.internal.firrtl.Width


class RegisterFile extends Module {
  val REG_ADDR_LEN: Width = 5.W

  val io = IO(new Bundle{
    val write_address = Input(UInt(REG_ADDR_LEN))
    val write_data = Input(UInt(32.W))
    val write_enable = Input(Bool())
    val reg1_addr = Input(UInt(REG_ADDR_LEN))
    val reg1_read_enable = Input(Bool())
    val reg1_data = Output(UInt(32.W))
    val reg2_addr = Input(UInt(REG_ADDR_LEN))
    val reg2_read_enable = Input(Bool())
    val reg2_data = Output(UInt(32.W))
    val test_reg_out = Output(Vec(32, UInt(32.W)))
  })
  private val registers = RegInit(VecInit(Seq.fill(32)(0.U(32.W))))
  when(io.write_enable && io.write_address=/=0.U){
    registers(io.write_address) := io.write_data
  }
  io.reg1_data := Mux(io.reg1_read_enable, registers(io.reg1_addr), 0.U)
  io.reg2_data := Mux(io.reg2_read_enable, registers(io.reg2_addr), 0.U)
  io.test_reg_out := registers
}
