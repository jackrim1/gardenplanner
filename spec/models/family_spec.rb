require 'rails_helper'

RSpec.describe Family, type: :model do
  describe "partial unique index on latin_name" do
    it "allows multiple families with NULL latin_name" do
      Family.create!(name: "Family 1", latin_name: nil)
      Family.create!(name: "Family 2", latin_name: nil)
      expect(Family.where(latin_name: nil).count).to eq(2)
    end

    it "prevents duplicate latin_names when present" do
      Family.create!(name: "Legumes", latin_name: "Fabaceae")
      duplicate = Family.new(name: "Peas", latin_name: "Fabaceae")
      expect {
        duplicate.save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows one NULL and one present latin_name" do
      Family.create!(name: "Family 1", latin_name: nil)
      Family.create!(name: "Legumes", latin_name: "Fabaceae")
      expect(Family.count).to eq(2)
    end
  end

  describe "dependent: :nullify on genera" do
    it "nullifies genus.family_id when family is deleted" do
      family = Family.create!(name: "Fabaceae")
      genus = Genus.create!(latin_name: "Vicia", family: family)
      
      family.destroy
      
      genus.reload
      expect(genus.family_id).to be_nil
      expect(Genus.exists?(genus.id)).to be true
    end

    it "handles multiple genera" do
      family = Family.create!(name: "Fabaceae")
      genus1 = Genus.create!(latin_name: "Vicia", family: family)
      genus2 = Genus.create!(latin_name: "Pisum", family: family)
      
      family.destroy
      
      expect(Genus.where(id: [genus1.id, genus2.id]).pluck(:family_id)).to all(be_nil)
    end
  end

  describe "composite validation: name or latin_name" do
    it "valid with only name" do
      family = Family.new(name: "Legumes")
      expect(family).to be_valid
    end

    it "valid with only latin_name" do
      family = Family.new(latin_name: "Fabaceae")
      expect(family).to be_valid
    end

    it "valid with both" do
      family = Family.new(name: "Legumes", latin_name: "Fabaceae")
      expect(family).to be_valid
    end

    it "invalid with neither" do
      family = Family.new(notes: "Just notes")
      expect(family).not_to be_valid
      expect(family.errors[:base]).to include("Must have either name or latin_name")
    end
  end
end

