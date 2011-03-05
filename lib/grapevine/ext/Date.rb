class Date
  # Parses a human readable period of time into seconds.
  #
  # @param [String] period  the time period to parse.
  #
  # @return [Fixnum]  the amount of time in the period, in seconds.
  def self.parse_time_period(period)
    return nil if period.nil? || period == ''

    # Extract from format: _y_M_w_d_h_m_s
    match, years, months, weeks, days, hours, mins, secs =
      *period.match(/^(\d+y)?(\d+M)?(\d+w)?(\d+d)?(\d+h)?(\d+m)?(\d+s)?$/)
    
    # Return nil if in invalid format
    return nil if match.nil?
    
    # Sum all time parts
    num = 0
    num += years.to_i * 31_536_000
    num += months.to_i * 2_592_000
    num += weeks.to_i * 604_800
    num += days.to_i * 86_400
    num += hours.to_i * 3600
    num += mins.to_i * 60
    num += secs.to_i
    
    return num
  end
end