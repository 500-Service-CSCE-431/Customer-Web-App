# frozen_string_literal: true

class AddRoleToAdmins < ActiveRecord::Migration[8.0]
  def change
    add_column :admins, :role, :string, default: 'member'
    add_index :admins, :role
  end
end
