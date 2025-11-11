class CreateEventFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :event_feedbacks do |t|
      t.references :calendar, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: true
      t.text :comments, null: false
      t.datetime :submitted_at, null: false

      t.timestamps
    end

    add_index :event_feedbacks, %i[calendar_id admin_id], unique: true
  end
end

