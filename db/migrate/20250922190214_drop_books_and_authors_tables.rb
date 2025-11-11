# frozen_string_literal: true

class DropBooksAndAuthorsTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :books, if_exists: true
    drop_table :authors, if_exists: true
  end
end
