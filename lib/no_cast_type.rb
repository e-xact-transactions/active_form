class NoCastType < ActiveRecord::Type::Value

  def type_cast(value)
    value
  end

end