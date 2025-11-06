# frozen_string_literal: true

class CreateCalendars < ActiveRecord::Migration[8.0]
  def change
    create_table :calendars do |t|
      t.string :title
      t.datetime :event_date
      t.text :description
      t.string :location

      t.timestamps
    end
  end
end
