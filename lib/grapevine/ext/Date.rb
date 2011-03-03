class Date
  # Parses a human readable period of time into seconds.
  #
  # @param [String] period  the time period to parse.
  #
  # @return [Fixnum]  the amount of time in the period, in seconds.
  def self.parse_time_period(period)
    return nil if period.nil?

    m, num, type = *period.match(/^(\d+)(s|m|h|d|w|M|y|)$/)
    
    return nil if m.nil?
    
    multiplier =
      case type
      when 's'
        1
      when 'm'
        60
      when 'h'
        3600
      when 'd'
        86_400
      when 'w'
        604_800
      when 'M'
        2_592_000
      when 'y'
        31_536_000
      end
    
    return num.to_i * multiplier
  end
end