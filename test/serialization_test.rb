require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class SerializationTest < Test::Unit::TestCase

  class ContactTest < ActiveForm
    field_accessor :name
    field_accessor :phone, :integer
  end

  def test_to_json
    params = {
      :name => "Christoph",
      :phone => "123123123",
    }

    ct = ContactTest.new(params)
    assert_equal %w(name phone), ct.serializable_hash.keys
    assert_equal "{\"name\":\"Christoph\",\"phone\":123123123}", ct.to_json
  end

  def test_from_json
    ct = ContactTest.new
    ct.from_json("{\"name\":\"Christoph\",\"phone\":\"123123123\"}")
    assert_equal "Christoph", ct.name
    assert_equal 123123123, ct.phone
  end

end
