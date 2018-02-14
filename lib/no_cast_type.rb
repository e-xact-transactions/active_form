class NoCastType < ActiveRecord::Type::Value

  def cast_value(value)
    value
  end

end