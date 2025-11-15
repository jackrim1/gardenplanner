class CreateFamilies < ActiveRecord::Migration[7.2]
  def change
    create_table :families do |t|
      t.string :name
      t.string :latin_name
      t.text :notes

      t.timestamps
    end

    # Partial unique index - only enforce uniqueness when latin_name is present
    add_index :families, :latin_name, unique: true, where: "latin_name IS NOT NULL"
    add_index :families, :name
  end
end
