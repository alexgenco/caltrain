module DataParser
  class << self
    def data
      @data ||= {}
    end

    def parse(file_path)
      data[file_path] ||= File.read(file_path).
      split(/[\n\r]+/)[1..-1].
      map { |line| line.gsub('"', '').
             gsub(/\s+/, ' ').
             split(/,+/) }
    end
  end
end
