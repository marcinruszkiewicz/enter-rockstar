# frozen_string_literal: true

RSpec.describe EnterRockstar::Generator::Poetic do
  let(:test_data_file) { 'spec/fixtures/test_tokens.json.gz' }
  let(:test_contents) { JSON.parse gunzip(file_fixture('spec/fixtures/test_tokens.json.gz').read) }
  let(:strategy) { 'random' }
  let(:amount) { 10 }

  context '#initialize' do
    let(:generator) do
      EnterRockstar::Generator::Poetic.new(
        data_file: test_data_file,
        amount: amount,
        strategy: strategy
      )
    end

    it 'reads tokens from json file' do
      expect(generator.tokens).to eq test_contents
      expect(generator.strategy).to eq '_random'
      expect(generator.amount).to eq 10
    end

    context 'wrong strategy file' do
      let(:strategy) { 'blitzkrieg' }

      it 'falls back to random' do
        expect(generator.strategy).to eq '_random'
      end
    end

    context 'wrong amount' do
      let(:amount) { 'an imaginary number' }

      it 'falls back to 5' do
        expect(generator.amount).to eq 5
      end
    end

    context 'non-json data file' do
      let(:test_data_file) { 'spec/fixtures/test_tokens_ungzipped.json' }

      it 'reads tokens correctly' do
        expect(generator.tokens).to eq test_contents
      end
    end

    context 'nonexistant data file' do
      let(:test_data_file) { 'this does not exist' }

      it 'raises IOError' do
        expect { EnterRockstar::Generator::Poetic.new(data_file: test_data_file) }.to raise_error IOError
      end
    end
  end

  context '#number' do
    let(:generator) do
      EnterRockstar::Generator::Poetic.new(
        data_file: 'spec/fixtures/single_tokens.json.gz',
        amount: 1,
        strategy: strategy
      )
    end

    context 'random strategy' do
      it 'converts string to poetic' do
        expect(generator.number('705')).to eq ['journey collective world']
      end

      it 'converts integer to poetic' do
        expect(generator.number(705)).to eq ['journey collective world']
      end

      it 'converts string with a decimal to poetic' do
        expect(generator.number('705.4')).to eq ['journey collective world . what']
      end

      it 'converts a decimal to poetic' do
        expect(generator.number(705.4)).to eq ['journey collective world . what']
      end
    end
  end
end
