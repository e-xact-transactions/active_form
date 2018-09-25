require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

plugin_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(plugin_root, 'lib/array_type')

class ArrayTypeTest < MiniTest::Test

  def test_casts_array
    array_type = ArrayType.new
    assert_equal [], array_type.cast([])
    assert_equal [1,2,3], array_type.cast([1,2,3])
    assert_equal %w(abc def ghi), array_type.cast(%w(abc def ghi))
  end

  def test_casts_string
    array_type = ArrayType.new
    assert_equal [], array_type.cast("")
    assert_equal %w(1 2 3), array_type.cast("1,2,3")
    assert_equal %w(abc def ghi), array_type.cast("abc,def,ghi")
  end

end
