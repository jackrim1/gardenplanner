require 'rails_helper'

RSpec.describe "Optional Associations", type: :model do
  describe "creating records without parents" do
    it "creates Genus without Family" do
      genus = Genus.create!(latin_name: "Orphanus")
      expect(genus).to be_persisted
      expect(genus.family).to be_nil
    end

    it "creates Species without Genus" do
      species = Species.create!(common_name: "Mystery Plant")
      expect(species).to be_persisted
      expect(species.genus).to be_nil
    end

    it "creates Species without CropGroup" do
      species = Species.create!(common_name: "Ornamental")
      expect(species).to be_persisted
      expect(species.crop_group).to be_nil
    end

    it "creates Cultivar without Species" do
      cultivar = Cultivar.create!(name: "Unknown Variety")
      expect(cultivar).to be_persisted
      expect(cultivar.species).to be_nil
    end
  end

  describe "navigating incomplete taxonomy chains" do
    it "safely navigates from cultivar to family with missing links" do
      # Cultivar -> nil species
      cultivar = Cultivar.create!(name: "Orphan")
      expect(cultivar.species&.genus&.family).to be_nil
    end

    it "safely navigates with partial chain" do
      # Cultivar -> Species -> nil genus
      species = Species.create!(common_name: "Partial")
      cultivar = Cultivar.create!(name: "Test", species: species)
      
      expect(cultivar.species).to eq(species)
      expect(cultivar.species&.genus).to be_nil
      expect(cultivar.species&.genus&.family).to be_nil
    end

    it "navigates complete chain" do
      family = Family.create!(latin_name: "Fabaceae")
      genus = Genus.create!(latin_name: "Vicia", family: family)
      species = Species.create!(latin_name: "Vicia faba", genus: genus)
      cultivar = Cultivar.create!(name: "Aquadulce", species: species)
      
      expect(cultivar.species.genus.family).to eq(family)
    end
  end

  describe "querying incomplete data" do
    it "finds all cultivars without species" do
      with_species = Cultivar.create!(
        name: "Known",
        species: Species.create!(common_name: "Plant")
      )
      without_species = Cultivar.create!(name: "Unknown")
      
      orphans = Cultivar.where(species_id: nil)
      expect(orphans).to include(without_species)
      expect(orphans).not_to include(with_species)
    end

    it "finds all species without genus" do
      with_genus = Species.create!(
        common_name: "Complete",
        genus: Genus.create!(latin_name: "Test")
      )
      without_genus = Species.create!(common_name: "Incomplete")
      
      orphans = Species.where(genus_id: nil)
      expect(orphans).to include(without_genus)
      expect(orphans).not_to include(with_genus)
    end
  end
end

