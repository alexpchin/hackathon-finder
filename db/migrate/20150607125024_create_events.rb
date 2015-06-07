class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :provider
      t.bigint :external_id
      t.json :content

      t.timestamps null: false
    end
  end
end
