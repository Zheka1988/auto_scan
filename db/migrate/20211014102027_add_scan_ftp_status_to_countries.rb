class AddScanFtpStatusToCountries < ActiveRecord::Migration[6.1]
  def change
    add_column :countries, :scan_ftp_status, :string, default: "Not started"
  end
end
