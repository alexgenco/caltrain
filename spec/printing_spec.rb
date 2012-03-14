describe Printing do
  include Printing

  before do
    @trip = Trip.new_from_data(['449_20110701','ct_local_20110701','WE_20110701','San Francisco (Train 449)','0','cal_sj_sf'])
  end

  it 'should have train info' do
    train_info(@trip, '10:00:00').must_equal('10:00:00 - Train 449 (local)')
  end

  it 'should have stop info' do
    stop_info(@trip, :sv).must_equal(
      '*sv -> mv -> sa -> cal -> pa -> men -> ath -> rc -> scl -> bel -> hil -> hay -> sm -> brl -> bdw -> mil -> sb -> ssf -> bsh -> tt -> sf'
    )
  end

  it 'should output properly' do
    lambda { print_trip(@trip, '10:00:00', :starting_at => :sv) }.must_output(<<-OUTPUT)
10:00:00 - Train 449 (local)
  *sv -> mv -> sa -> cal -> pa -> men -> ath -> rc -> scl -> bel -> hil -> hay -> sm -> brl -> bdw -> mil -> sb -> ssf -> bsh -> tt -> sf
    OUTPUT
  end
end
