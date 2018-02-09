module ZonelessTime
  private
  def new_time(year, mon, mday, hour, min, sec, microsec, offset = nil)
    # Treat 0000-00-00 00:00:00 as nil.
    return if year.nil? || (year == 0 && mon == 0 && mday == 0)

    if offset
      time = ::Time.utc(year, mon, mday, hour, min, sec, microsec) rescue nil
      return unless time

      time -= offset
      time
    else
      ::Time.new(year, mon, mday, hour, min, sec, microsec) rescue nil
    end
  end
end