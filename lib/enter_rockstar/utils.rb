# frozen_string_literal: true

require 'zlib'

module EnterRockstar
  # shared utility code for different modules
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

    def self.save_file(filename, contents)
      File.open(filename, 'w') do |f|
        gz = Zlib::GzipWriter.new(f)
        gz.write contents
        gz.close
      end
      puts "Saved as #{filename}"
    end
  end
end
