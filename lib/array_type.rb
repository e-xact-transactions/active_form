class ArrayType < ActiveModel::Type::Value

  def cast(value)
    return value if value.nil? || value.is_a?(Array)
    return value.to_s.split(",")
  end

end