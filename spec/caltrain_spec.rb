require 'minitest/autorun'
require 'minitest/pride'
require 'mocha'

require File.expand_path('../lib/caltrain', File.dirname(__FILE__))

describe Caltrain do
  before { Caltrain.stubs(:weekend?).returns(false) }

  after { Caltrain.clean! }

  describe 'trips' do
    it 'should parse trips.txt depending on the day of the week' do
      Caltrain.all_trips.first.must_equal(['101_20110701','ct_local_20110701','WD_20110701','San Francisco (Train 101)','0','cal_sj_sf'])
    end
  end

  describe 'times' do
    it 'should parse stop_times.txt correctly' do
      line = ['280_20110701','18:50:00','18:50:00','Mountain View Caltrain','10']
      Caltrain.all_times.must_include(line)
    end

    it 'should return times for a location' do
      ['16:58:00', '08:13:00', '19:44:00'].each do |time|
        Caltrain.times_for_location(:sv).map {|i| i[1]}.must_include(time)
      end
    end
  end

  describe '#next_departure' do
    it 'should return the next departure for north' do
      Caltrain.stubs(:now).returns('08:05:12')
      Caltrain.next_departure(:sv, :north).must_equal('08:13:00')
    end

    it 'should return the next departure for south' do
      Caltrain.stubs(:now).returns('18:50:00')
      Caltrain.next_departure(:sf, :south).must_equal('18:56:00')
    end
  end

  describe '#upcoming_departures' do
    it 'should return the upcoming trips for north' do
      Caltrain.stubs(:now).returns('08:05:12')
      upcoming1 = Caltrain.upcoming_departures(:sv, :north)
      upcoming1.must_include('08:18:00')
      upcoming1.wont_include('09:55:00')
      upcoming1.wont_include('09:14:00')
    end

    it 'should return upcoming trips for south' do
      Caltrain.stubs(:now).returns('18:30:10')
      upcoming2 = Caltrain.upcoming_departures(:sf, :south)
      upcoming2.must_include('18:33:00')
      upcoming2.wont_include('18:44:00')
      upcoming2.wont_include('18:59:00')
    end
  end

  describe 'weekend versus weekday' do
    it 'should pick weekday times' do
      Caltrain.stubs(:now).returns('09:10:10')

      Caltrain.next_departure(:mv, :north).must_equal('09:29:00')

      upcoming = Caltrain.upcoming_departures(:mv, :north)
      upcoming.must_include('16:37:00')
      upcoming.wont_include('09:19:00')
    end

    it 'should pick weekend times' do
      Caltrain.stubs(:weekend?).returns(true)
      Caltrain.stubs(:now).returns('07:46:15')

      Caltrain.next_departure(:sj, :north).must_equal('08:00:00')

      upcoming = Caltrain.upcoming_departures(:sj, :south)
      upcoming.must_include('12:00:00')
      upcoming.wont_include('07:50:00')
    end
  end

  describe 'excluding last stops' do
    it 'should not include times for last sf stop' do
      Caltrain.stubs(:now).returns('18:58:30')
      Caltrain.next_departure(:sf, :south).must_equal('19:30:00')
    end

    it 'should not include times for last sj stop' do
      Caltrain.stubs(:now).returns('08:12:10')
      Caltrain.next_departure(:sj, :north).must_equal('08:22:00')
    end
  end
end
