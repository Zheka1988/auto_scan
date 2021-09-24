require 'rails_helper'

RSpec.describe Country, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:short_name) }
  it { should validate_length_of(:short_name).is_equal_to(2) }

  describe 'get_cidr' do
    let(:country) { create :country }
    let(:non_existent_country) { create :country, :non_existent_country}

    it 'if cidr exist on site http://www.iwik.org/ipcountry/' do
      expect(country.get_cidr).to eq 'Yes'
    end

    it 'if cidr does not exist on site http://www.iwik.org/ipcountry/' do
      expect(non_existent_country.get_cidr).to eq 'No'
    end
  end
end
