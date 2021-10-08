class IpAddress < ApplicationRecord
  belongs_to :country

  validates :ip, uniqueness: { scope: :country_id, case_sensitive: false } 
  validates :ip, presence: true
  validates_format_of :ip, with: Resolv::IPv4::Regex

end
