# frozen_string_literal: true

RSpec.describe EnterRockstar::Scraper::Wikia do
  context 'album page scraping', :vcr do
    let(:data_dir) { 'spec/tmp' }
    let(:category_name) { 'power_metal' }
    let(:url) { '/wiki/Category:Genre/Power_Metal' }
    let!(:song_source) { file_fixture('spec/fixtures/The_Score.txt').read }

    let(:scraper) do
      EnterRockstar::Scraper::Wikia.new(
        category_name: category_name,
        url: url,
        data_dir: data_dir
      )
    end

    describe '#parse_song' do
      let(:song_url) { '/wiki/Amaranthe:The_Score' }
      let(:song_dirname) { '.' }
      let(:song_name) { 'The Score' }
      let(:instrumental) { '/wiki/Arcana_Opera:Intro' }
      let(:instrumental_name) { 'Intro' }

      it 'scrapes lyrics correctly' do
        expect(scraper.parse_song(song_url, song_dirname, song_name)).to eq song_source
      end

      it 'does not try to parse an instrumental song' do
        expect(scraper.parse_song(instrumental, song_dirname, instrumental_name)).to eq nil
      end
    end

    describe '#save_song' do
      it 'saves text file' do
        FakeFS.with_fresh do
          scraper.save_song('./The Score.txt', song_source)

          expect(File.exist?('The Score.txt')).to eq true
          expect(File.read('The Score.txt')).to eq song_source
        end
      end
    end

    describe '#parse_page' do
      let(:data_dir) { 'spec/tmp' }
      let(:album_url) { '/wiki/Sentenced:North_From_Here_(1993)' }
      let(:band_url) { '/wiki/Sentenced' }

      before do
        FileUtils.rm_rf('spec/tmp')
      end

      context 'single album page' do
        it 'parses all songs' do
          scraper.parse_page(album_url, data_dir)
          expect(File.exist?('spec/tmp/The Glow of 1000 Suns.txt')).to eq true
        end

        it 'skips songs that do not have links' do
          scraper.parse_page(album_url, data_dir)

          expect(File.exist?('spec/tmp/Amok Run.txt')).to eq false
        end
      end

      context 'band page' do
        it 'parses all albums' do
          scraper.parse_page(band_url, data_dir)
          expect(File.exist?('spec/tmp/The Funeral Album (2005)/End of the Road.txt')).to eq true
        end
      end
    end

    xdescribe '#parse_all_pages' do
    end
  end
end
