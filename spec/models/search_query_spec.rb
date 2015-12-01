require 'rails_helper'

RSpec.describe SearchQuery do
  subject { SearchQuery.new '' }

  context '#initialize' do
    it 'should fail if query is not string' do
      expect { described_class.new 12 }.to raise_error ArgumentError
    end
  end

  it { is_expected.to respond_to :raw_query }

  context '#parse' do
    before :each do
      allow(subject).to receive(:raw_query).and_return 'Positive "Complex Tokens"'
    end

    it 'should get positive tokens' do
      expect(subject.parse[:positive]).to eq Set.new(['Positive', 'Complex Tokens'])
    end

    it 'should extract all tokens' do
      allow(subject).to receive(:raw_query).and_return 'Positive "Complex Tokens" More "tokens"'
      expect(subject.parse[:positive]).to eq Set.new(['Positive', 'Complex Tokens', 'More', 'tokens'])
    end

    it 'should get negative tokens' do
      allow(subject).to receive(:raw_query).and_return '-Negative -"Complex Tokens"'
      expect(subject.parse[:negative]).to eq Set.new(['Negative', 'Complex Tokens'])
    end
  end

  context '#results' do
    let(:language_1) { double :language_1, name: 'Language 1', hits: 1, :hits= => nil }
    let(:language_2) { double :language_2, name: 'Language 2', hits: 1, :hits= => nil }

    before :each do
      allow(subject).to receive(:parse).and_return positive: ['Compiled'], negative: ['Ada']
      allow(Language).to receive(:where).with(name: ['Compiled']).and_return []
      allow(Language).to receive(:where).with(type: ['Compiled']).and_return [language_1, language_2]
      allow(Language).to receive(:where).with(designers: ['Compiled']).and_return []

      allow(Language).to receive(:where_not).with(name: ['Ada']).and_return [language_2]
      allow(Language).to receive(:where_not).with(type: ['Ada']).and_return [language_2]
      allow(Language).to receive(:where_not).with(designers: ['Ada']).and_return [language_2]
    end

    it 'should treat positive tokens as OR with negative as AND' do
      expect(subject.results).to eq [language_2]
    end

    it 'should order results by weight: take one' do
      allow(Language).to receive(:where).with(name: ['Compiled']).and_return [language_2]
      allow(Language).to receive(:where).with(type: ['Compiled']).and_return [language_1, language_2]
      allow(Language).to receive(:where).with(designers: ['Compiled']).and_return [language_2, language_1]

      allow(Language).to receive(:where_not).with(name: ['Ada']).and_return [language_2, language_1]
      allow(Language).to receive(:where_not).with(type: ['Ada']).and_return [language_1, language_2]
      allow(Language).to receive(:where_not).with(designers: ['Ada']).and_return [language_1, language_2]

      expect(subject.results).to eq [language_2, language_1]
    end

    it 'should order results by weight: take two' do
      allow(Language).to receive(:where).with(name: ['Compiled']).and_return [language_1, language_2]
      allow(Language).to receive(:where).with(type: ['Compiled']).and_return [language_1]
      allow(Language).to receive(:where).with(designers: ['Compiled']).and_return [language_2, language_1]

      allow(Language).to receive(:where_not).with(name: ['Ada']).and_return [language_1, language_2]
      allow(Language).to receive(:where_not).with(type: ['Ada']).and_return [language_1, language_2]
      allow(Language).to receive(:where_not).with(designers: ['Ada']).and_return [language_1, language_2]

      expect(subject.results).to eq [language_1, language_2]
    end
  end
end

