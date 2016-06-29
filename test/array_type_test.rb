require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

plugin_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(plugin_root, 'lib/array_type')

class ArrayTypeTest < Test::Unit::TestCase

  def test_casts_array
    array_type = ArrayType.new
    assert_equal [], array_type.type_cast([])
    assert_equal [1,2,3], array_type.type_cast([1,2,3])
    assert_equal %w(abc def ghi), array_type.type_cast(%w(abc def ghi))
  end

  def test_casts_string
    array_type = ArrayType.new
    assert_equal [], array_type.type_cast("")
    assert_equal %w(1 2 3), array_type.type_cast("1,2,3")
    assert_equal %w(abc def ghi), array_type.type_cast("abc,def,ghi")
  end

end
