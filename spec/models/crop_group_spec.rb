require 'rails_helper'

RSpec.describe CropGroup, type: :model do
  describe "dependent: :restrict_with_exception on species" do
    it "prevents deletion when species exist" do
      crop_group = CropGroup.create!(name: "Legumes")
      Species.create!(common_name: "Pea", crop_group: crop_group)
      
      expect {
        crop_group.destroy
      }.to raise_error(ActiveRecord::DeleteRestrictionError)
      
      expect(CropGroup.exists?(crop_group.id)).to be true
    end

    it "allows deletion when no species exist" do
      crop_group = CropGroup.create!(name: "Empty Group")
      
      expect {
        crop_group.destroy
      }.not_to raise_error
      
      expect(CropGroup.exists?(crop_group.id)).to be false
    end
  end
end

