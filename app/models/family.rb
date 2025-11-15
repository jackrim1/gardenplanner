class Family < ApplicationRecord
  has_many :genera, class_name: "Genus", dependent: :nullify
  
  validates :latin_name, uniqueness: { allow_nil: true }
  validate :has_name_or_latin_name
  
  private
  
  def has_name_or_latin_name
    if name.blank? && latin_name.blank?
      errors.add(:base, "Must have either name or latin_name")
    end
  end
end

