class Species < ApplicationRecord
  belongs_to :genus, optional: true
  belongs_to :crop_group, optional: true
  has_many :cultivars, dependent: :nullify
  
  enum :plant_type, {
    unknown: 0,
    vegetable: 1,
    herb: 2,
    fruit: 3,
    shrub: 4,
    tree: 5
  }
  
  enum :life_cycle, {
    unspecified: 0,
    annual: 1,
    biennial: 2,
    perennial: 3
  }
  
  validates :latin_name, uniqueness: { allow_nil: true }
  validate :has_name_or_latin_name
  
  private
  
  def has_name_or_latin_name
    if common_name.blank? && latin_name.blank?
      errors.add(:base, "Must have either common_name or latin_name")
    end
  end
end

