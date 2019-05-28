# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'

module EnterRockstar
  module Scraper
    # lyrics scraper for lyrics.wikia.com
    class Wikia
      START_HOST = 'http://lyrics.wikia.com'
      DATA_DIR = 'lyrics'
      SLEEP_BETWEEN_REQUESTS = 0.1

      attr_reader :tree, :url, :category_name, :output

      def initialize(category_name: 'heavy_metal', url: '/wiki/Category:Genre/Heavy_Metal', data_dir: 'lyrics_data')
        @tree = {}
        @output = "#{data_dir}/wikia_#{category_name}.json.gz"
        @url = url
        @category_name = category_name
      end

      def parse_category(url: nil, test_limit: false)
        url ||= START_HOST + @url
        html = URI.parse(url).open
        doc = Nokogiri::HTML(html)

        # get all category member links and sort them by band and album
        doc.css('li.category-page__member a').each do |category_link|
          next if category_link.attr('title').include?('Category:')

          band, album = category_link.attr('title').split(':')
          @tree[band] ||= {}

          if album.nil?
            @tree[band]['band_url'] = category_link.attr('href')
          else
            @tree[band][album] = category_link.attr('href')
          end
        end

        return if test_limit # test only first page scraping so it's easier

        print '.'
        # get next page if one exists and parse that
        next_url = doc.css('a.category-page__pagination-next')&.first&.attr('href')
        parse_category(url: next_url) unless next_url.nil?
      end

      def save_category
        EnterRockstar::Utils.save_file(@output, @tree.to_json)
      end

      def load_saved_json
        @tree = JSON.parse(EnterRockstar::Utils.load_json(@output))
      end

      def print_indexed_tree
        @tree.each_with_index do |(key, _val), index|
          puts "#{index}: #{key}"
        end
      end

      def parse_all_pages(start_index: 0)
        @tree.each_with_index do |(key, val), index|
          next if index < start_index

          puts "#{index}: #{key}"

          val.each do |k, v|
            dirname = k == 'band_url' ? [DATA_DIR, @category_name, key].join('/') : [DATA_DIR, @category_name, key, k].join('/')
            FileUtils.mkdir_p dirname

            parse_page(v, dirname)
          end
        end
      end

      def parse_page(url, dirname)
        sleep SLEEP_BETWEEN_REQUESTS
        html = URI.parse(START_HOST + url).open
        doc = Nokogiri::HTML(html)

        if doc.css('h2 span.mw-headline a').count.zero?
          # single album page listed on the category
          doc.css('div.mw-content-text ol li a').each do |song|
            next unless song&.attr('href')

            lyrics = parse_song(song.attr('href'), dirname, song.text)
            save_song("#{dirname}/#{song.text}.txt", lyrics) unless lyrics.nil?
          end
          puts
        else
          doc.css('h2 span.mw-headline a').each do |album|
            puts album.text
            # some band pages have extra albums that are not listed in the category page for some reason
            album_dirname = [dirname, album.text].join('/')
            FileUtils.mkdir_p album_dirname

            # get song pages
            album.parent.parent.css('+ div + ol > li a').each do |song|
              next unless song&.attr('href')

              lyrics = parse_song(song.attr('href'), album_dirname, song.text)
              save_song("#{album_dirname}/#{song.text}.txt", lyrics) unless lyrics.nil?
            end
            puts
          end
        end
      end

      def parse_song(url, dirname, songname)
        return if url.start_with? 'http'

        songfile = "#{dirname}/#{songname}.txt"
        without_last = songfile.split('/')
        without_last.pop
        FileUtils.mkdir_p without_last.join('/')
        return if File.exist?(songfile)

        print '.'
        sleep SLEEP_BETWEEN_REQUESTS
        html = URI.parse(START_HOST + url).open
        doc = Nokogiri::HTML(html)

        lyrics = doc.css('div.lyricbox').first
        return if lyrics.nil?
        return if lyrics.css('a')&.first&.attr('href') == '/wiki/Category:Instrumental'

        lyrics.inner_html.split('<br>').join("\n").gsub(%r{<\/?[^>]*>}, '')
      end

      def save_song(songfile, contents)
        EnterRockstar::Utils.save_plain(songfile, contents)
      end
    end
  end
end
