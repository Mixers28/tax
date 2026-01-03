class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.string :actor
      t.string :action, null: false
      t.string :object_ref, null: false
      t.json :before_state
      t.json :after_state
      t.datetime :logged_at, null: false

      t.timestamps
    end

    add_index :audit_logs, :logged_at
  end
end
