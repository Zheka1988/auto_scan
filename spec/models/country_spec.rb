require 'rails_helper'

RSpec.describe Country, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:short_name) }
  it { should validate_length_of(:short_name).is_equal_to(2) }
  it { should validate_inclusion_of(:status_nmap_scan).in_array(["In process", "Completed successfully", "Not started", "Completed with error(s)"])}

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

  describe '#scan_open_ports' do
    let(:country_with_cidr) { create :country, :with_cidr }
    let(:type_scan) { "scan_open_ports" }
    let(:cidr_array) { country_with_cidr.cidr.split(",") }

    it 'should calls NmapStartJob' do
      expect {country_with_cidr.run_nmap(type_scan)
      }.to have_enqueued_job(NmapStartJob).with(country_with_cidr, type_scan, country_with_cidr.ports, cidr_array)
    end
  end
end
