class CountriesController < ApplicationController
  before_action :load_country, only: [:show, :edit, :update, :destroy, :get_cidr, :scan_open_ports]
  
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
  
  def scan_open_ports
    if @country.cidr && @country.date_cidr
      @country.run_nmap("scan_open_ports")
      flash[:notice] =  "Masscan for #{@country.name} has been launched."
    else
      flash[:notice] =  "CIDR for #{@country.name} was not found. First download cidr."
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

