require 'active_model'
require 'active_model/type'

require_relative 'array_type'
require_relative 'hash_type'

class ActiveForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Serializers::JSON

  # All types currently specified as part of ActiveForms in RPM code:
  # :hash, :array, :datetime, :float, :decimal, :boolean, :date, :integer, :string
  ActiveModel::Type.register(:array, ArrayType)
  ActiveModel::Type.register(:hash, HashType)
  ActiveModel::Type.register(:double, ActiveModel::Type::Float)

  cattr_accessor :attr_types

  def self.field_accessor(name, sql_type = nil, default = nil, null = true)
    attr_types[name.to_s] = sql_type ? ActiveModel::Type.lookup(sql_type) : sql_type
    attr_reader name
    define_method "#{name}=" do |v|
      raw_values[name.to_s] = v # so we can do before_type_cast
      instance_variable_set("@#{name}", typecasted(name, v))
    end
  end

  def self.attr_types
    @attr_types ||= {}
  end
  def self.attr_names
    attr_types.keys
  end

  # TODO: get rid of this "missing attributes" bit
  def initialize(new_attributes = {}, ignore_missing_attributes = false)
    super(new_attributes)
  end

  def attr_names
    self.class.attr_names
  end

  # ensure we ignore missing attributes
  def _assign_attribute(k, v)
    public_send("#{k}=", v) if respond_to?("#{k}=")
  end

  # required to allow serialization
  def attributes
    self.class.attr_types.inject({}) do |a,(k,v)|
      a[k.to_s] = nil
      a
    end
  end
  def attributes=(hash)
    _assign_attributes(hash)
  end

  # Implement _before_type_cast accessors
  # Raw values are only recorded for attributes defined via 'field_accessor', so
  # jsut return the set value for other attrs.
  def method_missing(method_id, *params)
    if md = /_before_type_cast$/.match(method_id.to_s)
      attr_name = md.pre_match
      return raw_values[attr_name] || self.send(attr_name) if self.respond_to?(attr_name)
    end
    super
  end

  private
  def raw_values
    @raw_values ||= {}
  end
  def typecasted(attr_name, value)
    type = self.class.attr_types[attr_name.to_s]
    type.nil? ? value : type.cast(value)
  end
end