class CreateVeteranDeviceRecord < ActiveRecord::Migration[6.1]
  def change
    create_table :veteran_device_records do |t|
      t.references :device, null: false, foreign_key: true
      t.boolean :active
      t.string :user_uuid, null: false

      t.timestamps
    end
  end
end
