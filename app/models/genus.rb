class Genus < ApplicationRecord
  self.table_name = "genera"
  
  belongs_to :family, optional: true
  has_many :species, dependent: :nullify
  
  validates :latin_name, presence: true
  validates :latin_name, uniqueness: { scope: :family_id, allow_nil: true }
end

