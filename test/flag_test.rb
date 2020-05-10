require 'minitest/autorun'
require 'flag'

class FlagTest < MiniTest::Unit::TestCase
  def setup
    @flag = Flag.new
  end

  def teardown
    # Do nothing
  end

  def test_s
    @flag.s = 1
    assert_equal(@flag.s, 1)
    @flag.s = 0
    assert_equal(@flag.s, 0)
  end

  def test_z
    @flag.z = 1
    assert_equal(@flag.z, 1)
    @flag.z = 0
    assert_equal(@flag.z, 0)
  end

  def test_ac
    @flag.ac = 1
    assert_equal(@flag.ac, 1)
    @flag.ac = 0
    assert_equal(@flag.ac, 0)
  end

  def test_p
    @flag.p = 1
    assert_equal(@flag.p, 1)
    @flag.p = 0
    assert_equal(@flag.p, 0)
  end

  def test_c
    @flag.c = 1
    assert_equal(@flag.c, 1)
    @flag.c = 0
    assert_equal(@flag.c, 0)
  end

  def test_value
    @flag.s = 1
    assert_equal(0b10000010, @flag.value)
    @flag.z = 1
    assert_equal(0b11000010, @flag.value)
    @flag.ac = 1
    assert_equal(0b11010010, @flag.value)
    @flag.p = 1
    assert_equal(0b11010110, @flag.value)
    @flag.c = 1
    assert_equal(0b11010111, @flag.value)
  end
end