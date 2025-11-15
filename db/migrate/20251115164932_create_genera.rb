class CreateGenera < ActiveRecord::Migration[7.2]
  def change
    create_table :genera do |t|
      t.string :latin_name
      # Make family_id nullable (optional relationship)
      t.references :family, null: true, foreign_key: true

      t.timestamps
    end
    
    # Partial unique composite index - enforce uniqueness only when both are present
    add_index :genera, [:family_id, :latin_name], 
              unique: true, 
              where: "family_id IS NOT NULL AND latin_name IS NOT NULL",
              name: "index_genera_on_family_and_latin_name"
  end
end
