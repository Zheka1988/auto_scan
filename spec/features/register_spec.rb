require 'rails_helper'

feature 'User can register', %q{
  In order to be able to enter the applications,
  user can register
} do
 
  given!(:user) { create(:user) }
  
  background { visit new_user_registration_path }

  scenario 'Unregistered user tries to register' do
    fill_in 'Email', with: "wrong@test.com"
    fill_in 'Password', with: "12345678"
    fill_in 'Password confirmation', with: "12345678"
    click_button 'Sign up'

    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'Registered user tries to sign in' do  
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password
    click_button 'Sign up'

    expect(page).to have_content 'Email has already been taken'
  end

end