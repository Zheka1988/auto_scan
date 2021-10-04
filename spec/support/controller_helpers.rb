module ControllerHelpers
  def login(user)
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in(user)
  end

  def delete_downloaded_file   
    country_with_cidr = FactoryBot.create(:country, :with_cidr)
    File.delete("#{Rails.root}/app/assets/downloads/#{country_with_cidr.short_name}.cidr")
    Country.destroy_all
  end
end