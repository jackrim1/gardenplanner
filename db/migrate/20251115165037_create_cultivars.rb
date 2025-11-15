class CreateCultivars < ActiveRecord::Migration[7.2]
  def change
    create_table :cultivars do |t|
      t.string :name, null: false
      t.string :marketing_name
      t.text :description
      t.integer :days_to_maturity_min
      t.integer :days_to_maturity_max
      t.integer :height_cm
      t.integer :spread_cm
      # support_required is nullable (no default)
      t.boolean :support_required
      
      # Species is optional
      t.references :species, null: true, foreign_key: true

      t.timestamps
    end

    add_index :cultivars, :name
  end
end
