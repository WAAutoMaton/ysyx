import chisel3._
import chisel3.util._

object RangeLookup {

  /** @param key a key to search for
   * @param default a default value if nothing is found
   * @param mapping a sequence to search of keys and values
   * @return the value found or the default if not
   */
  def apply[S <: UInt, T <: Data](key: S, default: T, mapping: Seq[(S, S, T)]): T = {
    /* If the mapping is defined for all possible values of the key, then don't use the default value */
    val (defaultx, mappingx) = key.widthOption match {
      case Some(width) =>
        val keySetSize = BigInt(1) << width
        val keyMask = keySetSize - 1
        val distinctLitKeys = mapping.flatMap(_._1.litOption).map(_ & keyMask).distinct
        if (distinctLitKeys.size == keySetSize) {
          (mapping.head._3, mapping.tail)
        } else {
          (default, mapping)
        }
      case None => (default, mapping)
    }

    mappingx.foldLeft(defaultx) { case (d, (ks, ke, v)) => Mux(key >= ks && key <=ke, v, d) }
  }
}

// 由于Xbar 设计限制，必须先提供 awvalid 和 awaddr（或与wvalid同时提供）；
// 先提供 wvalid 将导致无法握手（由于不知道目标后端是谁）。
// 注意：输出端设备有内存时（范围为整个值域），必须把内存放在第0项上。
class AxiXbar(val OutNum: Int, val AddressMap: Array[(Long, Long)]) extends Module{
  val io = IO(new Bundle {
    val in = new AxiLiteIO()
    val out = Vec(OutNum, Flipped(new AxiLiteIO()))
  })

  val State_Bit_Width = (log2Ceil(OutNum)+1).W

  // state_r 值为 i 表示当前正在处理第 i 个输出端口，值为 OutNum 表示空闲状态
  val state_r = RegInit(OutNum.U(State_Bit_Width))
  val state_r_idle = OutNum.U
  state_r := MuxLookup(state_r, OutNum.U,
      (0 until OutNum).map(i => {
          i.U(State_Bit_Width) -> Mux(io.in.rready && io.out(i).rvalid, state_r_idle, i.U(State_Bit_Width))
        }) :+ (state_r_idle -> Mux(io.in.arvalid, RangeLookup(io.in.araddr, state_r_idle,
          AddressMap.map(
            {case (start, end) =>
              (start.U(Constant.BitWidth), end.U(Constant.BitWidth), AddressMap.indexOf((start, end)).U)
            }).toIndexedSeq
    ), state_r_idle)))

  for (i <- 0 until OutNum) {
    io.out(i).araddr := io.in.araddr
    io.out(i).arvalid := state_r === i.U(State_Bit_Width) && io.in.arvalid
    io.out(i).rready := state_r === i.U(State_Bit_Width) && io.in.rready
  }
  io.in.arready := Mux(state_r === state_r_idle, false.B, io.out(state_r).arready)
  io.in.rdata := Mux(state_r === state_r_idle, 0.U, io.out(state_r).rdata)
  io.in.rresp := Mux(state_r === state_r_idle, 0.U, io.out(state_r).rresp)
  io.in.rvalid := Mux(state_r === state_r_idle, false.B, io.out(state_r).rvalid)

  val state_w = RegInit(OutNum.U(State_Bit_Width))
  val state_w_idle = OutNum.U
  state_w := MuxLookup(state_w, OutNum.U,
    (0 until OutNum).map( i => {
        i.U(State_Bit_Width) -> Mux(io.in.bready && io.out(i).bvalid, state_w_idle, i.U(State_Bit_Width))
      }) :+ (state_w_idle -> Mux(io.in.awvalid, RangeLookup(io.in.awaddr, state_w_idle,
      AddressMap.map(
        {case (start, end) =>
          (start.U(Constant.BitWidth), end.U(Constant.BitWidth), AddressMap.indexOf((start, end)).U)
        }).toIndexedSeq
    ), state_w_idle)))

  for (i <- 0 until OutNum) {
    io.out(i).awaddr := io.in.awaddr
    io.out(i).awvalid := state_w === i.U(State_Bit_Width) && io.in.awvalid
    io.out(i).wdata := io.in.wdata
    io.out(i).wstrb := io.in.wstrb
    io.out(i).wvalid := state_w === i.U(State_Bit_Width) && io.in.wvalid
    io.out(i).bready := state_w === i.U(State_Bit_Width) && io.in.bready
  }
  io.in.awready := Mux(state_w === state_w_idle, false.B, io.out(state_w).awready)
  io.in.wready := Mux(state_w === state_w_idle, false.B, io.out(state_w).wready)
  io.in.bresp := Mux(state_w === state_w_idle, 0.U, io.out(state_w).bresp)
  io.in.bvalid := Mux(state_w === state_w_idle, false.B, io.out(state_w).bvalid)

}
