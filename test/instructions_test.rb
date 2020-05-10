require 'minitest/autorun'

require 'cpu'
require 'instruction'
require 'memory_stub'

class InstructionsTest < MiniTest::Unit::TestCase
  def setup
    @memory = MemoryStub.new
    @cpu = CPU.new(memory: @memory)
  end

  def teardown
    # Do nothing
  end

  def test_call
    @memory.set(0x5678, [0xCD, 0x34, 0x12])
    reg = @cpu.reg
    reg.pc = 0x5678
    reg.sp = 0x2000
    @cpu.run_step
    assert_equal(0x1234, reg.pc)
    assert_equal(0x1FFE, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x0000, reg.hl)
    assert_equal(0x7B, @memory.read(0x1FFE))
    assert_equal(0x56, @memory.read(0x1FFF))
  end

  def test_ret
    @memory.set(0x0000, [0xC9])
    reg = @cpu.reg
    reg.sp = 0x1FFE
    @memory.set(0x1FFE, [0x34, 0x12])
    @cpu.run_step
    assert_equal(0x1234, reg.pc)
    assert_equal(0x2000, reg.sp)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x0000, reg.hl)

    # TODO sp=0xFFFE check
  end

  def test_lxi_d
    @memory.set(0x0000, [0x11, 0x34, 0x12])
    reg = @cpu.reg
    @cpu.run_step
    assert_equal(0x0003, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x1234, reg.de)
    assert_equal(0x0000, reg.hl)
  end

  def test_lxi_h
    @memory.set(0x0000, [0x21, 0x34, 0x12])
    reg = @cpu.reg
    @cpu.run_step
    assert_equal(0x0003, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x1234, reg.hl)
  end

  def test_lxi_sp
    @memory.set(0x0000, [0x31, 0x34, 0x12])
    reg = @cpu.reg
    @cpu.run_step
    assert_equal(0x0003, reg.pc)
    assert_equal(0x1234, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x0000, reg.hl)
  end

  def test_ldax_d
    @memory.set(0x0000, [0x1A])
    @memory.set(0x1234, [0x56])
    reg = @cpu.reg
    reg.de = 0x1234
    @cpu.run_step
    assert_equal(0x0001, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x56, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x1234, reg.de)
    assert_equal(0x0000, reg.hl)
  end

  def test_inx_d
    @memory.set(0x0000, [0x13])
    reg = @cpu.reg
    reg.de = 0x1234
    @cpu.run_step
    assert_equal(0x0001, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x1235, reg.de)
    assert_equal(0x0000, reg.hl)

    reg.pc = 0
    reg.de = 0xFFFF
    @cpu.run_step
    assert_equal(0x0000, reg.de)
  end

  def test_inx_h
    @memory.set(0x0000, [0x23])
    reg = @cpu.reg
    reg.hl = 0x1234
    @cpu.run_step
    assert_equal(0x0001, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x1235, reg.hl)

    reg.pc = 0
    reg.hl = 0xFFFF
    @cpu.run_step
    assert_equal(0x0000, reg.hl)
  end

  def test_mov_m_a
    @memory.set(0x0000, [0x77]) #011110111
    reg = @cpu.reg
    reg.hl = 0x1234
    reg.a = 0x56
    @cpu.run_step
    assert_equal(0x0001, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x56, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x1234, reg.hl)
    assert(0x56, @memory.read(0x1234))
  end

  def test_hlt
    @memory.set(0x0000, [0x76])
    reg = @cpu.reg
    @cpu.run_step
    assert_equal(0x0001, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x0000, reg.hl)
    assert(@cpu.halt?)
  end

  def test_mvi
    # 00RRR110
    @memory.set(0x0000, [0x06, 0x01, # B 00000110
                         0x0E, 0x02, # C 00001110
                         0x16, 0x03, # D 00010110
                         0x1E, 0x04, # E 00011110
                         0x26, 0x05, # H 00100110
                         0x2E, 0x06, # L 00101110
                         0x36, 0x07, # M 00110110
                         0x3E, 0x08 # A 00111110
    ])
    reg = @cpu.reg
    8.times { @cpu.run_step }
    assert_equal(0x0010, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x08, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x01, reg.b)
    assert_equal(0x02, reg.c)
    assert_equal(0x03, reg.d)
    assert_equal(0x04, reg.e)
    assert_equal(0x05, reg.h)
    assert_equal(0x06, reg.l)
    assert_equal(0x07, @memory.read(0x0506))
  end

  # TODO test other register
  def test_dcr_b
    @memory.set(0x0000, [0x05])
    reg = @cpu.reg
    reg.b = 0x12
    @cpu.run_step
    assert_equal(0x0001, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x11, reg.b)
    assert_equal(0x00, reg.c)
    assert_equal(0x0000, reg.de)
    assert_equal(0x0000, reg.hl)

    reg.pc = 0x0000
    reg.b = 0x01
    @cpu.run_step
    assert_equal(0x00, reg.b)
    # TODO check other flags
    assert_equal(1, reg.flag.z)

    reg.pc = 0x0000
    reg.b = 0x00
    @cpu.run_step
    # TODO check other flags
    assert_equal(0xFF, reg.b)
    assert_equal(0, reg.flag.z)
  end

  # def test_ani
  #   @memory.set([0xE5, 0x0F])
  #   @cpu.reg_a = 0x3A
  #   regs0 = @cpu.regs
  #   @cpu.run_step
  #   regs1 = @cpu.regs
  #   assert_equal(0x0002, regs1.pc)
  #   assert_equal(regs0.sp, regs1.sp)
  #   assert_equal(0x0A, regs1.a)
  #   assert_equal(regs0.flag, regs1.flag)
  #   assert_equal(regs0.b, regs1.b)
  #   assert_equal(regs0.c, regs1.c)
  #   assert_equal(regs0.d, regs1.d)
  #   assert_equal(regs0.e, regs1.e)
  #   assert_equal(regs0.h, regs1.h)
  #   assert_equal(regs0.l, regs1.l)
  # end

  def test_jmp
    @memory.set(0x0000, [0xC3, 0x34, 0x12])
    reg = @cpu.reg
    @cpu.run_step
    assert_equal(0x1234, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x0000, reg.hl)
  end

  def test_jnz
    @memory.set(0x0000, [0xC2, 0x34, 0x12])
    reg = @cpu.reg
    @cpu.run_step
    assert_equal(0x1234, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x0000, reg.hl)

    reg.pc = 0x0000
    reg.flag.z = 1
    @cpu.run_step
    assert_equal(0x0003, reg.pc)
  end

  def test_nop
    @memory.set(0x0000, [0x00])
    reg = @cpu.reg
    @cpu.run_step
    assert_equal(0x0001, reg.pc)
    assert_equal(0x0000, reg.sp)
    assert_equal(0x00, reg.a)
    assert_equal(0b00000010, reg.flag.value)
    assert_equal(0x0000, reg.bc)
    assert_equal(0x0000, reg.de)
    assert_equal(0x0000, reg.hl)
  end
end