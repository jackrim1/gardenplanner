class CreateSpecies < ActiveRecord::Migration[7.2]
  def change
    create_table :species do |t|
      t.string :latin_name
      t.string :common_name
      t.integer :plant_type, null: false, default: 0
      t.integer :life_cycle, null: false, default: 0
      t.text :description
      
      # Both foreign keys are optional
      t.references :genus, null: true, foreign_key: { to_table: :genera }
      t.references :crop_group, null: true, foreign_key: true

      t.timestamps
    end

    # Partial unique index on latin_name when present
    add_index :species, :latin_name, unique: true, where: "latin_name IS NOT NULL"
    add_index :species, :common_name
  end
end
