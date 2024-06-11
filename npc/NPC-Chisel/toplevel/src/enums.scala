import chisel3._
import chisel3.internal.firrtl.Width

object Constant  {
  val BitWidth: Width = 32.W
  val InstLen: Width = 32.W
  val ALUSelLen: Width = 6.W
  val PCSelLen: Width = 3.W
  val ASelLen: Width = 2.W
  val BSelLen: Width = 2.W
  val WBSelLen: Width = 4.W
  val ImmTypeLen: Width = 3.W
  val LdValueLen: Width = 3.W
  val StValueLen: Width = 3.W
  val CsrValLen: Width = 2.W
  val RegisterNum = 32
  val CSRNum = 4
}
object ImmType extends Enumeration {
  val INVALID_TYPE: UInt = 0.U
  val I: UInt = 1.U
  val S: UInt = 2.U
  val B: UInt = 3.U
  val U: UInt = 4.U
  val J: UInt = 5.U
  val R: UInt = 6.U
}

object PCSelV extends Enumeration {
  val KEEP: UInt = 0.U
  val INC4: UInt = 1.U
  val OVERWRITE: UInt = 2.U
  val BRANCH:    UInt = 3.U
  val ECALL: UInt = 4.U
  val MRET: UInt = 5.U
}

object ASelV extends Enumeration {
  val ZERO: UInt = 0.U
  val REG: UInt = 1.U
  val PC:  UInt = 2.U
}

object BSelV extends Enumeration {
  val REG: UInt = 0.U
  val IMM: UInt = 1.U
}

object WBSelV extends Enumeration {
  val NO_WB: UInt = 0.U
  val ALU: UInt = 1.U
  val PC4: UInt = 2.U
  val LW: UInt = 3.U
  val LBU: UInt = 4.U
  val LHU: UInt = 5.U
  val LB: UInt = 6.U
  val LH: UInt = 7.U
  val CSR: UInt = 8.U
}

object ALUSelV extends Enumeration {
  val ZERO: UInt = 0.U
  val ADD: UInt = 1.U
  val SUB: UInt = 2.U
  val AND: UInt = 10.U
  val OR: UInt = 11.U
  val XOR: UInt = 12.U
  val EQ: UInt = 13.U
  val NEQ: UInt = 14.U
  val LT: UInt = 15.U
  val LTU : UInt = 16.U
  val GEU: UInt = 3.U
  val GE: UInt = 4.U
  val SLL: UInt = 5.U
  val SRL: UInt = 6.U
  val SRA: UInt = 7.U
  val SLT: UInt = 8.U
  val SLTU: UInt = 9.U
}

object LdValue extends Enumeration {
  val INV: UInt = 0.U
  val LB: UInt = 1.U
  val LH: UInt = 2.U
  val LW: UInt = 3.U
  val LBU: UInt = 4.U
  val LHU: UInt = 5.U
}

object StValue extends Enumeration {
  val INV: UInt = 0.U
  val SB: UInt = 1.U
  val SH: UInt = 2.U
  val SW: UInt = 3.U
}

object CsrVal extends Enumeration {
  val INV: UInt = 0.U
  val RW: UInt = 1.U
  val RS: UInt = 2.U
}
