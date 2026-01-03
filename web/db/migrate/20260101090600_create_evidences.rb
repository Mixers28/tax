class CreateEvidences < ActiveRecord::Migration[8.1]
  def change
    create_table :evidences do |t|
      t.references :tax_return, null: false, foreign_key: true
      t.string :filename, null: false
      t.string :mime
      t.string :sha256
      t.binary :encrypted_blob
      t.json :tags

      t.timestamps
    end
  end
end
