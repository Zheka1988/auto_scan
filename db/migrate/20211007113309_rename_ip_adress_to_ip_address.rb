class RenameIpAdressToIpAddress < ActiveRecord::Migration[6.1]
  def change
    rename_table :ip_adresses, :ip_addresses
  end
end
