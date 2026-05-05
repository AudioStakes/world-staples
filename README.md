# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Metrics seed CSVs
- `db/seeds/staple_catalog_300_with_metrics.csv` is preferred.
- `db/seeds/ingredient_metrics.csv` and `db/seeds/metric_sources.csv` are imported when present.
- Seed order: staple catalog -> ingredient metrics -> metric sources.
- Metrics are starter estimates and require review.
- Source URLs are imported per staple metrics and source master rows.
- Limitations: coarse qualitative production/cultivation; calories depend on basis/preparation; price/popularity/deliciousness are approximate; importer is additive/update-only for taggings/aliases; no admin review workflow yet.
