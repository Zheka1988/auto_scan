class AddDateLastScanToIpAddress < ActiveRecord::Migration[6.1]
  def change
    add_column :ip_addresses, :date_last_scan, :date
  end
end
