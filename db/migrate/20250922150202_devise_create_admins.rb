# frozen_string_literal: true

class DeviseCreateAdmins < ActiveRecord::Migration[8.0]
  def change
    create_table :admins do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Custom fields for Google OAuth
      t.string :full_name
      t.string :uid
      t.string :avatar_url

      t.timestamps null: false
    end

    add_index :admins, :email,                unique: true
    add_index :admins, :reset_password_token, unique: true
    add_index :admins, :uid,                  unique: true
  end
end
