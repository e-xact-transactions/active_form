require_relative 'zoneless_time'

# Rails will convert DateTimes to the default zone for the app.
# Use this type when you don't want that to happen.
class ZonelessDateTimeType < ActiveModel::Type::DateTime
  include ZonelessTime
end