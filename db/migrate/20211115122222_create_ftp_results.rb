class CreateFtpResults < ActiveRecord::Migration[6.1]
  def change
    create_table :ftp_results do |t|
      t.references :country, null: false, foreign_key: true
      t.references :ip_address, null: false, foreign_key: true
      t.text :results
      t.text :description

      t.timestamps
    end
  end
end
