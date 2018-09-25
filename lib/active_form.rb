require 'active_model'
require 'active_model/type'

require_relative 'array_type'
require_relative 'hash_type'
require_relative 'zoneless_date_time_type'
require_relative 'zoneless_time_type'

class ActiveForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Serializers::JSON

  # All types currently specified as part of ActiveForms in RPM code:
  # :hash, :array, :datetime, :float, :decimal, :boolean, :date, :integer, :string
  ActiveModel::Type.register(:array, ArrayType)
  ActiveModel::Type.register(:hash, HashType)
  ActiveModel::Type.register(:zoneless_datetime, ZonelessDateTimeType)
  ActiveModel::Type.register(:zoneless_time, ZonelessTimeType)
  ActiveModel::Type.register(:double, ActiveModel::Type::Float)

  # cattr_accessor :attr_types, :attr_names

  def self.field_accessor(name, sql_type = nil, default = nil, null = true)
    attr_types[name.to_s] = sql_type ? ActiveModel::Type.lookup(sql_type) : sql_type
    attr_names << name.to_s

    attr_writer name
    define_method name do
      typecasted(name, instance_variable_get("@#{name}"))
    end
  end

  def self.attr_types
    @attr_types ||= {}
  end
  # FixedRecord require ordered names, so do this rather than relying on attr_types.keys
  def self.attr_names
    @attr_names ||= []
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
    self.class.attr_names.inject({}) do |a,k|
      a[k.to_s] = self.send(k)
      a
    end
  end
  def attributes=(hash)
    _assign_attributes(hash)
  end
  
  def read_attribute_before_type_cast(attr_name)
    instance_variable_get("@#{attr_name}")
  end

  # Implement _before_type_cast accessors
  # Raw values are only recorded for attributes defined via 'field_accessor', so
  # jsut return the set value for other attrs.
  def method_missing(method_id, *params)
    # Implement _came_from_user? checks
    # Rails 5.2 will use the typecast value unless the attr came from the user.
    # Since this is for form validation, all attrs are deemed to have come from the user.
    if md = /_came_from_user\?$/.match(method_id.to_s)
      return true
    end
    # Implement attr_name? methods
    if md = /\?$/.match(method_id.to_s)
      attr_name = md.pre_match
      return self.send(attr_name) if self.class.attr_types[attr_name].class == ActiveModel::Type::Boolean
    end
    # Implement _before_type_cast accessors
    if md = /_before_type_cast$/.match(method_id.to_s)
      attr_name = md.pre_match
      return instance_variable_get("@#{attr_name}") if self.respond_to?(attr_name)
    end

    super
  end

  def respond_to?(method_id, include_private_methods=false)
    supported = super
    return supported if supported

    # Implement _came_from_user? checkas
    if md = /_came_from_user\?$/.match(method_id.to_s)
      return true
    end
    # Implement attr_name? methods
    if md = /\?$/.match(method_id.to_s)
      attr_name = md.pre_match
      return self.class.attr_names.include?(attr_name) &&
              self.class.attr_types[attr_name].class == ActiveModel::Type::Boolean
    end
    # Implement _before_type_cast accessors
    if md = /_before_type_cast$/.match(method_id.to_s)
      return self.class.attr_names.include?(md.pre_match)
    end

    false
  end

  private
  def typecasted(attr_name, value)
    type = self.class.attr_types[attr_name.to_s]
    type.nil? ? value : type.cast(value)
  end
end