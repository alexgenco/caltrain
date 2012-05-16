class Trip
  attr_reader :trip_id, :route_id, :service_id, :headsign, :direction, :shape_id

  class << self
    def trips_path
      "#{Caltrain.base_dir}/data/google_transit/trips.txt"
    end

    def data
      DataParser.parse(trips_path)
    end

    def new_from_data(data)
      new(*data)
    end

    def trips(dir=nil)
      @trips ||= []
      [:north, :south].include?(dir) ? @trips.select { |trip| trip.direction == dir } : @trips
    end

    def weekend(dir=nil)
      trips(dir).select { |trip| trip.service_id =~ /^WE/ }
    end

    def weekday(dir=nil)
      trips(dir).select { |trip| trip.service_id =~ /^WD/ }
    end

    def saturday_only(dir=nil)
      trips(dir).select { |trip| trip.service_id =~ /^ST/ }
    end

    def today(dir=nil)
      if Schedule.saturday?
        weekend(dir) + saturday_only(dir)
      elsif Schedule.weekend?
        weekend(dir)
      else
        weekday(dir)
      end
    end

    def <<(trip)
      @trips << trip unless trips.map(&:trip_id).include?(trip.trip_id)
    end
  end

  def initialize(*data)
    @trip_id = data[0]
    @route_id = data[1]
    @service_id = data[2]
    @headsign = data[3]
    @direction = data[4] == '0' ? :north : :south
    @shape_id = data[5]

    Trip << self
  end

  def train_no
    @trip_id =~ /^(\d+)_.+$/; $1.to_i
  end

  def type
    @route_id =~ /^ct_(\w+)_\d+/; $1
  end

  def time_data
    @time_data ||= Schedule.data.select { |row| row[0] == @trip_id }
  end

  def times
    @times ||= time_data.map_nth(1)
  end

  def time_at_location(loc)
    return nil if loc == stops.last
    loc_str = Schedule.abbrevs[loc]
    time_data.find { |row| row[3] =~ /^#{loc_str}/ }[1] rescue nil
  end

  def stops(dir=@direction)
    @stops ||= Schedule.stop_order.select { |stop| time_data.map_nth(3).any? { |d| d =~ /^#{Schedule.abbrevs[stop]}/ }  }
    dir == :north ? @stops : @stops.reverse
  end
end
