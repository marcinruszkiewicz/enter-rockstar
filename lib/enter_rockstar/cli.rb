# frozen_string_literal: true

require 'thor'
require_relative 'version'

module EnterRockstar
  # command line interface for enter-rockstar command
  class CLI < Thor
    package_name "Enter-Rockstar v#{EnterRockstar::VERSION}"

    desc 'scrape_category CATEGORY_NAME URL', 'scrape lyrics wikia category page for bands and albums'
    def scrape_category(category_name, url)
      scraper = EnterRockstar::Scraper::Wikia.new(category_name: category_name, url: url)
      scraper.parse_category(test_limit: true)
      scraper.save_category
      say
    end

    desc 'scrape_lyrics CATEGORY_NAME START_INDEX', 'scrape actual lyrics from the lyrics wikia using the generated json file'
    def scrape_lyrics(category_name, start_index=0)
      scraper = EnterRockstar::Scraper::Wikia.new(category_name: category_name)
      scraper.load_saved_json
      scraper.parse_all_pages(start_index: start_index)
    end

    desc 'print_indexed_tree CATEGORY_NAME', 'print tree with indexes'
    def print_indexed_tree(category_name)
      scraper = EnterRockstar::Scraper::Wikia.new(category_name: category_name)
      scraper.load_saved_json
      scraper.print_indexed_tree
    end

    desc 'tokenize DATA_DIR', 'take the downloaded lyrics text files and tokenize them'
    def tokenize(data_dir)
      tokenizer = EnterRockstar::Corpus::Tokenizer.new(data_dir: data_dir)
      tokenizer.tokenize
    end

    desc 'poetic NUMBER', 'generate a poetic representation of a number from the word base'
    def poetic(number)
      generator = EnterRockstar::Generator::Poetic.new
      results = generator.number(123)

      say results
    end
  end
end
