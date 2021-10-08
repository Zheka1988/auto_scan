require 'rails_helper'

RSpec.describe IpAddressesController, type: :controller do
  let(:user) { create :user }
  let!(:country) { create :country }
  let!(:ip_addresses) { create_list :ip_address, 3, country: country }

  describe 'GET #index' do
    before { sign_in(user) }
    before { get :index, params: { country_id: country.id } }

    it 'populates an array of all ip_adressses' do
      expect(assigns(:ip_addresses)).to match_array(ip_addresses)
    end

    it 'render index view' do
      expect(response).to render_template :index
    end
  end
end
