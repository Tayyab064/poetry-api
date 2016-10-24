class AddPoetToSher < ActiveRecord::Migration
  def change
  	add_column :shers , :poet , :string , default: ''
  end
end
