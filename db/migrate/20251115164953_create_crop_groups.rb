class CreateCropGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :crop_groups do |t|
      t.string :name, null: false
      t.text :description
      t.integer :rotation_years, default: 3

      t.timestamps
    end

    add_index :crop_groups, :name, unique: true
  end
end
