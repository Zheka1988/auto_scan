require 'rails_helper'

feature 'User can view results ftp scan for the country', %q{
  In order to view the results ftp scan
  authenticate user
  i'd like to be able list of ip addresses who have ftp anonymous vulnerability
} do
  given!(:user) { create :user }
  given(:country) { create :country }
  given(:ip_address) { create :ip_address, country: country }
  given!(:ftp_results) { create_list :ftp_result, 3, country: country, ip_address: ip_address }
  
  context "Authorized user" do
    background { sign_in(user) }
    
    scenario 'can view list ip adresses' do
      visit country_ip_addresses_path(country)
      find('.show-ftp-results-link').click
      expect(page).to have_content ftp_results.first.ip_address.ip, count: 3
      expect(page).to have_content ftp_results.first.results, count: 3
    end
  end

  scenario "Unauthorized user can't view results ftp_scan" do
    visit country_ip_addresses_path(country)
    expect(page).to have_content "You need to sign in or sign up before continuing."
  end
end