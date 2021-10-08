class CreateIpAdresses < ActiveRecord::Migration[6.1]
  def change
    create_table :ip_adresses do |t|
      t.references :country, null: false, foreign_key: true
      t.string :ip
      t.boolean :port_21, default: false
      t.boolean :port_22, default: false
      t.boolean :port_443, default: false
      t.boolean :port_139, default: false
      t.boolean :port_445, default: false
      t.boolean :port_3389, default: false
      t.boolean :port_80, default: false
      t.boolean :port_8080, default: false

      t.timestamps
    end
  end
end
