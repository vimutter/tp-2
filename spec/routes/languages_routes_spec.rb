require 'rails_helper'

RSpec.describe 'LanguagesController routes', type: :routing do
  it 'should route index' do
    expect(get: "/languages").to route_to(controller: "languages", action: 'index')
  end

  it 'should route home to index' do
    expect(get: "/").to route_to(controller: "languages", action: 'index')
  end
end
