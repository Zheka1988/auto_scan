require 'rails_helper'

feature 'User can added description for results of ftp scan ', %q{
  in order to add notes,
  authenticate user can added description
} do
  given!(:user) { create :user }
  given(:country) { create :country }
  given(:ip_address) { create :ip_address, country: country }
  given!(:ftp_result) { create :ftp_result, country: country, ip_address: ip_address }
  
  context "Authorized user" do
    background { sign_in(user) }
    
    scenario 'can view list ip adresses', js: true do
      visit country_ftp_results_path(country)
      find('.added-ftp-description-link').click
      fill_in 'Description', with: "description for ftp_result"
      click_on "Add"
      expect(page).to have_content "description for ftp_result"
    end
  end

  scenario "Unauthorized user can't view results ftp_scan" do
    visit country_ip_addresses_path(country)
    expect(page).to have_content "You need to sign in or sign up before continuing."
  end
end