RSpec.describe EnterRockstar::Scraper::Wikia do
  context 'category page scraping' do
    let(:category_name) { 'power_metal' }
    let(:url) { '/wiki/Category:Genre/Power_Metal' }
    let(:json_source) { file_fixture('spec/fixtures/wikia_power_metal.json').read }
    let(:expected_tree) { JSON.parse json_source }

    let(:scraper) do
      EnterRockstar::Scraper::Wikia.new(
        category_name: category_name,
        url: url,
        data_dir: 'spec/fixtures'
      )
    end

    it 'gets a hash tree from the wikia page', :vcr do
      scraper.parse_category(test_limit: true)

      expect(scraper.tree).to eq expected_tree
    end

    it 'reads the saved json file' do
      scraper.load_saved_json

      expect(scraper.tree).to eq expected_tree
    end
  end
end
