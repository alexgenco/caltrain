module Schedule
  class << self
    include Printing

    def times_path
      "#{Caltrain.base_dir}/data/google_transit/stop_times.txt"
    end

    def data
      @data ||= DataParser.parse(times_path)
    end

    def list(loc, dir, output=$stdout, detailed=false)
      trips = trips_with_times(loc, dir).select { |_, time| time > now }
      options = {:output => output, :starting_at => loc, :detailed => detailed}

      trips.each { |trip, time| print_trip(trip, time, options) }
    end

    def next(loc, dir, output=$stdout, detailed=false)
      trip = trips_with_times(loc, dir).find { |_, time| time > now }
      raise("No trips found!") unless trip
      options = {:output => output, :starting_at => loc, :detailed => detailed}

      print_trip(trip.first, trip.last, options)
    end

    def trips_with_times(loc, dir)
      @trips_with_times ||= trips_for_today(dir).map do |trip|
        if time = trip.time_at_location(loc)
          [trip, time]
        end
      end.compact.sort_by_nth(1)
    end

    def trips_for_today(dir)
      if weekend?
        Trip.weekend(dir)
      elsif saturday?
        Trip.saturday_only(dir)
      else
        Trip.weekday(dir)
      end
    end

    def now
      Time.now.strftime('%H:%M:%S')
    end

    def weekend?
      saturday? || sunday?
    end

    def sunday?
      Time.now.strftime("%A") == "Sunday"
    end

    def saturday?
      Time.now.strftime("%A") == "Saturday"
    end

    def abbrevs
      @abbrevs ||= {
        :gil => "Gilroy",
        :smt => "San Martin",
        :mrg => "Morgan Hill",
        :bhl => "Blossom Hill",
        :cap => "Capitol",
        :tam => "Tamien",
        :sj  => "San Jose",
        :clp => "College Park",
        :sc  => "Santa Clara",
        :law => "Lawrence",
        :sv  => "Sunnyvale",
        :mv  => "Mountain View",
        :sa  => "San Antonio",
        :cal => "California Ave",
        :pa  => "Palo Alto",
        :men => "Menlo Park",
        :ath => "Atherton",
        :rc  => "Redwood City",
        :scl => "San Carlos",
        :bel => "Belmont",
        :hil => "Hillsdale",
        :hay => "Hayward Park",
        :sm  => "San Mateo",
        :brl => "Burlingame",
        :bdw => "Broadway",
        :mil => "Millbrae",
        :sb  => "San Bruno",
        :ssf => "So. San Francisco",
        :bsh => "Bayshore",
        :tt  => "22nd Street",
        :sf  => "San Francisco"
      }.freeze
    end

    # for 1.8 support :/
    def stop_order
      @stop_order ||= [
        :gil, :smt, :mrg, :bhl, :cap, :tam, :sj, :clp, :sc, :law, :sv,
        :mv, :sa, :cal, :pa, :men, :ath, :rc, :scl, :bel, :hil, :hay, :sm,
        :brl, :bdw, :mil, :sb, :ssf, :bsh, :tt, :sf
      ].freeze
    end
  end
end
