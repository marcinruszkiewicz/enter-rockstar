# frozen_string_literal: true

require 'whatlanguage'
require 'ruby-progressbar'

module EnterRockstar
  module Corpus
    # take the downloaded lyrics texts and tokenize them
    class Tokenizer
      def initialize(data_dir:, name:)
        @data_dir = data_dir
        @stats = {}
        @tokens = {}
        @output_stats = "lyrics_data/#{name}_stats.json.gz"
        @output_tokens = "lyrics_data/#{name}_tokens.json.gz"
        @wl = WhatLanguage.new(:all)
      end

      def tokenize
        text_files = Dir.glob("#{@data_dir}/**/*.txt")
        puts "Parsing #{text_files.count} files."
        progressbar = ProgressBar.create(title: 'Progress', total: text_files.count)

        text_files.each do |filename|
          # read the lyrics and tokenize the words
          text = IO.read(filename)

          # Rockstar doesn't really work well with languages other than English
          if @wl.language(text) == :english
            tokenized = _to_tokens(text)
            # save stats which word appears after which one
            n = 3
            tokenized.each_cons(n) do |*head, continuation|
              @stats[head] ||= Hash.new(0)

              @stats[head][continuation] += 1
            end

            # save the words themselves based on what length they are
            tokenized.each do |token|
              next if token.length < 4 # shorter words are boring anyway

              @tokens[token.length] ||= []
              @tokens[token.length].push token unless @tokens[token.length].include? token
            end
            progressbar.increment
          else
            progressbar.increment
            next
          end
        end
        puts
      end

      def save_all
        EnterRockstar::Utils.save_file(@output_tokens, @tokens.to_json)
        EnterRockstar::Utils.save_file(@output_stats, @stats.to_json)
      end

      private

      def _to_tokens(text)
        text.downcase.split(/[^[[:alpha:]]]+/).reject(&:empty?).map(&:to_sym)
      end
    end
  end
end
