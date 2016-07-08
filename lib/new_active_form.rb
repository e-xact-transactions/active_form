require 'active_support/inflector'
require 'active_support/core_ext/hash/except'
require 'active_record/type'
require 'active_model'

require_relative 'no_cast_type'
require_relative 'array_type'
require_relative 'hash_type'

class ActiveForm < ActiveRecord::Base
  # include ActiveModel::Validations
  # include ActiveModel::Validations::Callbacks
  # include ActiveModel::Conversion
  # extend  ActiveModel::Naming

  # All types currently specified as part of ActiveForms in RPM code:
  # :hash, :array, :datetime, :float, :decimal, :boolean, :date, :integer, :string
  TYPE_MAPPINGS = Hash.new(NoCastType.new).merge({
      string: ActiveRecord::Type::String.new,
      char: ActiveRecord::Type::String.new,
      text: ActiveRecord::Type::Text.new,
      clob: ActiveRecord::Type::Text.new,
      integer: ActiveRecord::Type::Integer.new,
      int: ActiveRecord::Type::Integer.new,
      decimal: ActiveRecord::Type::Decimal.new,
      float: ActiveRecord::Type::Float.new,
      double: ActiveRecord::Type::Float.new,
      boolean: ActiveRecord::Type::Boolean.new,
      date: ActiveRecord::Type::Date.new,
      time: ActiveRecord::Type::Time.new,
      datetime: ActiveRecord::Type::DateTime.new,
      timestamp: ActiveRecord::Type::DateTime.new,
      binary: ActiveRecord::Type::Binary.new,
      blob: ActiveRecord::Type::Binary.new,
      array: ArrayType.new,
      hash: HashType.new,
    }).with_indifferent_access unless defined?(TYPE_MAPPINGS)

  # cattr_accessor :attr_types

  attr_accessor :extra_attributes

  def self.field_accessor(name, sql_type = nil, default = nil, null = true)
    # (self.attr_types ||= {})[name.to_s] = sql_type
    self.send(:attribute, name, TYPE_MAPPINGS[sql_type], {default: default})
  end

  def to_model; self; end
  def persisted?; false; end
  def to_key; nil; end
  def to_param; nil; end
  def new_record?; true; end
  def id; nil; end

  def initialize(new_attributes = nil, ignore_missing_attributes = false)
    if ignore_missing_attributes
      super(nil)
      # avoid mass-assignment
      new_attributes.except( *extra_attribute_keys(new_attributes) ).each do |key,value|
        self.send("#{key}=", value)
      end
      self.extra_attributes = new_attributes.slice( *extra_attribute_keys(new_attributes) )
    else
      super(new_attributes)
    end
    yield self if block_given?
  end

  def extra_attribute_keys(new_attributes)
    @extra_attribute_keys ||= (new_attributes.keys.map(&:to_s) - attribute_names).map(&:to_sym)
  end
  private :extra_attribute_keys

  # # def attribute_names
  # #   @attribute_names ||= instance_variables.map {|x| x.to_s[1..-1] }.sort
  # # end
  # def persistable_attribute_names
  #   []
  # end

  def self.columns
    @columns ||= add_user_provided_columns([])
  end
  
  def method_missing(method_id, *params)
    # Implement _before_type_cast accessors
    if md = /_before_type_cast$/.match(method_id.to_s)
      attr_name = md.pre_match
      return self[attr_name] if self.respond_to?(attr_name)
    end
    super
  end

  def raise_not_implemented_error(*params)
    self.class.raise_not_implemented_error(params)
  end
  
  alias save raise_not_implemented_error
  alias save! raise_not_implemented_error
  alias update_attribute raise_not_implemented_error
  alias update_attributes raise_not_implemented_error
  alias save valid?
  alias save! raise_not_implemented_error
  alias update_attribute raise_not_implemented_error
  alias update_attributes raise_not_implemented_error
  
  class <<self
    def raise_not_implemented_error(*params)
      raise NotImplementedError
    end
    
    alias create raise_not_implemented_error
    alias create! raise_not_implemented_error
    alias validates_acceptance_of raise_not_implemented_error
    alias validates_uniqueness_of raise_not_implemented_error
    alias validates_associated raise_not_implemented_error
    alias validates_on_create raise_not_implemented_error
    alias validates_on_update raise_not_implemented_error
    alias save_with_validation raise_not_implemented_error
  end
end