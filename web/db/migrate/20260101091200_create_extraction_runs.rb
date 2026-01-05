class CreateExtractionRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :extraction_runs do |t|
      t.references :evidence, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :model, null: false
      t.text :prompt
      t.text :response_raw
      t.json :candidates
      t.text :error_message
      t.datetime :started_at, null: false
      t.datetime :finished_at

      t.timestamps
    end

    add_index :extraction_runs, :status
  end
end
