class Array
  def map_nth(n)
    map { |elem| elem[n] } rescue self
  end

  def sort_by_nth(n)
    sort_by { |elem| elem[n] } rescue self
  end
end
