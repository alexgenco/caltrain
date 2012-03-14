describe 'core extensions' do
  describe 'Array#map_nth' do
    it 'returns the nth element of each array in a 2d array' do
      [[1,2,3],[4,5,6],[7,8,9]].map_nth(2).must_equal([3,6,9])
    end
  end

  describe 'Array#sort_by_nth' do
    it 'sorts 2d array by the nth element of each sub-array' do
      sorted = [[1,1,1],[1,2,3],[1,3,2]]
      [[1,2,3],[1,3,2],[1,1,1]].sort_by_nth(1).must_equal(sorted)
    end
  end
end
