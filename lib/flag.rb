# フラグレジスタのビット位置
# b7:S 符号
# b6:Z ゼロ
# b5:未使用（0に固定）
# b4:H　AUXキャリー（パックBCD演算用）
# b3:未使用 (0に固定）
# b2:P　パリティ
# b1:未使用 （0に固定）
# b0:C　キャリー
class Flag
  attr_accessor :s, :z, :ac, :p, :c

  def initialize
    @s = 0
    @z = 0
    @ac = 0
    @p = 0
    @c = 0
  end

  def value
    (@s << 7) + (@z << 6) + (@ac << 4) + (@p << 2) + 2 + @c
  end
end