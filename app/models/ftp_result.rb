class FtpResult < ApplicationRecord
  belongs_to :country
  belongs_to :ip_address

  validates :results, presence: true
end
