# world-staples

## Rails 8.1 + SQLite scaffold attempt log (2026-05-04 UTC)

The environment still cannot reach required external hosts, so `rails new` could not be executed.

### Failed command

```bash
gem install rails -v '~> 8.1.0' --no-document
```

Result: `403 "Forbidden"` from RubyGems HTTP fetch.

### HTTP 403 URLs

- `https://rubygems.org`
- `https://github.com`

### bundle config

```
Settings are listed in order of priority. The top value will be used.
```

### gem sources

```
*** CURRENT SOURCES ***

https://rubygems.org/
```
