# frozen_string_literal: true

RSpec.describe EnterRockstar::Scraper::Wikia do
  context 'category page scraping' do
    let(:data_dir) { 'spec/fixtures' }
    let(:category_name) { 'power_metal' }
    let(:url) { '/wiki/Category:Genre/Power_Metal' }
    let(:json_source) { file_fixture('spec/fixtures/wikia_power_metal.json.gz').read }
    let(:expected_tree) { JSON.parse gunzip(json_source) }

    let(:scraper) do
      EnterRockstar::Scraper::Wikia.new(
        category_name: category_name,
        url: url,
        data_dir: data_dir
      )
    end

    describe '#initialize' do
      it 'creates instance variables' do
        expect(scraper.tree).to eq({})
        expect(scraper.url).to eq url
        expect(scraper.output).to eq "#{data_dir}/wikia_#{category_name}.json.gz"
        expect(scraper.category_name).to eq category_name
      end
    end

    describe '#parse_category' do
      it 'gets a hash tree from the wikia page', :vcr do
        scraper.parse_category(test_limit: true)

        expect(scraper.tree).to eq expected_tree
      end
    end

    describe '#load_saved_json' do
      it 'reads the saved json gzip' do
        scraper.load_saved_json

        expect(scraper.tree).to eq expected_tree
      end

      context 'if gzipped json is not available' do
        let(:scraper) do
          EnterRockstar::Scraper::Wikia.new(
            category_name: 'power_metal_ungzipped',
            url: url,
            data_dir: data_dir
          )
        end

        it 'tries to fall back on ungzipped json' do
          scraper.load_saved_json

          expect(scraper.tree).to eq expected_tree
        end
      end

      context 'if no file found' do
        let(:scraper) do
          EnterRockstar::Scraper::Wikia.new(
            category_name: 'wrong_category_name',
            url: url,
            data_dir: data_dir
          )
        end

        it 'raises IOError' do
          expect { scraper.load_saved_json }.to raise_error IOError
        end
      end
    end

    describe '#save_category' do
      let(:scraper) do
        EnterRockstar::Scraper::Wikia.new(
          category_name: category_name,
          url: url,
          data_dir: '.'
        )
      end

      it 'saves a gzipped json file', :vcr do
        scraper.parse_category(test_limit: true)

        FakeFS.with_fresh do
          scraper.save_category

          expect(File.exist?("wikia_#{category_name}.json.gz")).to eq true
        end
      end
    end
  end
end
