require 'rails_helper'

RSpec.describe LanguagesController, type: :controller do
  let(:query_class) { double :query_class }
  let(:query) { double :query }
  let(:language) { double :language, as_json: { foo: :bar } }

  before :each do
    stub_const 'SearchQuery', query_class
  end

  context '#index' do
    it 'should render default index page' do
      get :index
    end

    it 'should render json search results' do
      allow(query_class).to receive(:new).and_return query
      allow(query).to receive(:results).and_return [language]

      get :index, format: 'json', query: 'Something'

      expect(response.body).to eq ''
    end
  end
end
