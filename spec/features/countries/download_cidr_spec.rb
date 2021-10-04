require 'rails_helper'

feature 'User can download cidr', %q{
  In order to use cidr in work not related to the application,
  user can download it 
}do
  given!(:user) { create :user }
  given!(:country) { create :country }
  given!(:country_with_cidr) { create :country, :with_cidr }

  after(:context) { delete_downloaded_file }

  context "Authorized user" do
    background { sign_in(user) }

    scenario "can download cidr if it was received earlier" do
      visit countries_path
      within "#country-#{country_with_cidr.id}" do
        find('a.link-download-file-cidr' ).click
      end 

      expect(page.body).to have_content country_with_cidr.date_cidr
      expect(page.body).to have_content country_with_cidr.cidr.split(",").first
      expect(page.body).to have_content country_with_cidr.cidr.split(",").last
    end

    scenario 'can not download cidr if it was not received earlier' do
      visit countries_path
      expect(page).to_not have_link(href: download_cidr_country_path(country))
    end
  end

  context "Unanuthorized user" do
    scenario 'can not download cidr' do
      visit countries_path
      expect(page).to_not have_link(href: download_cidr_country_path(country))
      expect(page).to_not have_link(href: download_cidr_country_path(country_with_cidr))
    end    
  end
end