# frozen_string_literal: true

module EnterRockstar
  class Utils
    def self.load_json(file)
      if File.exist?(file) && file.end_with?('.gz')
        data = Zlib::GzipReader.new(StringIO.new(IO.read(file))).read
      elsif File.exist? file.sub('.gz', '')
        data = IO.read(file.sub('.gz', ''))
      else
        raise IOError, "File not found: #{file}"
      end

      data
    end
  end
end
