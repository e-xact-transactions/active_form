require 'active_model'

require_relative 'array_type'
require_relative 'hash_type'

class ActiveForm
  include ActiveModel::Model

  # All types currently specified as part of ActiveForms in RPM code:
  # :hash, :array, :datetime, :float, :decimal, :boolean, :date, :integer, :string
  ActiveModel::Type.register(:array, ArrayType)
  ActiveModel::Type.register(:double, ActiveModel::Type::Float)
  ActiveModel::Type.register(:hash, HashType)

  attr_accessor :extra_attributes

  cattr_accessor :attr_types

  def self.field_accessor(name, sql_type = nil, default = nil, null = true)
    sql_type ||= :string
    attr_types[name.to_s] = ActiveModel::Type.lookup(sql_type)
    attr_accessor name
  end

  def self.attr_types
    @attr_types ||= {}
  end

  def initialize(new_attributes = {}, ignore_missing_attributes = false)
    super(new_attributes)
  end

  def _assign_attribute(k, v)
    if respond_to?("#{k}=")
      type = self.class.attr_types[k.to_s]
      public_send("#{k}=", type.cast(v))
    else
      raise ActiveModel::UnknownAttributeError.new(self, k)
    end
  end

end