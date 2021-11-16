require 'rails_helper'

RSpec.describe FtpResultsController, type: :controller do
  let(:user) { create :user }
  let!(:country) { create :country }
  let!(:ftp_results) { create_list :ftp_result, 3, :with_country_and_ip, country: country }

  describe 'GET #index' do
    before { sign_in(user) }
    before { get :index, params: { country_id: country.id } }

    it 'populates an array of all ip_adressses' do
      expect(assigns(:ftp_results)).to match_array(ftp_results)
    end

    it 'render index view' do
      expect(response).to render_template :index
    end
  end
end
