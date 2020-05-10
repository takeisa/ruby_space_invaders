# frozen_string_literal: true

module Instruction
  INSTRUCTION_DEFS = [
    [:call,    '11001101', 3], # CD #
    [:ret,     '11001001', 1], # CD #
    [:lxi_d,   '00010001', 3], # LD DE,#
    [:lxi_h,   '00100001', 3], # LD HL,#
    [:lxi_sp,  '00110001', 3], # LD SP,#
    [:ldax_d,  '00011010', 1], # LD A,(DE)
    [:inx_d,   '00010011', 1], # INC DE
    [:inx_h,   '00100011', 1], # INC HL
    [:mov,     '01DDDSSS', 1], # LD REG,REG / LD (HL),REG / LD REG,(HL)
    [:hlt,     '01110110', 1], # HLT
    [:mvi,     '00DDD110', 2], # LD REG,# / LD (HL),#
    [:dcr,     '00DDD101', 1], # JP
    [:jmp,     '11000011', 3], # JP
    [:jnz,     '11000010', 3], # JP
    [:nop,     '00000000', 1]  # NOP
  ].freeze

  REG_NAMES = %w[B C D E H L (HL) A]

  def reg_m
    mem_read(@reg.hl)
  end

  def reg_m=(data)
    mem_write(@reg.hl, data)
  end

  def undefined(code)
    raise format('Undefined code: PC=%04X CODE=%02X', reg.pc, code)
  end

  def call(code)
    addr = fetch16(1)
    reg.inc_pc(3)
    pc = reg.pc
    pc_low = pc[0..7]
    pc_high = pc[8..15]
    sp = reg.sp
    mem_write(sp - 1, pc_high)
    mem_write(sp - 2, pc_low)
    reg.sp = sp - 2
    reg.pc = addr
    context.mnemonic = 'CALL $%04X' % addr
  end

  def ret(code)
    sp = reg.sp
    pc_low = mem_read(sp)
    pc_high = mem_read(sp + 1)
    reg.sp = sp + 2
    reg.pc = (pc_high << 8) + pc_low
  end

  def lxi_d(code)
    data = fetch16(1)
    reg.de = data
    reg.inc_pc(3)
    context.mnemonic = 'LD DE,$%04X' % data
  end

  def lxi_h(code)
    data = fetch16(1)
    reg.hl = data
    reg.inc_pc(3)
    context.mnemonic = 'LD HL,$%04X' % data
  end

  def lxi_sp(code)
    addr = fetch16(1)
    reg.sp = addr
    reg.inc_pc(3)
    context.mnemonic = 'LD SP,$%04X' % addr
  end

  def ldax_d(code)
    data = mem_read(reg.de)
    reg.a = data
    reg.inc_pc(1)
    context.mnemonic = 'LD A,(DE)'
  end

  def inx_d(code)
    reg.de = (reg.de + 1) & 0xFFFF
    reg.inc_pc(1)
    context.mnemonic = 'INC DE'
  end

  def inx_h(code)
    reg.hl = (reg.hl + 1) & 0xFFFF
    reg.inc_pc(1)
    context.mnemonic = 'INC HL'
  end

  def mov(code)
    dst = code[3..5]
    src = code[0..2]
    data = reg.get(src)
    reg.set(dst, data)
    reg.inc_pc(1)
    context.mnemonic = 'LD %s,%s' % [REG_NAMES[dst], REG_NAMES[src]]
  end

  def hlt(code)
    self.halt = true
    reg.inc_pc(1)
    context.mnemonic = 'HLT'
  end

  def mvi(code)
    data = fetch(1)
    reg_cd = code[3..5]
    reg.set(reg_cd, data)
    reg.inc_pc(2)
    context.mnemonic = 'LD %s,$%02X' % [REG_NAMES[reg_cd], data]
  end

  def dcr(code)
    reg_cd = code[3..5]
    # TODO refactoring
    add(reg_cd, -1)
    reg.inc_pc(1)
    context.mnemonic = 'DEC %s' % REG_NAMES[reg_cd]
  end

  def jmp(code)
    addr = fetch16(1)
    reg.pc = addr
    context.mnemonic = 'JP $%04X' % addr
  end

  def jnz(code)
    addr = fetch16(1)
    if reg.flag.z.zero?
      reg.pc = addr
    else
      reg.inc_pc(3)
    end
    context.mnemonic = 'JP NZ,$%04X' % addr
  end

  def nop(code)
    reg.inc_pc
    context.mnemonic = 'NOP'
    # Do nothing
  end

  # module methods

  def count_alpha(pattern)
    pattern.gsub(/[01]/, '').size
  end

  def embed_digits(pattern, digits)
    s = pattern
    digits.each_char do |c|
      s = s.sub(/[A-Z]/, c)
    end
    s
  end

  def to_code_array(pattern)
    alpha_count = count_alpha(pattern)
    return [pattern.to_i(2)] if alpha_count.zero?

    code_array = 0.upto(2 ** alpha_count - 1).map do |n|
      digits = format('%0*b', alpha_count, n)
      embed = embed_digits(pattern, digits)
      embed.to_i(2)
    end

    code_array
  end

  def create_instructions
    table = Array.new(256, [:undefined, 1, method(:undefined)])
    INSTRUCTION_DEFS.map do |mnemonic, pattern, length|
      code_array = to_code_array(pattern)
      code_array.each do |code|
        # raise "Definitions are duplicated: " +
        #           "DATA=#{format('%2X', d)}" +
        #           "MNEMONIC=#{mnemonic} " if MNEMONIC_TABLE[d]
        instruction_method = method(mnemonic)
        table[code] = [mnemonic, length, instruction_method]
      end
    end
    table
  end

  # for debug
  def print_instructions(instructions)
    instructions.each_with_index do |mnemonic, index|
      puts "#{format('%2X %08b', index, index)} #{mnemonic}"
    end
  end
end

# for debug
# Instruction::print_instructions