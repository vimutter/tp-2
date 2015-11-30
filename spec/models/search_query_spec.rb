require 'rails_helper'

RSpec.describe SearchQuery do
  context '#initialize' do
    it 'should fail if query is not string' do
      expect { described_class.new }.to raise_error ArgumentError
    end
  end

  it { is_expected.to respond_to :raw_query }

  context '#parse' do
    subject { SearchQuery.new '' }

    before :each do
      allow(subject).to receive(:raw_query).and_return 'Positive "Complex Tokens"'
    end

    it 'should get positive tokens' do
      expect(subject.parse[:positive]).to eq ['Positive', 'Complex Tokens']
    end

    it 'should get negative tokens' do
      allow(subject).to receive(:raw_query).and_return '-Negative -"Complex Tokens"'
      expect(subject.parse[:negative]).to eq ['Negative', 'Complex Tokens']
    end
  end

  context '#results' do
    subject { SearchQuery.new '' }
    let(:language_1) { double :language_1 }
    let(:language_2) { double :language_2 }

    before :each do
      allow(subject).to receive(:parse).and_return positive: ['Compiled'], negative: ['Ada']
      allow(Language).to receive(:where).with(name: ['Compiled']).and_return []
      allow(Language).to receive(:where).with(type: ['Compiled']).and_return [language_1, language_2]
      allow(Language).to receive(:where).with(designers: ['Compiled']).and_return []

      allow(Language).to receive(:where_not).with(name: ['Ada']).and_return [language_2]
      allow(Language).to receive(:where_not).with(type: ['Ada']).and_return []
      allow(Language).to receive(:where_not).with(designers: ['Ada']).and_return []
    end

    it 'should treat positive tokens as OR with negative as AND' do
      expect(subject.results).to eq [language_1]
    end
  end
end

