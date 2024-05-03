import chisel3._
import chiseltest._
import org.scalatest._

import flatspec._
import matchers._


class TopLevelSpec extends AnyFlatSpec with ChiselScalatestTester with GivenWhenThen with should.Matchers {
  behavior of "Toplevel io sample"

  def ToUInt(x: Int): Int = if(x>=0) x else 16+x

  it should "Unsigned addition" in {
    test(new TopLevel()).withAnnotations(
      Seq(
        WriteVcdAnnotation,
        // VerilatorBackendAnnotation, // Uncomment to use the Verilator backend
      ),
    ) { c =>
      c.io.out.expect(1.U)
      c.clock.step(1)
      c.io.out.expect("b10000000".U)
      c.clock.step(1)
      c.io.out.expect("b01000000".U)
    }
  }
}
