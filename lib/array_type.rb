class ArrayType < ActiveRecord::Type::Value

  def type_cast(value)
    return value if value.is_a?(Array)
    return value.split(",")
  end

end