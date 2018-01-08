class HashType < ActiveModel::Type::Value

  def cast(value)
    return value if value.nil? || value.is_a?(Hash)
    raise NotImplementedError.new("Can't type_cast to Hash from #{value.class}")
  end

end