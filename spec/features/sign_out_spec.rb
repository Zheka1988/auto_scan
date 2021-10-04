require 'rails_helper'

feature 'User can sign_out', %q{
  in order to complete the use of the application, 
  user can log out
} do
  
  given!(:user) { create(:user) }

  scenario 'Logged in user tries to log out' do   
    sign_in(user)
    click_on 'Log_out'
    expect(page).to have_content 'Signed out successfully.'
  end

  scenario 'Not logged in user tries to log out' do
    visit countries_path

    expect(page).to_not have_content 'Log out'
  end
end