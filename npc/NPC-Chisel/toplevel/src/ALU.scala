import chisel3._
import Chisel.MuxLookup
import ALUSelV._
class ALU extends Module{
  val io = IO(new Bundle{
    val src1 = Input(UInt(Constant.BitWidth))
    val src2 = Input(UInt(Constant.BitWidth))
    val result = Output(UInt(Constant.BitWidth))
    val sel = Input(UInt(Constant.ALUSelLen))
  })
  io.result := MuxLookup(io.sel, 0.U, Seq(
    ADD -> (io.src1 + io.src2),
    SUB -> (io.src1 - io.src2),
    AND -> (io.src1 & io.src2),
    OR  -> (io.src1 | io.src2),
    XOR -> (io.src1 ^ io.src2),
    EQ  -> (io.src1 === io.src2),
    NEQ -> (io.src1 =/= io.src2),
    LT  -> (io.src1.asSInt < io.src2.asSInt),
    GE  -> (io.src1.asSInt >= io.src2.asSInt),
    LTU -> (io.src1 < io.src2),
    GEU -> (io.src1 >= io.src2),
    SLL -> (io.src1 << io.src2(4,0)),
    SRL -> (io.src1 >> io.src2),
    SRA -> (io.src1.asSInt >> io.src2(4,0)).asUInt,
    SLT -> (io.src1.asSInt < io.src2.asSInt),
    SLTU-> (io.src1 < io.src2),
  ))
}
