require 'rails_helper'

RSpec.describe Species, type: :model do
  describe "partial unique index on latin_name" do
    it "allows multiple species with NULL latin_name" do
      Species.create!(common_name: "Tomato")
      Species.create!(common_name: "Potato")
      expect(Species.where(latin_name: nil).count).to eq(2)
    end

    it "prevents duplicate latin_names when present" do
      Species.create!(common_name: "Broad bean", latin_name: "Vicia faba")
      duplicate = Species.new(common_name: "Fava bean", latin_name: "Vicia faba")
      expect {
        duplicate.save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "dependent: :nullify on cultivars" do
    it "nullifies cultivar.species_id when species is deleted" do
      species = Species.create!(common_name: "Tomato")
      cultivar = Cultivar.create!(name: "Beefsteak", species: species)
      
      species.destroy
      
      cultivar.reload
      expect(cultivar.species_id).to be_nil
      expect(Cultivar.exists?(cultivar.id)).to be true
    end
  end

  describe "composite validation: common_name or latin_name" do
    it "valid with only common_name" do
      species = Species.new(common_name: "Tomato")
      expect(species).to be_valid
    end

    it "valid with only latin_name" do
      species = Species.new(latin_name: "Solanum lycopersicum")
      expect(species).to be_valid
    end

    it "valid with both" do
      species = Species.new(
        common_name: "Tomato",
        latin_name: "Solanum lycopersicum"
      )
      expect(species).to be_valid
    end

    it "invalid with neither" do
      species = Species.new(description: "A plant")
      expect(species).not_to be_valid
      expect(species.errors[:base]).to include("Must have either common_name or latin_name")
    end
  end
end

