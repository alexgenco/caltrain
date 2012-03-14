describe Caltrain do
  it 'has a base directory' do
    Caltrain.base_dir.must_equal(File.expand_path('..', File.dirname(__FILE__)))
  end
end
