class GrowingProfile < ApplicationRecord
  belongs_to :cultivar
  
  enum :sun_requirement, {
    unspecified: 0,
    full_sun: 1,
    part_shade: 2,
    shade: 3
  }
  
  validates :region_code, presence: true
  validates :cultivar_id, uniqueness: { scope: :region_code }
  
  # Helper method for month range queries that handle wraparound
  # e.g., October (10) to March (3) for overwintering
  def self.sowable_outdoors_in_month(month, region = nil)
    query = all
    query = query.where(region_code: region) if region
    
    query.where(
      "sow_outdoors_from_month IS NOT NULL AND sow_outdoors_to_month IS NOT NULL"
    ).select do |profile|
      if profile.sow_outdoors_from_month <= profile.sow_outdoors_to_month
        # Normal range: e.g., March (3) to June (6)
        month >= profile.sow_outdoors_from_month && month <= profile.sow_outdoors_to_month
      else
        # Wraparound range: e.g., October (10) to March (3)
        month >= profile.sow_outdoors_from_month || month <= profile.sow_outdoors_to_month
      end
    end
  end
  
  def self.sowable_indoors_in_month(month, region = nil)
    query = all
    query = query.where(region_code: region) if region
    
    query.where(
      "sow_indoors_from_month IS NOT NULL AND sow_indoors_to_month IS NOT NULL"
    ).select do |profile|
      if profile.sow_indoors_from_month <= profile.sow_indoors_to_month
        month >= profile.sow_indoors_from_month && month <= profile.sow_indoors_to_month
      else
        month >= profile.sow_indoors_from_month || month <= profile.sow_indoors_to_month
      end
    end
  end
  
  def self.harvestable_in_month(month, region = nil)
    query = all
    query = query.where(region_code: region) if region
    
    query.where(
      "harvest_from_month IS NOT NULL AND harvest_to_month IS NOT NULL"
    ).select do |profile|
      if profile.harvest_from_month <= profile.harvest_to_month
        month >= profile.harvest_from_month && month <= profile.harvest_to_month
      else
        month >= profile.harvest_from_month || month <= profile.harvest_to_month
      end
    end
  end
end

