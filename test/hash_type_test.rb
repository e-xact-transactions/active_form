require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

plugin_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(plugin_root, 'lib/hash_type')

class HashTypeTest < Test::Unit::TestCase

  def test_casts_hash
    hash_type = HashType.new
    
    hash = {}
    assert_equal(hash, hash_type.cast(hash))

    hash = {a:1, b:2, c:3}
    assert_equal hash, hash_type.cast(hash)

    hash = {a:"abc", b:"def", c:"ghi"}
    assert_equal hash, hash_type.cast(hash)
  end

  def test_does_not_cast_string
    hash_type = HashType.new
    assert_raises(NotImplementedError) do
      hash_type.cast("")
    end
  end

end
