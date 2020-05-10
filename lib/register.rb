require_relative 'flag'

class Register
  attr_accessor :a
  attr_reader :flag
  attr_accessor :b, :c, :d, :e, :h, :l
  attr_accessor :pc, :sp

  def initialize(memory)
    @memory = memory
    @a = 0
    @flag = Flag.new
    @b = 0
    @c = 0
    @d = 0
    @e = 0
    @h = 0
    @l = 0
    @pc = 0
    @sp = 0
    @set_methods =
      %i[b= c= d= e= h= l= m= a=].map { |sym| method(sym) }.freeze
    @get_methods =
      %i[b c d e h l m a].map { |sym| method(sym) }.freeze
  end

  def bc
    uint16(b, c)
  end

  def bc=(bc)
    @b, @c = uint16_to_uint8_2(bc)
  end

  def de
    uint16(d, e)
  end

  def de=(de)
    @d, @e = uint16_to_uint8_2(de)
  end

  def hl
    uint16(h, l)
  end

  def hl=(hl)
    @h, @l = uint16_to_uint8_2(hl)
  end

  def m
    @memory.read(hl)
  end

  def m=(uint8)
    @memory.write(hl, uint8)
  end

  def set(reg_cd, byte)
    @set_methods[reg_cd].call(byte)
  end

  def get(reg_cd)
    @get_methods[reg_cd].call
  end

  def inc_pc(n = 1)
    @pc = (@pc + n) & 0xFFFF
  end

  private

  def uint16(uint8_high, uint8_low)
    (uint8_high << 8) + uint8_low
  end

  def uint16_to_uint8_2(value)
    [value[8..15], value[0..7]]
  end
end