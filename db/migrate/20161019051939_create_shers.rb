class CreateShers < ActiveRecord::Migration
  def change
    create_table :shers do |t|
      t.text :body , default: ""
      t.string :url , default: ""
      t.string :category , default: ""
      t.timestamps null: false
    end
    add_index :shers, [:body, :category]
  end
end
