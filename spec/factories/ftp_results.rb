FactoryBot.define do
  factory :ftp_result do
    country { nil }
    ip_address { nil }
    results { "Vuln" }
    description { "MyText" }
  end
  
  trait :not_vuln do
    results { "Not vuln" }
  end

  trait :with_country_and_ip do
    transient do # for default value
      country { nil }
    end

    after(:build) do |ftp_result, evaluator|
      ip_address = FactoryBot.create(:ip_address, country: evaluator.country)
      ftp_result.ip_address_id = ip_address.id
      ftp_result.country_id = evaluator.country.id
    end
  end
end
