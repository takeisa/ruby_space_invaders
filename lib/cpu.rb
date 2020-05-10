
# frozen_string_literal: true

require_relative './register'
require_relative './instruction'
require_relative './trace_context'

# 8080 CPU
class CPU
  attr_reader :reg, :context

  include Instruction

  def initialize(memory:)
    @memory = memory
    @reg = Register.new(@memory)
    @halt = false
    @instructions = create_instructions
    @context = TraceContext.new
  end

  def halt?
    @halt
  end

  def halt=(enabled)
    @halt = enabled
  end

  def mem_write(addr, data)
    @memory.write(addr, data)
  end

  def mem_read(addr)
    @memory.read(addr)
  end

  def mem_read_bytes(addr, length)
    bytes = []
    length.times do
      bytes.append(mem_read(addr))
      addr = (addr + 1) & 0xFFFF
    end
    bytes
  end

  def run_step
    context.reg = reg
    code = fetch
    mnemonic, length, instruction_method = get_instruction(code)
    context.mnemonic = mnemonic.to_s
    context.bytes = mem_read_bytes(reg.pc, length)
    instruction_method.call(code)
    puts context.to_s
  end

  def run
    run_step until @halt
  end

  def fetch(offset = 0)
    mem_read((reg.pc + offset) & 0xFFFF)
  end

  def fetch16(offset = 0)
    addr = (reg.pc + offset & 0xFFFF)
    low = mem_read(addr)
    high = mem_read((addr + 1) & 0xFFFF)
    (high << 8) + low
  end

  def add(reg_cd, value)
    data = reg.get(reg_cd)
    result = (data + value) & 0xFF
    reg.set(reg_cd, result)
    # TODO set flags
    reg.flag.z = result.zero? ? 1 : 0
    result
  end

  def get_instruction(code)
    @instructions[code]
  end
end