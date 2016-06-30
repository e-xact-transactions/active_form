class ArrayType < ActiveRecord::Type::Value

  def type_cast(value)
    return value if value.nil? || value.is_a?(Array)
    return value.to_s.split(",")
  end

end