source "https://rubygems.org"

ruby "4.0.3"

RAILS_VERSION = "8.1.3"

gem "railties", RAILS_VERSION
gem "activesupport", RAILS_VERSION
gem "activemodel", RAILS_VERSION
gem "activerecord", RAILS_VERSION
gem "actionpack", RAILS_VERSION
gem "actionview", RAILS_VERSION

gem "sqlite3", "~> 2.9", ">= 2.9.3"
gem "puma", "~> 8.0", ">= 8.0.0"
gem "bootsnap", "~> 1.24", require: false
gem "csv"

group :development, :test do
  gem "debug", "~> 1.11", ">= 1.11.1", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", "~> 0.9", ">= 0.9.3", require: false
  gem "brakeman", "~> 8.0", ">= 8.0.4", require: false
  gem "rubocop-rails-omakase", "~> 1.1", ">= 1.1.0", require: false
end

group :development do
  gem "web-console", "~> 4.3", ">= 4.3.0"
end
