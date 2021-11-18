class FtpResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_country, only: [:index]
  before_action :load_ftp_result, only: [:added_description]
  
  def index
    @ftp_results = @country.ftp_results
  end

  def added_description
    @ftp_result.update(ftp_result_params)
  end

  private
  def load_ftp_result
    @ftp_result = FtpResult.find(params[:id])
  end

  def load_country
    @country = Country.find(params[:country_id])
  end

  def ftp_result_params
    params.require(:ftp_result).permit(:description)
  end
end
