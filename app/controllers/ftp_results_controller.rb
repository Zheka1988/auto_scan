class FtpResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_country, only: [:index]

  def index
    @ftp_results = @country.ftp_results
  end
  private

  def load_country
    @country = Country.find(params[:country_id])
  end

end
