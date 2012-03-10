describe Trip do
  before do
    @trip_data = ['207_20110701','ct_limited_20110701','WD_20110701','San Francisco (Train 207)','0','cal_tam_sf']
    @trip = Trip.new_from_data(@trip_data)
  end

  after { Trip.clean! }

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

  describe 'class methods' do
    it 'should keep track of trips by direction' do
      other_data = @trip_data.dup
      other_data[4] = '1'
      strip = Trip.new_from_data(other_data)

      Trip.trips(:north).must_equal([@trip])
      Trip.trips(:south).must_equal([strip])
      Trip.trips.must_equal([@trip, strip])
    end
  end
end
