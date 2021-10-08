require 'rails_helper'


feature 'User can view ip addresses', %q{
  In order to view the list ip addresses with open port
  authenticate user
  i'd like to be able list of ip addresses
}do
  
  given(:user) { create :user }
  given(:country) { create :country}
  given(:ip_address) { create :ip_address, country: country }
  
  context 'Authenticate user' do
    background { sign_in(user) }

    scenario 'can view list ip adresses' do
      visit countries_path(ip_address.country.id)
      
      click_on "#{country.name}"
      
      expect(page).to have_content ip_address.ip
    end
  end
  
  scenario 'Unauthenticate user' do
    visit countries_path(ip_address.country.id)
    click_on "#{country.name}"
    expect(page).to have_content "You need to sign in or sign up before continuing."
  end
end