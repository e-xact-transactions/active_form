class ArrayType < ActiveModel::Type::Value

  private
  def cast_value(value)
    return value if value.nil? || value.is_a?(Array)
    return value.to_s.split(",")
  end

end