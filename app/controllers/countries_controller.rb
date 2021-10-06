class CountriesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  
  before_action :load_country, only: [:show, :edit, :update, :destroy, :get_cidr, :download_cidr, :scan_open_ports]
  
  protect_from_forgery except: [:get_cidr, :download_cidr, :scan_open_ports]

  def index
    @countries = Country.all.order("name ASC")
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
      flash.now.notice = "CIDR for #{@country.name} was successfully reciewed."
    elsif message == "No"
      flash.now.notice = "CIDR for #{@country.name} was not reciewed."
    elsif message.include?("Rescued")
      flash.now.notice = "#{message}."
    end
  end

  def download_cidr
    message = @country.generate_cidr_file

    if message == "Yes"
      send_file "#{Rails.root}/app/assets/downloads/#{@country.short_name}.cidr"
      flash.now.notice = "CIDR file for #{@country.name} downloaded successfully."
    else message == "No"
      flash.now.notice = "First you need to get cidr for #{@country.name}."
    end
  end
  
  def scan_open_ports
    if @country.cidr && @country.date_cidr
      @country.run_nmap("scan_open_ports")
      # flash[:notice] = "Open ports scan for #{@country.name} has been successfully launched."
      # flash.now.notice =  "Open ports scan for #{@country.name} completed."
    else
      flash.now.notice = "CIDR for #{@country.name} was not found. First download cidr."
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

