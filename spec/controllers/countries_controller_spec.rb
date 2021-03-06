require 'rails_helper'

RSpec.describe CountriesController, type: :controller do
  let(:country) { create :country }
  let(:user) { create :user }

  describe 'GET #index' do
    let(:countries) { create_list :country, 3}
    before { get :index }

    it 'populates an array of all countries' do
      expect(assigns(:countries)).to match_array(countries)
    end

    it 'render index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: country } }

    it 'assigns the requested country to @country' do
      expect(assigns(:country)).to eq country
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before { sign_in(user) }

    before { get :new}

    it 'assigns a new Country to @country' do
      expect(assigns(:country)).to be_a_new(Country)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    before { sign_in(user) }

    before { get :edit, params: { id: country } }

    it 'assigns the requested country to @country' do
      expect(assigns(:country)).to eq country
    end

    it 'renders edit view' do
      expect(response).to render_template :edit
    end    
  end

  describe 'POST #create' do
    before { sign_in(user) }
    context 'With valid attribute' do
      it 'saves a new country in the database' do
        expect { post :create, params: { country: attributes_for(:country) } }.to change(Country, :count).by(1)
      end

      it 'redirects to show view' do
        post :create, params: { country: attributes_for(:country) }
        expect(response).to redirect_to assigns(:country)
      end
    end

    context 'With invalid attribute' do
      it 'does not save the country' do
        expect { post :create, params: { country: attributes_for(:country, :invalid) } }.to_not change(Country, :count)
      end
      
      it 're-render new view' do
        post :create, params: { country: attributes_for(:country, :invalid) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    before { sign_in(user) }
    context 'With valid attribute' do
      it 'assigns the requested country to @country' do
        patch :update, params: { id: country, country: attributes_for(:country) }
        expect(assigns(:country)).to eq country
      end

      it 'changes country attributes' do
        patch :update, params: { id: country, country: {name: "New name", short_name: "Nn"} }
        country.reload

        expect(country.name).to eq 'New name'
        expect(country.short_name).to eq 'Nn'
      end

      it 'redirects to updated country' do
        patch :update, params: { id: country, country: attributes_for(:country) }
        expect(response).to redirect_to country
      end
    end

    context 'With invalid attributes' do
      before { patch :update, params: { id: country, country: attributes_for(:country, :invalid) } }
      it 'does not change country' do
        country.reload

        expect(country.name).to eq "Kazakhstan"
        expect(country.short_name).to eq "KZ"
      end

      it 're-renders edit view' do
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in(user) }

    let!(:country) { create :country }

    it 'deletes the country' do
      expect { delete :destroy, params: { id: country } }.to change(Country, :count).by(-1)
    end

    it 'redirects to index' do
      delete :destroy, params: { id: country }
      expect(response).to redirect_to countries_path
    end
  end

  describe 'GET #get_cidr' do
    before { sign_in(user) }
    context 'if cidr exist on site http://www.iwik.org/ipcountry/' do
      before { get :get_cidr, params: { id: country }, format: :js }

      it 'assigns the requested country to @country' do
        expect(assigns(:country)).to eq country
      end
      
      it 'download and save cidr in database for the country' do
        country.reload
        expect(country.cidr).to include "57.96.0/22"
      end

      it 'change date of download cidr for the country' do
        country.reload
        expect(country.date_cidr).to be_between(Date.today - 2.day, Date.today)
      end

      it 'render get_cidr view' do
        expect(response).to render_template :get_cidr
      end
    end

    context 'if cidr does not exist on site http://www.iwik.org/ipcountry/' do
      let(:non_existent_country) { create :country, :non_existent_country }
      
      before { get :get_cidr, params: { id: non_existent_country }, format: :js }

      it 'fields cidr and date_cidr for the country continue to equal nil' do         
        expect(non_existent_country.date_cidr).to be_nil
        expect(non_existent_country.cidr).to be_nil
      end

      it 'render get_cidr view' do
        expect(response).to render_template :get_cidr
      end
    end

  end

  describe 'GET #download_cidr' do
    let(:country_with_cidr) { create :country, :with_cidr }

    before { sign_in(user) }
    
    after(:all) { delete_downloaded_file }

    context 'if cidr for country received earlier' do      
      it 'assigns the requested country to @country' do
        get :download_cidr, params: { id: country_with_cidr }, format: :js
        expect(assigns(:country)).to eq country_with_cidr
      end

      it 'call to generate_cidr_file function returns yes' do
        get :download_cidr, params: { id: country_with_cidr }, format: :js
        expect(country_with_cidr.generate_cidr_file).to eq 'Yes'
      end

      it "sends a file named '# {country.short_name}.cidr" do
        expect(controller).to receive(:send_file).with("#{Rails.root}/app/assets/downloads/#{country_with_cidr.short_name}.cidr").and_call_original
        get :download_cidr, params: { id: country_with_cidr }, format: :js
      end
    end

    context 'if cidr for country eq nil' do
      before { get :download_cidr, params: { id: country }, format: :js }

      it 'assigns the requested country to @country' do
        get :download_cidr, params: { id: country }, format: :js
        expect(assigns(:country)).to eq country
      end

      it 'call to generate_cidr_file function returns no' do
        get :download_cidr, params: { id: country }, format: :js
        expect(country.generate_cidr_file).to eq 'No'
      end

      it "does not send file" do
        expect(controller).not_to receive(:send_file).with("#{Rails.root}/app/assets/downloads/#{country.short_name}.cidr").and_call_original
        get :download_cidr, params: { id: country }, format: :js
      end

      it "render view download_cidr" do
        get :download_cidr, params: { id: country }, format: :js
        expect(response).to render_template :download_cidr
      end
    end
  end

  describe 'GET #scan_open_ports' do
    before { sign_in(user) }
    context 'if cidr for country not nul' do
      let(:country_with_cidr) { create :country, :with_cidr }
      before { get :scan_open_ports, params: { id: country_with_cidr }, format: :js }

      it 'assigns the requested country to @country' do
        expect(assigns(:country)).to eq country_with_cidr  
      end

      it 'change date_last_nmap_scan for country' do
        country_with_cidr.reload
        expect(country_with_cidr.date_last_nmap_scan).to eq Date.today
      end

      it 'change status_nmap_scan for country on In process' do
        country_with_cidr.reload
        expect(country_with_cidr.status_nmap_scan).to eq "In process"
      end

      it 'change date_last_nmap_scan for country' do
        country_with_cidr.reload
        expect(country_with_cidr.date_last_nmap_scan).to eq Date.today
      end
      
      it 'render view scan_open_ports' do
        expect(response).to render_template :scan_open_ports
      end
    end

    context 'if cidr for country eq nul' do
      before { get :scan_open_ports, params: { id: country }, format: :js }
      
      it 'assigns the requested country to @country' do
        expect(assigns(:country)).to eq country  
      end

      it 'not change date_last_nmap_scan for country' do
        country.reload
        expect(country.date_last_nmap_scan).to be_nil 
      end

      it 'not change status_nmap_scan for country on In process' do
        country.reload
        expect(country.status_nmap_scan).to eq "Not started"
      end

      it 'render view scan_open_ports' do
        expect(response).to render_template :scan_open_ports
      end

    end
  end

  describe 'GET #scan_ftp_anonymous' do
    before { sign_in(user) }

    context 'if country has scanned ip addresses' do
      let!(:ip_addresses) { create_list :ip_address, 3, :open_ports, country: country }
      before { get :scan_ftp_anonymous, params: { id: country }, format: :js }

      it 'assigns the requested country to @country' do
        expect(assigns(:country)).to eq country
      end
      
      it 'change scan_ftp_status for country on In process' do
        country.reload
        expect(country.scan_ftp_status).to eq "In process"
      end

      it 'render view scan_open_ports' do
        expect(response).to render_template :scan_ftp_anonymous
      end
    end

    context 'if country does not have scanned ip addresses' do
      let(:country_without_ip_addresses) { create :country }
      before { get :scan_ftp_anonymous, params: { id: country_without_ip_addresses }, format: :js }
      
      it 'assigns the requested country to @country' do
        expect(assigns(:country)).to eq country_without_ip_addresses
      end

      it 'not change scan_ftp_status for country on In process' do
        country_without_ip_addresses.reload
        expect(country_without_ip_addresses.scan_ftp_status).to eq "Not started"
      end

      it 'render view scan_open_ports' do
        expect(response).to render_template :scan_ftp_anonymous
      end      
    end
  end
end
