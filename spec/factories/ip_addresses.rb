FactoryBot.define do
  sequence :ip do |n|
    "8.8.8.#{n}"
  end

  factory :ip_address do
    # country { FactoryBot.create(:country) }
    country { nil }
    ip 
    port_21 { false }
    port_22 { false }
    port_443 { false }
    port_139 { false }
    port_445 { false }
    port_3389 { false }
    port_80 { false }
    port_8080 { false }
  end
  
  trait :open_ports do
    port_21 { true }
    port_22 { true }
    port_443 { true }
    port_139 { true }
    port_445 { true }
    port_3389 { true }
    port_80 { true }
    port_8080 { true }
  end
end
