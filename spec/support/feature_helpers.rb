module FeatureHelpers
  def sign_in(user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'
  end

  def delete_downloaded_file   
    country_with_cidr = FactoryBot.create(:country, :with_cidr)
    File.delete("#{Rails.root}/app/assets/downloads/#{country_with_cidr.short_name}.cidr")
    Country.destroy_all
  end
end