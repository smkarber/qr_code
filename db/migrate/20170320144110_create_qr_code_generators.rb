class CreateQrCodeGenerators < ActiveRecord::Migration[5.0]
  def change
    create_table :qr_code_generators do |t|

      t.timestamps
    end
  end
end
