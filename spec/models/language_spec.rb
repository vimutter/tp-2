require 'rails_helper'

RSpec.describe Language do
  context '.where' do
    it 'should return language objects by string' do
      result = described_class.where(name: 'A+').first
      expect(result.name).to eq 'A+'
      expect(result.type).to eq ['Array']
      expect(result.designers).to eq ['Arthur Whitney']
    end

    it 'should return language objects by array' do
      result = described_class.where(name: ['A+']).first
      expect(result.name).to eq 'A+'
      expect(result.type).to eq ['Array']
      expect(result.designers).to eq ['Arthur Whitney']
    end
  end

  context '.where_not' do
    it 'should return language objects by array' do
      result = described_class.where_not(type: ['Compiled', 'Iterative']).first
      expect(result.name).to eq 'A+'
      expect(result.type).to eq ['Array']
      expect(result.designers).to eq ['Arthur Whitney']
    end

    it 'should return language objects by sring' do
      result = described_class.where_not(type: 'Compiled').first
      expect(result.name).to eq 'A+'
      expect(result.type).to eq ['Array']
      expect(result.designers).to eq ['Arthur Whitney']
    end
  end
end
