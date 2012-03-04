require 'minitest/autorun'
require 'minitest/pride'
require 'mocha'

require File.expand_path('../lib/caltrain', File.dirname(__FILE__))

describe Caltrain do
  describe 'trips' do
    it 'should parse trips.txt correctly' do
      Caltrain.trips.first.must_equal(['101_20110701','ct_local_20110701','WD_20110701','San Francisco (Train 101)','0','cal_sj_sf'])
    end

    it 'should have north trip ids' do
      ['101_20110701', '189_20110701'].each do |id|
        Caltrain.north_trips.must_include(id)
      end

      ['312_20110701', '274_20110701'].each do |id|
        Caltrain.north_trips.wont_include(id)
      end
    end

    it 'should have south trip ids' do
      ['312_20110701', '274_20110701'].each do |id|
        Caltrain.south_trips.must_include(id)
      end

      ['101_20110701', '189_20110701'].each do |id|
        Caltrain.south_trips.wont_include(id)
      end
    end
  end

  describe 'times' do
    it 'should parse stop_times.txt correctly' do
      line = ["280_20110701","18:50:00","18:50:00","Mountain View Caltrain","10"]
      Caltrain.times.must_include(line)
    end

    it 'should return times for a location' do
      ["20:34:00", "19:14:00", "21:34:00"].each do |time|
        Caltrain.times_for_location(:sv).must_include(time)
      end
    end

    it 'should return times for a direction' do
      ['08:13:00', '08:18:00'].each do |time|
        Caltrain.times_for_direction(:north).must_include(time)
      end

      ['18:56:00', '18:33:00'].each do |time|
        Caltrain.times_for_direction(:south).must_include(time)
      end
    end

    it 'should return times for location and direction' do
      ['08:13:00', '08:18:00'].each do |time|
        Caltrain.times_for_location_and_direction(:sv, :north).must_include(time)
      end

      ['17:17:00', '08:05:00'].each do |time|
        Caltrain.times_for_location_and_direction(:sv, :north).wont_include(time)
      end

      ['18:56:00', '18:33:00'].each do |time|
        Caltrain.times_for_location_and_direction(:sf, :south).must_include(time)
      end

      ['07:11:00', '08:11:00'].each do |time|
        Caltrain.times_for_location_and_direction(:sf, :south).wont_include(time)
      end
    end
  end

  describe '#next_trip' do
    it 'should return the time of the next trip given a location and direction' do
      Caltrain.stubs(:now).returns('08:05:12')
      Caltrain.next_trip(:sv, :north).must_equal('08:13:00')

      Caltrain.stubs(:now).returns('18:50:10')
      Caltrain.next_trip(:sf, :south).must_equal('18:56:00')
    end
  end

  describe '#upcoming_trips' do
    it 'should return the upcoming trips for a location and direction' do
      Caltrain.stubs(:now).returns('08:05:12')
      upcoming1 = Caltrain.upcoming_trips(:sv, :north)
      upcoming1.must_include('08:18:00')
      upcoming1.wont_include('09:55:00')

      Caltrain.stubs(:now).returns('18:30:10')
      upcoming2 = Caltrain.upcoming_trips(:sf, :south)
      upcoming2.must_include('18:33:00')
      upcoming2.wont_include('18:44:00')
    end
  end
end
