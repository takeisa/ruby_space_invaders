class MemoryStub
  def initialize(memory = [])
    @memory = memory
  end

  def read(addr)
    @memory[addr]
  end

  def write(addr, byte)
    @memory[addr] = byte
  end

  def set(addr, bytes)
    bytes.each do |b|
      @memory[addr] = b
      addr = (addr + 1) & 0xFFFF
    end
  end
end

