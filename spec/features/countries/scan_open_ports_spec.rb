require 'rails_helper'

feature 'User can run scan ope ports', %q{
  In order to find open ports, 
  user can run a scan open ports
}do
  given!(:user) { create :user }
  given!(:country) { create :country }
  given!(:country_with_cidr) { create :country, :with_cidr }

  context "Authorized user" do
    background { sign_in(user) }
    
    scenario "can run scan open ports if cidr was received earlier", js: true do
      visit countries_path
      within "#country-#{country_with_cidr.id}" do
        click_on 'Scan open ports'
        expect(page).to have_content 'In process'       
      end
    end

    scenario "can't run scan open ports if cidr was not received earlier" do
      visit countries_path
      expect(page).to_not have_link(href: scan_open_ports_country_path(country))
    end
  end

  context "Unathorized user" do
    scenario 'can not run scan open ports' do
      expect(page).to_not have_link(href: scan_open_ports_country_path(country))
      expect(page).to_not have_link(href: scan_open_ports_country_path(country_with_cidr))
    end  
  end
end