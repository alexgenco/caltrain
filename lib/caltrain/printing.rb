module Printing
  def print_trip(trip, time, options={})
    start = options[:starting_at]
    output = options[:output] || $stdout

    output << train_info(trip, time) << "\n"
    output << "  " << stop_info(trip, start) << "\n"
  end

  def train_info(trip, time)
    "#{time} - Train #{trip.train_no} (#{trip.type})"
  end

  def stop_info(trip, start=trip.stops.first)
    string = trip.stops.join(' -> ')
    "*#{string[(string =~ /\b#{start}\b/ || 0)..-1]}"
  end

  def pretty_hash(hash)
    max_field_width = hash.values.map(&:size).max

    hash.each do |key, value|
      puts "%#{max_field_width}s #{key}" % value
    end
  end
end
