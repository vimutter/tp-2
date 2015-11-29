require 'rails_helper'

RSpec.describe LanguageData, type: :module do
  subject do
    Class.new do
      include LanguageData
    end
  end

  it 'should provide DATA constant' do
    expect(subject::DATA.first).to_not be_nil
  end
end
