class CropGroup < ApplicationRecord
  has_many :species, dependent: :restrict_with_exception
  
  validates :name, presence: true, uniqueness: true
end

