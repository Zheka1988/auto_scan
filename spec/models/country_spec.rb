require 'rails_helper'

RSpec.describe Country, type: :model do
  it { should have_many(:ip_addresses) }
  it { should have_many(:ftp_results) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:short_name) }
  it { should validate_length_of(:short_name).is_equal_to(2) }
  it { should validate_inclusion_of(:status_nmap_scan).in_array(["In process", "Completed successfully", "Not started", "Completed with error(s)"])}
  it { should validate_inclusion_of(:scan_ftp_status).in_array(["In process", "Completed successfully", "Not started", "Completed with error(s)"])}

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

  describe 'generate_cidr_file' do
    let(:country) { create :country, :with_cidr }
    let(:country_without_cidr) { create :country }
    let!(:count)  { count_first = Dir.glob(File.join("#{Rails.root}/app/assets/downloads/", "**", "*")).select{ |file| File.file?(file) }.count }

    it "if country has cidr" do  
      expect(country.generate_cidr_file).to eq "Yes"
      
      count_after_action = Dir.glob(File.join("#{Rails.root}/app/assets/downloads/", "**", "*")).select{ |file| File.file?(file) }.count
      expect(count_after_action).to eq count + 1 
      File.delete("#{Rails.root}/app/assets/downloads/#{country.short_name}.cidr")
    end

    it "if country has no cidr" do    
      expect(country_without_cidr.generate_cidr_file).to eq "No"

      count_after_action = Dir.glob(File.join("#{Rails.root}/app/assets/downloads/", "**", "*")).select{ |file| File.file?(file) }.count
      expect(count_after_action).to eq count
    end
  end

  describe '#run_nmap' do
    let(:country_with_cidr) { create :country, :with_cidr }
    let(:type_scan) { "scan_open_ports" }
    let(:cidr_array) { country_with_cidr.cidr.split(",") }

    it 'should calls NmapStartJob' do
      expect {country_with_cidr.run_nmap(type_scan)
      }.to have_enqueued_job(NmapStartJob).with(country_with_cidr, type_scan, country_with_cidr.ports, cidr_array)
    end
  end
end
