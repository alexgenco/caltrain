class Trip
  attr_reader :trip_id, :route_id, :service_id, :headsign, :direction, :shape_id

  class << self
    def new_from_data(data)
      new(*data)
    end

    def trips(dir=nil)
      @trips ||= []
      dir ? @trips.select { |trip| trip.direction == dir } : @trips
    end

    def <<(trip)
      trips << trip
    end

    def clean!
      instance_variables.each { |i| instance_variable_set(i, nil) }
      true
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

  def times
    @times ||= DataParser.parse(Caltrain.times_path).select { |row| row[0] == @trip_id }.map { |i| i[1] }
  end
end
