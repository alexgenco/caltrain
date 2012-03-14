describe Trip do
  before do
    @trip_data = ['207_20110701','ct_limited_20110701','WD_20110701','San Francisco (Train 207)','0','cal_tam_sf']
    @trip = Trip.new_from_data(@trip_data)
  end

  after { Caltrain.clean! }

  describe '#new_from_data' do
    it 'should extract data from an array' do
      @trip.trip_id.must_equal('207_20110701')
      @trip.route_id.must_equal('ct_limited_20110701')
      @trip.service_id.must_equal('WD_20110701')
      @trip.headsign.must_equal('San Francisco (Train 207)')
      @trip.direction.must_equal(:north)
      @trip.shape_id.must_equal('cal_tam_sf')
    end
  end

  it 'should extract time data' do
    @trip.times.must_include('06:12:00')
  end

  it 'should have a train number' do
    @trip.train_no.must_equal(207)
  end

  it 'should have a type' do
    @trip.type.must_equal('limited')
  end

  describe 'class methods' do
    it 'should keep track of trips by direction' do
      south_data = ['284_20110701','ct_limited_20110701','WD_20110701','San Jose (Train 284)','1','cal_sf_sj']
      south_trip = Trip.new_from_data(south_data)

      Trip.trips(:north).must_equal([@trip])
      Trip.trips(:south).must_equal([south_trip])
      Trip.trips.must_equal([@trip, south_trip])
    end

    it 'should keep track of trips depending on time of week' do
      we_data = ['436_20110701','ct_local_20110701','WE_20110701','San Jose (Train 436)','1','cal_sf_sj']
      we_trip = Trip.new_from_data(we_data)
      sat_data = ['451_20110701','ct_local_20110701','ST_20110701','San Francisco (Train 451)','0','cal_sj_sf']
      sat_trip = Trip.new_from_data(sat_data)

      Trip.weekend.must_equal([we_trip])
      Trip.weekday.must_equal([@trip])
      Trip.saturday_only.must_equal([sat_trip])
    end

    it 'should have trips for today' do
      Timecop.freeze(2012, 3, 11, 9, 30, 0) do
        we_data = ['436_20110701','ct_local_20110701','WE_20110701','San Jose (Train 436)','1','cal_sf_sj']
        we_trip = Trip.new_from_data(we_data)

        Trip.today.must_equal([we_trip])
      end
    end

    it 'should have the time at a given location' do
      @trip.time_at_location(:mv).must_equal('06:23:00')
    end

    it 'should give nil for the last stop' do
      @trip.time_at_location(:sf).must_be_nil
    end

    it 'should have stops' do
      stops = [:tam, :sj, :sc, :law, :sv, :mv, :sa, :cal, :pa, :men, :rc, :hil, :mil, :ssf, :sf]
      @trip.stops.must_equal(stops)
    end
  end
end
