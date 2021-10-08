require 'rails_helper'

RSpec.describe IpAddress, type: :model do
  it { should belong_to(:country) }

  subject { create(:ip_address) }
  it { should validate_uniqueness_of(:ip).scoped_to(:country_id).case_insensitive }
  it { should validate_presence_of(:ip) }
  it { should allow_value('8.8.8.8').for(:ip) }
  it { should_not allow_value('8.8.8').for(:ip) }
  it { should_not allow_value('asd').for(:ip) }
end
