class Caltrain
  TIMES_PATH = 'data/google_transit/stop_times.txt'
  TRIPS_PATH = 'data/google_transit/trips.txt'

  class << self
    def upcoming_departures(loc, dir)
      times(loc, dir).select { |time| time > now }.sort
    end

    def next_departure(loc, dir)
      times(loc, dir).find { |time| time > now }
    end

    def times(loc, dir)
      @times ||= times_for_location(loc).select { |line| trip_ids_for_direction(dir).include?(line[0]) }.map {|i| i[1]}.sort
    end

    def trip_ids_for_direction(dir)
      @trip_ids_for_direction ||= trips_for_time_of_week.select {|trip| trip[4] == (dir == :north ? '0' : '1') }.map(&:first)
    end

    def trips_for_time_of_week
      @trips_for_time_of_week ||= all_trips.select { |trip| trip[2] =~ (weekend? ? /^WE/ : /^WD/) }
    end

    def times_for_location(loc)
      @times_for_location ||= all_times.select { |arr| arr[3] =~ /^#{abbrevs[loc]}/ }
    end

    def all_times
      @all_times ||= File.read(TIMES_PATH).split(/[\n\r]+/)[1..-1].map { |line| line.gsub('"', '').split(/,+/) }
    end

    def all_trips
      @all_trips ||= File.read(TRIPS_PATH).split(/[\n\r]+/)[1..-1].map { |line| line.gsub('"', '').split(/,+/) }.sort
    end

    def weekend?
      @weekend ||= (Time.now.saturday? || Time.now.sunday?)
    end

    def now
      @now ||= Time.now.strftime('%H:%M:%S')
    end

    def abbrevs
      {
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
      { :list => :upcoming_departures, :next => :next_departure }
    end

    def clean!
      instance_variables.each { |i| instance_variable_set(i, nil) }
      true
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
