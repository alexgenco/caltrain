describe Schedule do
  before do
    trip_data = ['329_20110701','ct_bullet_20110701','WD_20110701','San Francisco (Train 329)','0','cal_tam_sf']
    @trip = Trip.new_from_data(trip_data)
  end

  after { Caltrain.clean! }

  it 'should tell you what day of week it is' do
    Timecop.freeze(2012, 03, 10) do
      Schedule.weekend?.must_equal(true)
      Schedule.saturday?.must_equal(true)
    end
  end

  it 'should have data' do
    line = ['207_20110701','06:39:00','06:39:00','Menlo Park Caltrain','10']
    Schedule.data.must_include(line)
  end
end
