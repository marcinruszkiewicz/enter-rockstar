# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'json'
require 'zlib'

module EnterRockstar
  module Scraper
    # lyrics scraper for lyrics.wikia.com
    class Wikia
      START_HOST = 'http://lyrics.wikia.com'
      DATA_DIR = 'lyrics'
      SLEEP_BETWEEN_REQUESTS = 0.1

      attr_reader :tree

      def initialize(category_name: 'heavy_metal', url: '/wiki/Category:Genre/Heavy_Metal', data_dir: 'lyrics_data')
        @tree = {}
        @output = "#{data_dir}/wikia_#{category_name}.json.gz"
        @url = url
        @category_name = category_name
      end

      def parse_category(url: nil, test_limit: false)
        url ||= START_HOST + @url
        html = URI.open(url)
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
        puts
        out = File.new(@output, 'w')
        out.write Zlib.gzip(@tree.to_json)
        out.close
        puts "Saved JSON data to #{@output}"
      end

      def load_saved_json
        @tree = JSON.parse(load_json)
        @new_tree = JSON.parse(load_json)
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

            parse_page(v, dirname, key)
          end
        end

        @tree = @new_tree
        save_category
      end

      def parse_page(url, dirname, band)
        puts url
        sleep SLEEP_BETWEEN_REQUESTS
        html = URI.open(START_HOST + url)
        doc = Nokogiri::HTML(html)

        if doc.css('h2 span.mw-headline a').count.zero?
          # single album page listed on the category
          doc.css('div.mw-content-text ol li a').each do |song|
            parse_song(song.attr('href'), dirname, song.text) if song&.attr('href')
          end
          puts
        else
          doc.css('h2 span.mw-headline a').each do |album|
            puts album.text
            # some band pages have extra albums that are not listed in the category page for some reason
            album_dirname = [dirname, album.text].join('/')
            FileUtils.mkdir_p album_dirname
            @new_tree[band][album.text] = album.attr('href')

            # get song pages
            album.parent.parent.css('+ div + ol > li a').each do |song|
              parse_song(song.attr('href'), album_dirname, song.text) if song&.attr('href')
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
        html = URI.open(START_HOST + url)
        doc = Nokogiri::HTML(html)

        lyrics = doc.css('div.lyricbox').first
        return if lyrics.nil?

        if lyrics.css('a')&.first&.attr('href') == '/wiki/Category:Instrumental'
          # instrumental song, whatever
        else
          proper_text = lyrics.inner_html.gsub(%r{<div.*?(\/div>)}, '').split('<br>').join("\n")

          out = File.new(songfile, 'w')
          out.write proper_text
          out.close
        end
      end

      private

      def load_json
        if File.exist? @output
          data = Zlib.gunzip IO.read(@output)
        elsif File.exist? @output.sub('.gz', '')
          data = IO.read(@output)
        else
          raise IOError, "File not found: #{@output}"
        end

        data
      end
    end
  end
end
