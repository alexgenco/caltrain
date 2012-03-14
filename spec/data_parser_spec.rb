describe DataParser do
  it 'should parse stop_times.txt correctly' do
    line = ['280_20110701','18:50:00','18:50:00','Mountain View Caltrain','10']
    DataParser.parse(Schedule.times_path).must_include(line)
  end

  it 'should parse trips.txt correctly' do
    line = ['207_20110701','ct_limited_20110701','WD_20110701','San Francisco (Train 207)','0','cal_tam_sf']
    DataParser.parse(Trip.trips_path).must_include(line)
  end
end
