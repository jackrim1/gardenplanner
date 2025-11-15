# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Example 1: Complete taxonomy data
# ===================================

# Crop Groups
legumes = CropGroup.find_or_create_by!(name: "Legumes") do |cg|
  cg.description = "Peas, beans and other nitrogen-fixing legumes. Improve soil for following crops."
  cg.rotation_years = 3
end

brassicas = CropGroup.find_or_create_by!(name: "Brassicas") do |cg|
  cg.description = "Cabbage family. Heavy feeders, benefit from nitrogen-rich soil."
  cg.rotation_years = 3
end

# Taxonomy
fabaceae = Family.find_or_create_by!(latin_name: "Fabaceae") do |f|
  f.name = "Legumes"
  f.notes = "Pea family - nitrogen-fixing plants"
end

vicia = Genus.find_or_create_by!(latin_name: "Vicia", family: fabaceae)

broad_bean = Species.find_or_create_by!(latin_name: "Vicia faba") do |s|
  s.common_name = "Broad bean"
  s.plant_type  = :vegetable
  s.life_cycle  = :annual
  s.description = "A cool-season legume grown for edible seeds. Hardy and reliable."
  s.genus       = vicia
  s.crop_group  = legumes
end

# Cultivars
aquadulce = Cultivar.find_or_create_by!(species: broad_bean, name: "Aquadulce Claudia") do |c|
  c.description          = "Reliable overwintering broad bean with long pods."
  c.days_to_maturity_min = 80
  c.days_to_maturity_max = 110
  c.height_cm            = 90
  c.spread_cm            = 30
  c.support_required     = true
end

the_sutton = Cultivar.find_or_create_by!(species: broad_bean, name: "The Sutton") do |c|
  c.description          = "Dwarf variety, ideal for small gardens and exposed sites."
  c.days_to_maturity_min = 90
  c.days_to_maturity_max = 100
  c.height_cm            = 45
  c.spread_cm            = 30
  c.support_required     = false
end

# Growing Profiles
GrowingProfile.find_or_create_by!(
  cultivar: aquadulce,
  region_code: "uk_south"
) do |gp|
  gp.sun_requirement         = :full_sun
  gp.spacing_in_row_cm       = 15
  gp.spacing_between_rows_cm = 45
  
  gp.sow_outdoors_from_month = 10  # October
  gp.sow_outdoors_to_month   = 11  # November
  gp.harvest_from_month      = 4   # April
  gp.harvest_to_month        = 6   # June
  
  gp.frost_hardy             = true
  gp.notes                   = "Best for autumn sowing. Protect from severe winds."
end

GrowingProfile.find_or_create_by!(
  cultivar: aquadulce,
  region_code: "uk_scotland"
) do |gp|
  gp.sun_requirement         = :full_sun
  gp.spacing_in_row_cm       = 15
  gp.spacing_between_rows_cm = 45
  
  gp.sow_indoors_from_month  = 2   # February
  gp.sow_indoors_to_month    = 3   # March
  gp.sow_outdoors_from_month = 4   # April
  gp.sow_outdoors_to_month   = 5   # May
  gp.harvest_from_month      = 7   # July
  gp.harvest_to_month        = 9   # September
  
  gp.frost_hardy             = true
  gp.notes                   = "Spring sowing recommended for colder regions."
end

GrowingProfile.find_or_create_by!(
  cultivar: the_sutton,
  region_code: "uk_south"
) do |gp|
  gp.sun_requirement         = :full_sun
  gp.spacing_in_row_cm       = 15
  gp.spacing_between_rows_cm = 30
  
  gp.sow_indoors_from_month  = 2   # February
  gp.sow_indoors_to_month    = 3   # March
  gp.sow_outdoors_from_month = 3   # March
  gp.sow_outdoors_to_month   = 6   # June
  gp.harvest_from_month      = 6   # June
  gp.harvest_to_month        = 9   # September
  
  gp.frost_hardy             = false
  gp.notes                   = "Compact variety, good for windy sites. No support needed."
end

# Example 2: Incomplete data from seed packet
# ============================================
# Demonstrates handling missing taxonomic data

# Just cultivar name and basic growing info (common for local/heritage varieties)
mystery_tomato = Cultivar.find_or_create_by!(name: "Granny's Red Tomato") do |c|
  c.description = "Heritage variety, sweet flavor"
  c.species = nil  # Don't know the exact species
end

# Can still add growing profile
GrowingProfile.find_or_create_by!(
  cultivar: mystery_tomato,
  region_code: "uk_south"
) do |gp|
  gp.sow_indoors_from_month = 3
  gp.sow_indoors_to_month = 4
  gp.harvest_from_month = 7
  gp.harvest_to_month = 9
  gp.notes = "From gran's garden, needs staking"
end

# Example 3: Partial taxonomy (common name only)
# ==============================================

# Create species with just common name (latin name unknown)
pumpkin = Species.find_or_create_by!(common_name: "Pumpkin") do |s|
  s.plant_type = :vegetable
  s.life_cycle = :annual
  s.genus = nil  # Could be Cucurbita maxima, moschata, or pepo - not specified
end

atlantic_giant = Cultivar.find_or_create_by!(name: "Atlantic Giant") do |c|
  c.species = pumpkin
  c.description = "Massive pumpkins for competitions"
end

puts "✅ Seed data loaded successfully!"
puts "   - #{CropGroup.count} crop groups"
puts "   - #{Family.count} families"
puts "   - #{Genus.count} genera"
puts "   - #{Species.count} species"
puts "   - #{Cultivar.count} cultivars"
puts "   - #{GrowingProfile.count} growing profiles"
