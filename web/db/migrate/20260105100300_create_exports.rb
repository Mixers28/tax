class CreateExports < ActiveRecord::Migration[8.1]
  def change
    create_table :exports do |t|
      t.references :tax_return, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :format, null: false # pdf, json
      t.string :file_path
      t.string :json_path
      t.string :file_hash
      t.integer :file_size
      t.json :export_snapshot # All box values at export time
      t.json :validation_state # Validation results at export time
      t.json :calculation_results # All calculations at export time
      t.datetime :exported_at

      t.timestamps
    end

    add_index :exports, [:tax_return_id, :created_at]
    add_index :exports, :exported_at
  end
end
