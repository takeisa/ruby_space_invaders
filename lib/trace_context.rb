class TraceContext
  attr_accessor :enabled
  attr_writer :mnemonic

  def initialize
    @enabled = true
  end

  def reg=(reg)
    return unless enabled

    @reg_text = format('PC=%04X SP=%04X' \
                           ' A=%02X FLAG=%08b' \
                           ' B=%02X C=%02X' \
                           ' D=%02X E=%02X' \
                           ' H=%02X L=%02X',
                       reg.pc, reg.sp,
                       reg.a, reg.flag.value,
                       reg.b, reg.c,
                       reg.d, reg.e,
                       reg.h, reg.l)
  end

  def bytes=(bytes)
    @bytes_text = bytes.map { |b| '%02X' % b }.join(' ')
  end

  def to_s
    @reg_text + (' | %-9s | ' % @bytes_text) + @mnemonic
  end
end