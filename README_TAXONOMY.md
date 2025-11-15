# Garden Planner Taxonomy System

A flexible plant taxonomy system designed for gardeners, not botanists. You can start with just a cultivar name (what's on your seed packet) and fill in botanical details later.

## The Big Picture

The system has two main parts:

1. **Botanical Taxonomy** (optional, can be filled in later)
   - Family → Genus → Species → Cultivar
   
2. **Practical Gardening Data** (what you actually need)
   - CropGroup (for crop rotation)
   - GrowingProfile (when to sow, harvest, spacing, etc.)

## Example: Adding a Maris Piper Potato

Let's walk through adding a Maris Piper potato to your garden planner.

### Step 1: Create the Cultivar (Required)

This is the only thing you **must** have - the variety name:

```ruby
maris_piper = Cultivar.create!(
  name: "Maris Piper",
  description: "Versatile maincrop potato, excellent for chips and roasting",
  days_to_maturity_min: 120,
  days_to_maturity_max: 140,
  height_cm: 60
)
```

✅ **Done!** You can stop here and add a growing profile. The potato is in your system.

### Step 2: Add Species (Optional)

If you know the species, add it:

```ruby
potato = Species.find_or_create_by!(latin_name: "Solanum tuberosum") do |s|
  s.common_name = "Potato"
  s.plant_type = :vegetable
  s.life_cycle = :annual
  s.description = "Tuberous crop, member of nightshade family"
end

# Link the cultivar to the species
maris_piper.update!(species: potato)
```

### Step 3: Add Botanical Hierarchy (Optional)

If you want the full botanical classification:

```ruby
# Family
solanaceae = Family.find_or_create_by!(latin_name: "Solanaceae") do |f|
  f.name = "Nightshades"
  f.notes = "Includes potatoes, tomatoes, peppers, eggplants"
end

# Genus
solanum = Genus.find_or_create_by!(latin_name: "Solanum", family: solanaceae)

# Update species to include genus
potato.update!(genus: solanum)
```

### Step 4: Add Crop Rotation Group (Recommended)

For crop rotation planning:

```ruby
solanaceae_group = CropGroup.find_or_create_by!(name: "Solanaceae") do |cg|
  cg.description = "Nightshade family. Don't plant in same spot more than once every 3 years."
  cg.rotation_years = 3
end

potato.update!(crop_group: solanaceae_group)
```

### Step 5: Add Growing Profile (The Useful Stuff!)

This is where the gardening magic happens:

```ruby
GrowingProfile.create!(
  cultivar: maris_piper,
  region_code: "uk_south",
  
  # When to plant
  sow_indoors_from_month: 2,    # February
  sow_indoors_to_month: 4,      # April
  sow_outdoors_from_month: 4,   # April
  sow_outdoors_to_month: 5,     # May
  
  # When to harvest
  harvest_from_month: 8,         # August
  harvest_to_month: 10,          # October
  
  # Growing conditions
  sun_requirement: :full_sun,
  spacing_in_row_cm: 30,
  spacing_between_rows_cm: 60,
  frost_hardy: false,
  
  notes: "Earth up regularly. Ready when foliage dies back."
)
```

### Different Region? Add Another Profile!

```ruby
GrowingProfile.create!(
  cultivar: maris_piper,
  region_code: "uk_scotland",
  
  # Later planting in Scotland
  sow_outdoors_from_month: 5,   # May
  sow_outdoors_to_month: 6,     # June
  harvest_from_month: 9,         # September
  harvest_to_month: 10,          # October
  
  sun_requirement: :full_sun,
  spacing_in_row_cm: 30,
  spacing_between_rows_cm: 60,
  frost_hardy: false,
  notes: "Wait until soil warms up in Scotland. Watch for late frosts."
)
```

## Complete Taxonomy Chain

Now you have:

```
Family: Solanaceae (Nightshades)
  └─ Genus: Solanum
      └─ Species: Solanum tuberosum (Potato)
          └─ Cultivar: Maris Piper
              ├─ Growing Profile (UK South)
              └─ Growing Profile (UK Scotland)

Crop Group: Solanaceae (for rotation planning)
```

## Querying Your Data

### Find what to plant this month

```ruby
# What can I sow outdoors in April in UK South?
profiles = GrowingProfile.sowable_outdoors_in_month(4, "uk_south")
profiles.each do |profile|
  puts profile.cultivar.name
end
# => "Maris Piper"
```

### Find what to harvest

```ruby
# What can I harvest in September?
profiles = GrowingProfile.harvestable_in_month(9, "uk_south")
profiles.each do |profile|
  species = profile.cultivar.species&.common_name || "Unknown"
  puts "#{species} - #{profile.cultivar.name}"
end
# => "Potato - Maris Piper"
```

### Navigate the taxonomy

```ruby
maris_piper = Cultivar.find_by(name: "Maris Piper")

# Go up the hierarchy (safe navigation handles missing links)
maris_piper.species&.common_name           # => "Potato"
maris_piper.species&.genus&.latin_name     # => "Solanum"
maris_piper.species&.genus&.family&.name   # => "Nightshades"

# Crop rotation
maris_piper.species&.crop_group&.name      # => "Solanaceae"
maris_piper.species&.crop_group&.rotation_years  # => 3
```

### Find all potatoes

```ruby
potato = Species.find_by(common_name: "Potato")
potato.cultivars.pluck(:name)
# => ["Maris Piper", "Charlotte", "King Edward", ...]
```

### Crop rotation planning

```ruby
# Find all vegetables in the nightshade rotation group
solanaceae = CropGroup.find_by(name: "Solanaceae")
solanaceae.species.pluck(:common_name)
# => ["Potato", "Tomato", "Pepper", "Eggplant"]
```

## The Flexible Approach: Starting Simple

You find a packet of "Gran's Mystery Tomato" at a seed swap. You don't know the variety or species details:

```ruby
# Just create the cultivar
mystery = Cultivar.create!(
  name: "Gran's Mystery Tomato",
  description: "Heritage variety from seed swap"
)

# Add growing info from the packet
GrowingProfile.create!(
  cultivar: mystery,
  region_code: "uk_south",
  sow_indoors_from_month: 3,
  sow_indoors_to_month: 4,
  harvest_from_month: 7,
  harvest_to_month: 9,
  notes: "Needs staking"
)
```

✅ **Done!** You can garden with this info.

Later, if you identify it, just add the species:

```ruby
tomato = Species.find_by(common_name: "Tomato")
mystery.update!(species: tomato)
```

## Month Wraparound (Overwintering Crops)

Some crops are sown in autumn and harvested in spring:

```ruby
# Broad beans - sow October to November, harvest April to June
GrowingProfile.create!(
  cultivar: aquadulce,
  region_code: "uk_south",
  sow_outdoors_from_month: 10,  # October
  sow_outdoors_to_month: 11,    # November
  harvest_from_month: 4,         # April
  harvest_to_month: 6,           # June
  frost_hardy: true
)

# Query works across year boundary
GrowingProfile.sowable_outdoors_in_month(10, "uk_south")  # ✅ Includes broad beans
GrowingProfile.sowable_outdoors_in_month(11, "uk_south")  # ✅ Includes broad beans
GrowingProfile.sowable_outdoors_in_month(12, "uk_south")  # ❌ Outside range
GrowingProfile.sowable_outdoors_in_month(1, "uk_south")   # ❌ Outside range
```

## Data Quality: Finding Gaps

```ruby
# Find cultivars without species info (candidates for enrichment)
Cultivar.where(species_id: nil).pluck(:name)
# => ["Gran's Mystery Tomato", "Old Packet from Shed"]

# Find species without genus (incomplete taxonomy)
Species.where(genus_id: nil).pluck(:common_name)
# => ["Pumpkin", "Squash"]

# Find cultivars with growing profiles but no species
Cultivar.joins(:growing_profiles)
        .where(species_id: nil)
        .pluck(:name)
```

## Key Design Principles

### 1. Bottom-Up Data Entry
Start with what you have (cultivar name on seed packet), add details later.

### 2. No False Precision
If you don't know the botanical name, leave it blank. Better to have `nil` than wrong data.

### 3. Practical Over Academic
This is for gardeners first, botanists second. Common names are as valid as Latin names.

### 4. Incremental Enrichment
Data can be improved over time. Start simple, add detail as it becomes available.

### 5. Region-Specific Growing Data
Different regions = different growing seasons. One cultivar can have multiple growing profiles.

## Real-World Scenarios

### Scenario 1: Buying Seeds at Garden Centre
```ruby
# Packet says: "Carrot - Chantenay Red Cored"
# Back says: Sow March-July, Harvest June-October

cultivar = Cultivar.create!(name: "Chantenay Red Cored")

GrowingProfile.create!(
  cultivar: cultivar,
  region_code: "uk_south",
  sow_outdoors_from_month: 3,
  sow_outdoors_to_month: 7,
  harvest_from_month: 6,
  harvest_to_month: 10
)
```

### Scenario 2: Seed Catalog with Full Details
```ruby
# Catalog gives you everything: Tomato (Solanum lycopersicum) 'San Marzano'

# Create the full hierarchy
species = Species.find_or_create_by!(
  latin_name: "Solanum lycopersicum",
  common_name: "Tomato"
)

cultivar = Cultivar.create!(
  name: "San Marzano",
  species: species,
  description: "Italian plum tomato, perfect for sauces",
  days_to_maturity_min: 80,
  days_to_maturity_max: 90,
  height_cm: 150,
  support_required: true
)

GrowingProfile.create!(
  cultivar: cultivar,
  region_code: "uk_south",
  sow_indoors_from_month: 3,
  sow_indoors_to_month: 4,
  harvest_from_month: 7,
  harvest_to_month: 9,
  sun_requirement: :full_sun,
  spacing_in_row_cm: 45,
  spacing_between_rows_cm: 60
)
```

### Scenario 3: Planning Crop Rotation
```ruby
# Year 1: Where did I plant brassicas?
bed_a_species = Species.where(crop_group: brassicas_group)

# Year 2: Don't plant brassicas in bed A
# Year 3: Don't plant brassicas in bed A
# Year 4: OK to plant brassicas in bed A again

rotation = brassicas_group.rotation_years  # => 3
```

## Summary

The Garden Planner taxonomy is designed to be **flexible** and **forgiving**:

- ✅ Only cultivar name is required
- ✅ Everything else is optional
- ✅ Fill in details when you have them
- ✅ Works with incomplete data
- ✅ Handles real-world gardening scenarios
- ✅ Supports crop rotation planning
- ✅ Region-specific growing data

Start simple. Grow as you learn. Just like your garden! 🌱

