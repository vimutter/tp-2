class LanguagesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        render json: SearchQuery.new(params[:query].to_s).results
      end
    end
  end
end
