require 'minitest/autorun'

require 'register'

class RegisterTest < MiniTest::Unit::TestCase
  def setup
    @memory = Minitest::Mock.new
    @reg = Register.new(@memory)
  end

  def teardown
    # Do nothing
  end

  def test_a
    @reg.a = 0x12
    assert_equal(@reg.a, 0x12)
  end

  def test_b
    @reg.b = 0x12
    assert_equal(@reg.b, 0x12)
  end

  def test_c
    @reg.c = 0x12
    assert_equal(@reg.c, 0x12)
  end

  def test_d
    @reg.d = 0x12
    assert_equal(@reg.d, 0x12)
  end

  def test_e
    @reg.e = 0x12
    assert_equal(@reg.e, 0x12)
  end

  def test_h
    @reg.h = 0x12
    assert_equal(@reg.h, 0x12)
  end

  def test_l
    @reg.l = 0x12
    assert_equal(@reg.l, 0x12)
  end

  def test_pc
    @reg.pc = 0x1234
    assert_equal(@reg.pc, 0x1234)
  end

  def test_sp
    @reg.sp = 0x1234
    assert_equal(@reg.sp, 0x1234)
  end

  def test_bc
    @reg.bc = 0x1234
    assert_equal(@reg.bc, 0x1234)
    assert_equal(@reg.b, 0x12)
    assert_equal(@reg.c, 0x34)
    @reg.b = 0x56
    @reg.c = 0x78
    assert_equal(@reg.bc, 0x5678)
  end

  def test_de
    @reg.de = 0x1234
    assert_equal(@reg.de, 0x1234)
    assert_equal(@reg.d, 0x12)
    assert_equal(@reg.e, 0x34)
    @reg.d = 0x56
    @reg.e = 0x78
    assert_equal(@reg.de, 0x5678)
  end

  def test_hl
    @reg.hl = 0x1234
    assert_equal(@reg.hl, 0x1234)
    assert_equal(@reg.h, 0x12)
    assert_equal(@reg.l, 0x34)
    @reg.h = 0x56
    @reg.l = 0x78
    assert_equal(@reg.hl, 0x5678)
  end

  def test_flag
    assert(@reg.flag)
  end

  def test_reg_set
    @reg.set(0b000, 0x01)
    assert_equal(0x01, @reg.b)
    @reg.set(0b001, 0x02)
    assert_equal(0x02, @reg.c)
    @reg.set(0b010, 0x03)
    assert_equal(0x03, @reg.d)
    @reg.set(0b011, 0x04)
    assert_equal(0x04, @reg.e)
    @reg.set(0b100, 0x05)
    assert_equal(0x05, @reg.h)
    @reg.set(0b101, 0x06)
    assert_equal(0x06, @reg.l)

    @memory.expect(:write, nil, [0x0506, 0x07])
    @reg.set(0b110, 0x07)
    @memory.verify

    @reg.set(0b111, 0x08)
    assert_equal(0x08, @reg.a)
  end

  def test_reg_get
    @reg.b = 0x01
    assert(@reg.b, @reg.get(0b000))
    @reg.c = 0x02
    assert(@reg.c, @reg.get(0b001))
    @reg.d = 0x03
    assert(@reg.d, @reg.get(0b010))
    @reg.e = 0x04
    assert(@reg.e, @reg.get(0b011))
    @reg.h = 0x05
    assert(@reg.h, @reg.get(0b100))
    @reg.l = 0x06
    assert(@reg.l, @reg.get(0b101))

    @memory.expect(:read, 0x07, [0x0506])
    assert(0x07, @reg.get(0b110))
    @memory.verify

    @reg.a = 0x08
    assert(@reg.a, @reg.get(0b111))
  end

  def test_inc_pc
    @reg.pc = 0x0000
    @reg.inc_pc
    assert(0x0001, @reg.pc)
    @reg.inc_pc(2)
    assert(0x0003, @reg.pc)
    @reg.pc = 0xFFFF
    @reg.inc_pc
    assert(0x0000, @reg.pc)
    @reg.pc = 0xFFFF
    @reg.inc_pc(2)
    assert(0x0001, @reg.pc)
  end
end