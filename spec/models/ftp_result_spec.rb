require 'rails_helper'

RSpec.describe FtpResult, type: :model do
  let (:country) { create :country }
  let (:ip_address) { create :ip_address }

  it { should belong_to(:country) }
  it { should belong_to(:ip_address) }

  it { should validate_presence_of(:results) }
end
