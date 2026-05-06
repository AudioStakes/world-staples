# README

## Metrics data and seed behavior

This project seeds staple and metric data from CSV files under `db/seeds`.

### Primary CSVs
- `db/seeds/staple_catalog_300_with_metrics.csv` (preferred staple catalog)
- `db/seeds/ingredient_metrics.csv`
- `db/seeds/metric_sources.csv`

Fallback:
- If the 300-row file is missing, seeds fallback to `db/seeds/staple_catalog.csv`.

### Seed import order
1. Staple catalog import (`staple_catalog_300_with_metrics.csv` preferred)
2. Ingredient metrics import (`ingredient_metrics.csv` if present)
3. Metric sources import (`metric_sources.csv` if present)

### Metric table roles
- `staple_metrics`: per-staple metric attributes (calories, price, satiety, storage, popularity, etc.)
- `ingredient_metrics`: per-ingredient baseline metrics and notes
- `metric_sources`: metric provenance metadata

### Data quality and limitations
- Metrics are **starter estimates** and require ongoing review.
- Calories depend on preparation method and stated basis.
- Production/cultivation values are qualitative, not strict quantitative measurements.
- Price/popularity/deliciousness are approximate guidance.
- Importers are additive/update-oriented; taggings/aliases are not fully destructive-sync.
- There is currently no admin moderation/review workflow UI.

## Local setup / run

- `bin/rails db:setup`
- `bin/rails db:seed`
- `bin/rails server`
- `bin/rails test`
