# frozen_string_literal: true

class AddCategoryToCalendars < ActiveRecord::Migration[8.0]
  def change
    add_column :calendars, :category, :string
  end
end
