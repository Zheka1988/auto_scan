require 'rails_helper'

feature 'User can run ftp anonymous scan', %q{
  In order to find the ftp anonymous vulnerability,
  user can run ftp scan for the ip addresses of a selected country 
  with an open 21 port
} do
  given!(:user) { create :user }
  given!(:country) { create :country}
  given!(:ip_addresses) { create_list :ip_address, 3, :open_ports, country: country }
  
 context "Authorized user" do
    background { sign_in(user) }
    
    scenario "can run ftp scan", js: true do
      visit country_ip_addresses_path(country)  
      find(".show-panel-action-body").click
      click_on "FTP-Anonymous"
      expect(page).to have_content "Ftp scan for #{country.name} has been successfully launched."
    end
  end

  scenario "Unauthorized can't run ftp scan" do
    visit country_ip_addresses_path(country)
    expect(page).to have_content "You need to sign in or sign up before continuing."
  end
end