# frozen_string_literal: true

class CreateEventSignups < ActiveRecord::Migration[8.0]
  def change
    create_table :event_signups do |t|
      t.string :user_email
      t.string :user_name
      t.references :calendar, null: false, foreign_key: true
      t.datetime :signed_up_at

      t.timestamps
    end
  end
end
