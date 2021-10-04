require 'rails_helper'

feature 'User can get cidr', %q{
  In order to obtain ip addresses for scanning, 
  user can download the cidr of the target country 
}do
  given!(:user) { create :user }
  given!(:country) { create :country }
  given!(:non_exist_country) { create :country, :non_existent_country }

  context 'Authenticate user' do
    background { sign_in(user) }
    
    scenario 'can get user if country exist on site http://www.iwik.org/ipcountry', js: true do
      visit countries_path
      within ".countries .table-countries #country-#{country.id}" do
        click_on 'Get CIDR'
        
        expect(page).to have_content "Update CIDR"
        expect(page).to have_content country.date_cidr
        expect(page).to have_content "Scan open ports"
        expect(page).to_not have_content "First get CIDR"
      end
      expect(page).to have_content "CIDR for #{country.name} was successfully reciewed."
    end

    scenario "can't get user if country does not exist on site http://www.iwik.org/ipcountry", js: true do
      visit countries_path
      within ".countries .table-countries #country-#{non_exist_country.id}" do
        click_on 'Get CIDR'
        expect(page).to have_content "Get CIDR"
        expect(page).to have_content "First get CIDR"
      end
      expect(page).to have_content "CIDR for #{non_exist_country.name} was not reciewed."
    end
  end

  context 'Unauthenticate user' do
    scenario "can't get CIDR" do
      visit countries_path
      within ".countries .table-countries #country-#{non_exist_country.id} .cidr-country" do
        expect(page).to have_content "After authorization"
      end
    end
  end
end
