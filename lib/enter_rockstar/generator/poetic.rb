# frozen_string_literal: true

require 'zlib'

module EnterRockstar
  module Generator
    # lyrics scraper for lyrics.wikia.com
    class Poetic

      STRATEGIES = {
        'random' => '_random'
      }

      def initialize(data_file:, amount: 1, strategy: 'random')
        @tokens = JSON.parse(Zlib.gunzip(IO.read(data_file)))
        @amount = amount.to_i
        @strategy = STRATEGIES[strategy]
      end

      def number(num)
        # split the number into parts
        array = num.split(/\B/)

        all_results = []
        @amount.times do
          result = send(@strategy, array)
          all_results.push result.join(' ')
        end

        all_results
      end

      private

      def _random(array)
        result = []
        array.each do |digit|
          # digits less than 4 should use longer words
          digit = digit.to_i < 4 ? (digit.to_i + 10).to_s : digit
          result << @tokens[digit].sample
        end

        result
      end
    end
  end
end
