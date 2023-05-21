class CreateMicroposts < ActiveRecord::Migration[7.0]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # creates multi-key index to index by both keys at once!
    add_index :microposts, [:user_id, :created_at]
  end
end
