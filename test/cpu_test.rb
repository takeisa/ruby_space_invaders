# frozen_string_literal: true

require 'minitest/autorun'

require 'cpu'
require 'instruction'

require 'memory_stub'

class CPUTest < MiniTest::Unit::TestCase
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_memory_write
    memory = Minitest::Mock.new
    cpu = CPU.new(memory: memory)
    memory.expect(:write, nil, [0x1234, 0x12])
    cpu.mem_write(0x1234, 0x12)
    memory.verify
  end

  def test_memory_read
    memory = Minitest::Mock.new
    cpu = CPU.new(memory: memory)
    memory.expect(:read, nil, [0x1234])
    cpu.mem_read(0x1234)
    memory.verify
  end

  def test_fetch16
    memory = MemoryStub.new([0x34, 0x12])
    cpu = CPU.new(memory: memory)
    data = cpu.fetch16
    assert_equal(0x1234, data)
  end

  def test_run_step
    memory = MemoryStub.new([0x00])
    cpu = CPU.new(memory: memory)
    cpu.run_step
    assert_equal(0x0001, cpu.reg.pc)
  end

  # def test_add
  #   cpu = CPU.new(memory: nil)
  #   cpu.reg_b = 0
  #   cpu.add(0b000, 0)
  #   assert_equal(0x00, cpu.reg_b)
  #   assert(cpu.reg_flag_z)
  #
  #   cpu.reg_b = 0
  #   cpu.add(0b000, -1)
  #   assert_equal(0xFF, cpu.reg_b)
  #   assert(!cpu.reg_flag_z)
  #
  #   # TODO test other flags
  # end
end