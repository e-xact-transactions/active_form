require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class ValidationTest < MiniTest::Test

  def test_error_messages
    assert_nothing_raised do
      self.class.class_eval %q{
        class ErrorMessagesTest < ActiveForm
          field_accessor :email
          validates_presence_of :email, :message => 'is missing'
        end
      }
    end

    emt = ErrorMessagesTest.new
    refute emt.valid?
    assert_equal "is missing", emt.errors[:email][0]
    assert_equal "Email is missing", emt.errors.full_messages.first
  end

  def test_validates_confirmation_of
    assert_nothing_raised do
      self.class.class_eval %q{
        class ConfirmationOfTest < ActiveForm
          field_accessor :email
          field_accessor :email_confirmation
          validates_confirmation_of :email
        end
      }
    end

    cot = ConfirmationOfTest.new
    assert cot.valid?, cot.errors.full_messages.join(',')
    cot.email_confirmation = cot.email = "someone@example.com"
    assert cot.valid?, cot.errors.full_messages.join(',')
    cot.email_confirmation = "wrong@address.com"
    refute cot.valid?
    refute_nil cot.errors[:email]
  end

  def test_validates_acceptance_of
    assert_nothing_raised do
      self.class.class_eval %q{
        class AcceptanceOfTest < ActiveForm
          field_accessor :terms_of_service, :boolean
          validates_acceptance_of :terms_of_service
        end
      }
    end

    aot = AcceptanceOfTest.new :terms_of_service => true
    assert aot.valid?
  end

  def test_presence_of
    assert_nothing_raised do
      self.class.class_eval %q{
        class PresenceOfTest < ActiveForm
          field_accessor :email
          validates_presence_of :email
        end
      }
    end

    pot = PresenceOfTest.new
    refute pot.valid?
    pot.email = "someone@example.com"
    assert pot.valid?, pot.errors.full_messages.join(',')
  end

  def test_validates_length_of
    assert_nothing_raised do
      self.class.class_eval %q{
        class LengthOfTest < ActiveForm
          field_accessor :name
          validates_length_of :name, :minimum => 3
        end
      }
    end

    lot = LengthOfTest.new
    refute lot.valid?
    lot.name = "Christoph"
    assert lot.valid?, lot.errors.full_messages.join(',')
  end

  def test_validates_format_of
    assert_nothing_raised do
      self.class.class_eval %q{
        class FormatOfTest < ActiveForm
          field_accessor :email
          validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
        end
      }
    end

    fot = FormatOfTest.new
    refute fot.valid?
    fot.email = "abc"
    refute fot.valid?
    fot.email = "c.schiessl@gmx.net"
    assert fot.valid?, fot.errors.full_messages.join(',')
  end

  def test_validates_inclusion_of
    assert_nothing_raised do
      self.class.class_eval %q{
        class InclusionOfTest < ActiveForm
          field_accessor :booltest
          field_accessor :texttest
          validates_inclusion_of :booltest, :in => [true, false]
          validates_inclusion_of :texttest, :in => %w{Joe Mike Jack}
        end
      }
    end

    iot = InclusionOfTest.new
    refute iot.valid?
    iot.booltest, iot.texttest = true, "Jack"
    assert iot.valid?, iot.errors.full_messages.join(',')
  end

  def test_validates_exclusion_of
    assert_nothing_raised do
      self.class.class_eval %q{
        class ExclusionOfTest < ActiveForm
          field_accessor :name
          validates_exclusion_of :name, :in => %w{Bill Gates}
        end
      }
    end

    eot = ExclusionOfTest.new
    assert eot.valid?, eot.errors.full_messages.join(',')
    eot.name = "Bill"
    refute eot.valid?
    eot.name = "Christoph"
    assert eot.valid?, eot.errors.full_messages.join(',')
  end

  def test_validates_associated
    assert_raises(NoMethodError) do
      self.class.class_eval %q{
        class AssociatedTest < ActiveForm
          field_accessor :test
          validates_associated :test
        end
      }
    end
  end

  def test_validates_numericality_of
    assert_nothing_raised do
      self.class.class_eval %q{
        class NumericalityTest < ActiveForm
          field_accessor :width
          field_accessor :height
          field_accessor :amount, :decimal
          validates_numericality_of :width, :height, :amount
        end
      }
    end

    nt = NumericalityTest.new
    refute nt.valid?
    nt.width, nt.height, nt.amount = 123, "123", 1
    assert nt.valid?, nt.errors.full_messages.join(',')
    nt.width = "123sdf"
    refute nt.valid?
    assert_equal "is not a number", nt.errors[:width].first
    nt.width = 123
    nt.amount = "$100"
    refute nt.valid?
    assert_equal "is not a number", nt.errors[:amount].first
  end

  def test_validates_on_create
    assert_raises(NoMethodError) do
      self.class.class_eval %q{
        class OnCreateTest < ActiveForm
          field_accessor :name
          validates_on_create do
            # do something
          end
        end
      }
    end
  end

  def test_validates_on_update
    assert_raises(NoMethodError) do
      self.class.class_eval %q{
        class OnUpdateTest < ActiveForm
          field_accessor :name
          validates_on_update do
            # do something
          end
        end
      }
    end
  end
end
