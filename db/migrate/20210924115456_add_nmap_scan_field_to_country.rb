class AddNmapScanFieldToCountry < ActiveRecord::Migration[6.1]
  def change
    add_column :countries, :date_last_nmap_scan, :date
    add_column :countries, :status_nmap_scan, :string, default: "Not started"
  end
end
