class AddUrlToQrGenerator < ActiveRecord::Migration[5.0]
  def change
    add_column :qr_code_generators, :url, :string, default: "http://momenthealth.com", null: false
  end
end
