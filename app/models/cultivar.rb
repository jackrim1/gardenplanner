class Cultivar < ApplicationRecord
  belongs_to :species, optional: true
  has_many :growing_profiles, dependent: :restrict_with_exception
  
  validates :name, presence: true
end

