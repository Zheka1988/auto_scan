class IpAddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_country, only: [:index]
  
  def index
    @ip_addresses = @country.ip_addresses
  end
  private

  def load_country
    @country = Country.find(params[:country_id])
  end
end
