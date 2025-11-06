# frozen_string_literal: true

class ModifySignupsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :signups, if_exists: true

    create_table :signups do |t|
      t.references :calendar, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: true
      t.timestamps
    end

    # Add unique constraint to prevent duplicate signups
    add_index :signups, %i[admin_id calendar_id], unique: true
  end
end
