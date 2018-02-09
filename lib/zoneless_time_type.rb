require_relative 'zoneless_time'

# Rails will convert Times to the default zone for the app.
# Use this type when you don't want that to happen.
class ZonelessTimeType < ActiveModel::Type::Time
  include ZonelessTime
end