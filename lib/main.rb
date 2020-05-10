# frozen_string_literal: true

require_relative './cpu'

def load(file_name)
  data = nil
  File.open(file_name) do |f|
    data = f.read(0x10000)
  end
  data.bytes
end

def print_bytes(bytes)
  0.upto(0xff) do |addr|
    puts format('%04X %02X', addr, bytes[addr])
  end
end

class Memory
  def initialize(bytes)
    @bytes = bytes
  end

  def read(addr)
    @bytes[addr]
  end

  def write(addr, byte)
    raise "video memory access!!" if addr >= 0x2400

    @bytes[addr] = byte
  end
end

def main
  bytes = load('../rom/invaders.img')

# for debug
# print_bytes bytes

  memory = Memory.new(bytes)
  cpu = CPU.new(memory: memory)

  cpu.run
end

main
