class AddPort25ToIpAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :ip_addresses, :port_25, :boolean, default: false
  end
end
