class Caltrain
  TIMES_PATH = File.expand_path('../../data/google_transit/stop_times.txt', __FILE__)
  TRIPS_PATH = File.expand_path('../../data/google_transit/trips.txt', __FILE__)

  class << self
    def next_trip(loc, dir)
      times_for_location_and_direction(loc, dir).find { |time| time > now }
    end

    def upcoming_trips(loc, dir)
      times_for_location_and_direction(loc, dir).select { |time| time > now }
    end

    def now
      Time.now.strftime("%H:%M:%S")
    end

    def times_for_location(loc)
      times.select { |line| line[3] =~ /^#{abbrevs[loc]}/ }.map { |i| i[1] }.sort
    end

    def times_for_direction(dir)
      times.select { |line| method(:"#{dir}_trips").call.include?(line[0]) }.map { |i| i[1] }.sort
    end

    def times_for_location_and_direction(loc, dir)
      (times_for_location(loc) & times_for_direction(dir)).sort
    end

    def times
      @times ||= File.read(TIMES_PATH).split(/[\n\r]+/)[1..-1].map { |line| line.gsub('"', '').split(/,+/) }
    end

    def north_trips
      @north_trips ||= trips.select { |arr| arr[4] == "0" }.map { |i| i[0] }
    end

    def south_trips
      @south_trips ||= trips.select { |arr| arr[4] == "1" }.map { |i| i[0] }
    end

    def trips
      @trips ||= File.read(TRIPS_PATH).split(/[\n\r]+/)[1..-1].map { |line| line.gsub('"', '').split(/,+/) }
    end

    def abbrevs
      @abbrevs ||= {
        :tt  => "22nd Street",
        :ath => "Atherton",
        :bsh => "Bayshore",
        :bel => "Belmont",
        :bhl => "Blossom Hill",
        :bdw => "Broadway",
        :brl => "Burlingame",
        :cal => "California Ave",
        :cap => "Capitol",
        :clp => "College Park",
        :gil => "Gilroy",
        :hay => "Hayward Park",
        :hil => "Hillsdale",
        :law => "Lawrence",
        :men => "Menlo Park",
        :mil => "Millbrae",
        :mrg => "Morgan Hill",
        :mv  => "Mountain View",
        :pa  => "Palo Alto",
        :rc  => "Redwood City",
        :sa  => "San Antonio",
        :sb  => "San Bruno",
        :scl => "San Carlos",
        :sf  => "San Francisco",
        :sj  => "San Jose",
        :smt => "San Martin",
        :sm  => "San Mateo",
        :sc  => "Santa Clara",
        :ssf => "So. San Francisco",
        :sv  => "Sunnyvale",
        :tam => "Tamien"
      }
    end

    def pretty_abbrevs
      max_field_width = abbrevs.values.map(&:size).max

      abbrevs.values.zip(abbrevs.keys).each do |name, abr|
        puts "%#{max_field_width}s #{abr}" % name
      end
    end

    def usage
      puts "Usage:"
      puts "  caltrain <action> <location> <direction>"
      puts "  action => [ next | list ]"
      puts ""
      puts "Abbreviations:"
      pretty_abbrevs
      exit(1)
    end

    def actions
      { :list => :upcoming_trips, :next => :next_trip }
    end

    def run!(args)
      begin
        act, loc, dir = *args

        if dir =~ /^n/
          puts method(actions[act.to_sym]).call(loc.to_sym, :north)
        elsif dir =~ /^s/
          puts method(actions[act.to_sym]).call(loc.to_sym, :south)
        else
          raise
        end
      rescue
        usage
      end
    end
  end
end
