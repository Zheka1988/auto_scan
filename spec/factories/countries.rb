FactoryBot.define do
  factory :country do
    name { "Kazakhstan" }
    short_name { "KZ" }
    cidr { nil }
    date_cidr { nil }
    
    trait :invalid do
      short_name { "KZ_KZ" }
    end

    trait :non_existent_country do
      name { "Qqqqqqqq" }
      short_name { "QQ" }
    end
  end
end
