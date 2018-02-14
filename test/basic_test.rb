require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class BasicTest < Test::Unit::TestCase
  include ActiveModel::Lint::Tests

  def model
   return @model if @model
   self.class.class_eval %q{
     class TestForm < ActiveForm
     end
   }
   @model = TestForm.new
  end


  def test_class_loads
    assert_nothing_raised { ActiveForm }
  end

  def test_mass_assignments
    self.class.class_eval %q{
      class ContactTest < ActiveForm
        field_accessor :name
        field_accessor :phone
        field_accessor :email
        field_accessor :subject
        validates_presence_of :name, :phone, :email, :subject
        validates_length_of :name, :phone, :subject, :minimum => 3
        validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
      end
    }

    params = {
      :name => "Christoph",
      :phone => "123123123",
      :email => "c.schiessl@gmx.net",
      :subject => "Test",
    }

    assert_nothing_raised do
      ct = ContactTest.new(params)
      assert_valid ct
    end
  end

  def test_ignores_unknown_attributes
    self.class.class_eval %q{
      class ContactTest < ActiveForm
        field_accessor :name
      end
    }

    params = {
      :name => "Christoph",
      :subject => "Test",
    }

    ct = ContactTest.new(params)
    assert_valid ct
    assert_equal "Christoph", ct.name
    assert ct.respond_to?(:name)
    refute ct.respond_to?(:subject)
  end

  def test_recognises_question_for_boolean_attrs
    self.class.class_eval %q{
      class PersonTest < ActiveForm
        field_accessor :name
        field_accessor :age, :integer
        field_accessor :minor, :boolean
      end
    }

    params = {
      :name => "Christoph",
      :age => 12,
      :minor => true
    }

    pt = PersonTest.new(params)
    assert pt.respond_to?(:name)
    assert pt.respond_to?(:age)
    assert pt.respond_to?(:minor)
    refute pt.respond_to?(:name?)
    refute pt.respond_to?(:age?)
    assert pt.respond_to?(:minor?)
  end

  def test_mass_assignments_with_type_conversion
    self.class.class_eval %q{
      class ContactTest < ActiveForm
        field_accessor :name, :string
        field_accessor :phone, :integer
        field_accessor :email
        field_accessor :admin, :boolean

        attr_accessor :plain
      end
    }

    params = {
      :name => "Christoph",
      :phone => "123123123",
      :email => "c.schiessl@gmx.net",
      :admin => "true",
      :plain => 123
    }

    ct = nil
    assert_nothing_raised do
      ct = ContactTest.new(params)
    end
    assert ct.name.is_a?(String)
    assert ct.phone.is_a?(Integer)
    assert ct.email.is_a?(String) # default is not to typecast
    assert ct.admin.is_a?(TrueClass)
    assert ct.plain.is_a?(Integer) # attrs defined by attr_accessor are not typecast

    assert_equal "123123123", ct.phone_before_type_cast
  end

  def test_stores_before_type_cast_value
    self.class.class_eval %q{
      class ContactTest < ActiveForm
        field_accessor :name, :string
        field_accessor :phone, :integer
        field_accessor :email
        field_accessor :admin, :boolean

        attr_accessor :plain
      end
    }

    params = {
      :name => "Christoph",
      :phone => "123123123",
      :email => "c.schiessl@gmx.net",
      :admin => "true",
      :plain => 123
    }

    ct = ContactTest.new(params)
    assert_equal "Christoph", ct.name_before_type_cast
    assert_equal "123123123", ct.phone_before_type_cast
    assert_equal "c.schiessl@gmx.net", ct.email_before_type_cast
    assert_equal "true", ct.admin_before_type_cast
    assert_equal 123, ct.plain_before_type_cast
  end

  def test_save_and_create_methods
    assert_nothing_raised do
      self.class.class_eval %q{
        class SaveAndCreateTest < ActiveForm
          field_accessor :name
          validates_presence_of :name
        end
      }
    end

    sact = SaveAndCreateTest.new :name => "Christoph"
    assert_raise(NoMethodError) { assert sact.save }
    assert_raise(NoMethodError) { sact.save! }
    assert_raise(NoMethodError) { sact.update_attribute :name, "Chris" }
    assert_raise(NoMethodError) { sact.update_attributes :name => "Chris" }
    assert_raise(NoMethodError) { SaveAndCreateTest.create :name => "Christoph" }
    assert_raise(NoMethodError) { SaveAndCreateTest.create! :name => "Christoph" }
  end

  def test_attributes
    assert_nothing_raised do
      self.class.class_eval %q{
        class AttributesTest < ActiveForm
        end
      }
    end

    at = AttributesTest.new
    assert_raise(NoMethodError) { at.not_defined = "test" }
    assert_raise(NoMethodError) { at[:not_defined] = "test" }
    assert_raise(NoMethodError) { at[:not_defined] }
  end

end
