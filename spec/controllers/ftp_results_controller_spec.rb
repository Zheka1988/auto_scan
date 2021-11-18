require 'rails_helper'

RSpec.describe FtpResultsController, type: :controller do
  let(:user) { create :user }
  let!(:country) { create :country }
  

  describe 'GET #index' do
    let!(:ftp_results) { create_list :ftp_result, 3, :with_country_and_ip, country: country }
    before { sign_in(user) }
    before { get :index, params: { country_id: country.id } }

    it 'populates an array of all ip_adressses' do
      expect(assigns(:ftp_results)).to match_array(ftp_results)
    end

    it 'render index view' do
      expect(response).to render_template :index
    end
  end

  describe "PATCH #added_description" do
    let!(:ftp_result) { create :ftp_result, :with_country_and_ip, country: country }
    before { sign_in(user) }
    before { patch :added_description, params: { id: ftp_result, ftp_result: { description: "New description" } }, format: :js }
    
    it 'assigns the requested ftp_result to @ftp_result' do
      expect(assigns(:ftp_result)).to eq ftp_result
    end

    it 'changes ftp_result description' do
      ftp_result.reload
      expect(ftp_result.description).to eq "New description"
    end

    it 'render added_description view' do
      expect(response).to render_template :added_description
    end
  end
end
