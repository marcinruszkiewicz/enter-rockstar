# frozen_string_literal: true

require 'zlib'

module EnterRockstar
  module Generator
    # lyrics scraper for lyrics.wikia.com
    class Poetic
      STRATEGIES = {
        'random' => '_random'
      }.freeze

      attr_reader :tokens, :amount, :strategy

      def initialize(data_file:, amount: 5, strategy: 'random')
        @tokens = JSON.parse EnterRockstar::Utils.load_json(data_file)
        @amount = Integer(amount) rescue 5
        @strategy = STRATEGIES[strategy] || '_random'
      end

      def number(num)
        # split the number into parts
        array = num.to_s.split(/\B|\b/)

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
          if digit == '.'
            result << '.'
            next
          end

          # digits less than 4 should use longer words
          digit = digit.to_i < 4 ? (digit.to_i + 10).to_s : digit
          result << @tokens[digit].sample
        end

        result
      end
    end
  end
end
