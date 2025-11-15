require 'rails_helper'

RSpec.describe Cultivar, type: :model do
  describe "dependent: :restrict_with_exception on growing_profiles" do
    it "prevents deletion when growing profiles exist" do
      cultivar = Cultivar.create!(name: "Tomato")
      GrowingProfile.create!(cultivar: cultivar, region_code: "uk_south")
      
      expect {
        cultivar.destroy
      }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end

    it "allows deletion when no growing profiles exist" do
      cultivar = Cultivar.create!(name: "Tomato")
      
      expect {
        cultivar.destroy
      }.not_to raise_error
    end
  end
end

