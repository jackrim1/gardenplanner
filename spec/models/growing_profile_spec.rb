require 'rails_helper'

RSpec.describe GrowingProfile, type: :model do
  let(:cultivar) { Cultivar.create!(name: "Test Plant") }
  
  describe ".sowable_outdoors_in_month" do
    context "normal range (no wraparound)" do
      let!(:profile) do
        GrowingProfile.create!(
          cultivar: cultivar,
          region_code: "uk_south",
          sow_outdoors_from_month: 3,  # March
          sow_outdoors_to_month: 6     # June
        )
      end

      it "includes months within range" do
        expect(GrowingProfile.sowable_outdoors_in_month(3)).to include(profile)
        expect(GrowingProfile.sowable_outdoors_in_month(4)).to include(profile)
        expect(GrowingProfile.sowable_outdoors_in_month(6)).to include(profile)
      end

      it "excludes months outside range" do
        expect(GrowingProfile.sowable_outdoors_in_month(2)).not_to include(profile)
        expect(GrowingProfile.sowable_outdoors_in_month(7)).not_to include(profile)
      end
    end

    context "wraparound range (overwintering)" do
      let!(:profile) do
        GrowingProfile.create!(
          cultivar: cultivar,
          region_code: "uk_south",
          sow_outdoors_from_month: 10,  # October
          sow_outdoors_to_month: 3      # March
        )
      end

      it "includes late months (Oct-Dec)" do
        expect(GrowingProfile.sowable_outdoors_in_month(10)).to include(profile)
        expect(GrowingProfile.sowable_outdoors_in_month(11)).to include(profile)
        expect(GrowingProfile.sowable_outdoors_in_month(12)).to include(profile)
      end

      it "includes early months (Jan-Mar)" do
        expect(GrowingProfile.sowable_outdoors_in_month(1)).to include(profile)
        expect(GrowingProfile.sowable_outdoors_in_month(2)).to include(profile)
        expect(GrowingProfile.sowable_outdoors_in_month(3)).to include(profile)
      end

      it "excludes months in the gap (Apr-Sep)" do
        expect(GrowingProfile.sowable_outdoors_in_month(4)).not_to include(profile)
        expect(GrowingProfile.sowable_outdoors_in_month(7)).not_to include(profile)
        expect(GrowingProfile.sowable_outdoors_in_month(9)).not_to include(profile)
      end
    end

    context "edge cases" do
      it "handles profiles with NULL months" do
        GrowingProfile.create!(
          cultivar: cultivar,
          region_code: "uk_south",
          sow_outdoors_from_month: nil,
          sow_outdoors_to_month: nil
        )
        expect(GrowingProfile.sowable_outdoors_in_month(5).count).to eq(0)
      end

      it "filters by region when specified" do
        south = GrowingProfile.create!(
          cultivar: cultivar,
          region_code: "uk_south",
          sow_outdoors_from_month: 3,
          sow_outdoors_to_month: 6
        )
        
        other_cultivar = Cultivar.create!(name: "Other")
        north = GrowingProfile.create!(
          cultivar: other_cultivar,
          region_code: "uk_scotland",
          sow_outdoors_from_month: 3,
          sow_outdoors_to_month: 6
        )
        
        results = GrowingProfile.sowable_outdoors_in_month(4, "uk_south")
        expect(results).to include(south)
        expect(results).not_to include(north)
      end
    end
  end

  describe ".sowable_indoors_in_month" do
    it "handles wraparound correctly" do
      profile = GrowingProfile.create!(
        cultivar: cultivar,
        region_code: "uk_south",
        sow_indoors_from_month: 11,
        sow_indoors_to_month: 2
      )
      
      expect(GrowingProfile.sowable_indoors_in_month(11)).to include(profile)
      expect(GrowingProfile.sowable_indoors_in_month(12)).to include(profile)
      expect(GrowingProfile.sowable_indoors_in_month(1)).to include(profile)
      expect(GrowingProfile.sowable_indoors_in_month(2)).to include(profile)
      expect(GrowingProfile.sowable_indoors_in_month(5)).not_to include(profile)
    end
  end

  describe ".harvestable_in_month" do
    it "handles wraparound correctly for year-round crops" do
      profile = GrowingProfile.create!(
        cultivar: cultivar,
        region_code: "uk_south",
        harvest_from_month: 10,
        harvest_to_month: 4
      )
      
      expect(GrowingProfile.harvestable_in_month(10)).to include(profile)
      expect(GrowingProfile.harvestable_in_month(1)).to include(profile)
      expect(GrowingProfile.harvestable_in_month(4)).to include(profile)
      expect(GrowingProfile.harvestable_in_month(6)).not_to include(profile)
    end
  end

  describe "unique composite index (region_code, cultivar_id)" do
    let(:cultivar) { Cultivar.create!(name: "Tomato") }
    
    it "allows different regions for same cultivar" do
      GrowingProfile.create!(cultivar: cultivar, region_code: "uk_south")
      GrowingProfile.create!(cultivar: cultivar, region_code: "uk_scotland")
      
      expect(cultivar.growing_profiles.count).to eq(2)
    end

    it "prevents duplicate region for same cultivar" do
      GrowingProfile.create!(cultivar: cultivar, region_code: "uk_south")
      
      expect {
        GrowingProfile.create!(cultivar: cultivar, region_code: "uk_south")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "allows same region for different cultivars" do
      other_cultivar = Cultivar.create!(name: "Carrot")
      
      GrowingProfile.create!(cultivar: cultivar, region_code: "uk_south")
      GrowingProfile.create!(cultivar: other_cultivar, region_code: "uk_south")
      
      expect(GrowingProfile.where(region_code: "uk_south").count).to eq(2)
    end
  end
end

