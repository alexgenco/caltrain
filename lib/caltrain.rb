require 'core_ext'

module Caltrain
  require 'caltrain/data_parser'
  require 'caltrain/trip'
  require 'caltrain/printing'
  require 'caltrain/schedule'

  class << self
    include Printing

    def base_dir
      File.expand_path('..', File.dirname(__FILE__))
    end

    def usage
      puts "Usage:"
      puts "  caltrain <location> <direction> [ list | next ]"
      puts ""
      puts "Abbreviations:"
      pretty_hash(Schedule.abbrevs)
      exit(1)
    end

    def clean!
      [self, Trip].each do |klass|
        klass.instance_variables.each { |i| klass.instance_variable_set(i, nil) }
      end
      true
    end

    def run!(args)
      loc, dir, act = *args
      usage unless loc && dir
      loc = loc.to_sym
      act = :next unless act

      populate_trips!

      if dir =~ /^n/i
        Schedule.method(act).call(loc, :north)
      elsif dir =~ /^s/i
        Schedule.method(act).call(loc, :south)
      else
        raise("#{dir} is not a recognized direction")
      end
    rescue => e
      puts "Error: #{e}"
    end

    private

    def populate_trips!
      DataParser.parse(Trip.trips_path).each { |args| Trip.new_from_data(args) }
    end
  end
end
