class CountriesController < ApplicationController
  before_action :load_country, only: [:show, :edit, :update, :destroy, :get_cidr]
  
  def index
    @countries = Country.all
  end

  def show
  end

  def new
    @country = Country.new
  end

  def edit
  end

  def create
    @country = Country.new(country_params)
    if @country.save
      redirect_to @country
    else
      render :new
    end
  end

  def update
    if @country.update(country_params)
      redirect_to @country
    else
      render :edit
    end
  end

  def destroy
    @country.destroy
    redirect_to countries_path
  end

  def get_cidr
    message = @country.get_cidr

    if message == "Yes"
      flash[:notice] = "CIDR for #{@country.name} was success download."
    elsif message == "No"
      flash[:alert] = "CIDR for #{@country.name} was not download."
    elsif message.include?("Rescued")
      flash[:alert] = "#{message}"
    end
  end

  private
  def load_country
    @country = Country.find(params[:id])
  end

  def country_params
    params.require(:country).permit(:name, :short_name, :status_masscan)
  end
end

