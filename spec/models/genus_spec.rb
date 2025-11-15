require 'rails_helper'

RSpec.describe Genus, type: :model do
  describe "composite partial unique index" do
    let!(:family) { Family.create!(name: "Fabaceae") }
    
    it "allows same latin_name in different families" do
      Genus.create!(latin_name: "Vicia", family: family)
      other_family = Family.create!(name: "Other")
      Genus.create!(latin_name: "Vicia", family: other_family)
      expect(Genus.where(latin_name: "Vicia").count).to eq(2)
    end

    it "prevents duplicate latin_name within same family" do
      Genus.create!(latin_name: "Vicia", family: family)
      duplicate = Genus.new(latin_name: "Vicia", family: family)
      expect {
        duplicate.save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows multiple genera with same latin_name and NULL family_id" do
      Genus.create!(latin_name: "Vicia", family: nil)
      Genus.create!(latin_name: "Vicia", family: nil)
      expect(Genus.where(latin_name: "Vicia", family_id: nil).count).to eq(2)
    end

    it "allows same latin_name with NULL family_id and present family_id" do
      Genus.create!(latin_name: "Vicia", family: nil)
      Genus.create!(latin_name: "Vicia", family: family)
      expect(Genus.where(latin_name: "Vicia").count).to eq(2)
    end
  end

  describe "table name override" do
    it "uses 'genera' as table name" do
      expect(Genus.table_name).to eq("genera")
    end

    it "queries the correct table" do
      genus = Genus.create!(latin_name: "Vicia")
      expect(Genus.find(genus.id)).to eq(genus)
    end

    it "works with associations from other models" do
      family = Family.create!(name: "Fabaceae")
      genus = Genus.create!(latin_name: "Vicia", family: family)
      
      expect(family.genera).to include(genus)
    end

    it "works with foreign key references" do
      genus = Genus.create!(latin_name: "Vicia")
      species = Species.create!(common_name: "Bean", genus: genus)
      
      expect(species.genus).to eq(genus)
      expect(genus.species).to include(species)
    end
  end
end

