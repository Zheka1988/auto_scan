FactoryBot.define do
  factory :country do
    name { "Kazakhstan" }
    short_name { "KZ" }
    cidr { nil }
    date_cidr { nil }
    date_last_nmap_scan { nil }
    status_nmap_scan { 'Not started'}

    trait :invalid do
      short_name { "KZ_KZ" }
    end

    trait :non_existent_country do
      name { "Qqqqqqqq" }
      short_name { "QQ" }
    end

    trait :with_cidr do
      short_name { "AF" }
      cidr { "91.109.217.0/24,91.109.219.0/24" }
      date_cidr { Date.today }
    end

  end
end
