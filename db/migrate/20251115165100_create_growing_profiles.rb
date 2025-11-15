class CreateGrowingProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :growing_profiles do |t|
      t.references :cultivar, null: false, foreign_key: true
      t.string :region_code, null: false
      t.integer :sun_requirement, default: 0
      t.integer :spacing_in_row_cm
      t.integer :spacing_between_rows_cm
      t.integer :sow_indoors_from_month
      t.integer :sow_indoors_to_month
      t.integer :sow_outdoors_from_month
      t.integer :sow_outdoors_to_month
      t.integer :harvest_from_month
      t.integer :harvest_to_month
      # frost_hardy is nullable (no default)
      t.boolean :frost_hardy
      t.text :notes

      t.timestamps
    end

    # Unique composite index - one profile per cultivar per region
    add_index :growing_profiles, [:region_code, :cultivar_id], 
              unique: true,
              name: "index_growing_profiles_on_region_and_cultivar"
  end
end
