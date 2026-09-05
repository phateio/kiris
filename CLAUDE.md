# CLAUDE.md

> **Editing this file:** Consider the whole document before changing it — the right section, the right wording, the most essential form for every sentence. **Length limit: 200 lines** — trim or consolidate before adding.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Phate Radio (Rails application module `Kiris`) is an internet radio site for anime, game and J-pop
music. Rails does **not** stream audio — an external Icecast server does. Rails owns the track
database, the web UI and a JSON API; the streaming side drives it through the Bridge API
(`/bridge/*`), which is the busiest surface in production.

## The UGC removal: six tables have no models, on purpose

Issues, track/image comments and track migrations were deleted wholesale — models, controllers,
helpers, views, routes, tests and fixtures, 82 files. **Their six PostgreSQL tables were deliberately
kept, every row intact: `issues`, `issue_replies`, `track_comments`, `image_comments`,
`track_migrations`, `track_migration_comments`.** They are the backup that makes the removal
reversible; `db/structure.sql` still declares them and `db/migrate/` still creates them on a fresh
setup. **Do not drop them as orphan cleanup, and do not regenerate models to match them.** Both are wrong.

Fallout already in the tree: `app/mailers/` holds only `.keep` (`SystemMailer` went with the issue
notifications), so the `action_mailer` SMTP block in `config/environments/production.rb` is vestigial;
`Admin::TracksController#confirm` no longer records its field-diff changelog as a `Changelog`-nicknamed
`TrackComment`; and `Track#editable?`, `Lyric#editable?` and `Image#image_editable?` have no callers left.

## Versions

| Thing | Reality |
| --- | --- |
| Ruby | 2.5.9, consistent across `.ruby-version`, `Gemfile` and `Dockerfile`. |
| Rails | `Gemfile` asks `~> 4.2.5`; `Gemfile.lock` pins **4.2.10**. Bundler 1.17.3. |
| Database | PostgreSQL only. Schema lives in `db/structure.sql` (`config.active_record.schema_format = :sql`) — never regenerate a `schema.rb`. |
| Cache | `:redis_store` in production, `:memory_store` in development. `$redis` is **nil outside production** (`config/initializers/redis.rb`). |

Rails/Ruby upgrades have a mandatory procedure in `README.md` ("Rails Upgrade Guidelines"): one
major version at a time, apply the full railsdiff, stop and ask on any conflict.

## Commands

```bash
bundle install
bundle exec rake db:create db:migrate db:seed   # first-time setup
rails server                                    # dev server on :3000
bundle exec rubocop                             # lint (development-group gem)

bundle exec rake db:test:prepare
bundle exec rake test                                                 # full suite
bundle exec rake test TEST=test/models/track_test.rb TESTOPTS="-n /validations/"   # one file / one test
```

There is no `rails test` runner — that arrived in Rails 5; the rake task reads `TEST` / `TESTOPTS`.
Tests are Minitest with `fixtures :all` and one helper, `authenticate_member` (`test/test_helper.rb`),
which just sets `session[:access] = 5`. **27 of the 53 test files are empty generator stubs** —
`.github/workflows/ci.yml` does run `rubocop` and `rake db:test:prepare test` on Ruby 2.5.9 against a
PostgreSQL service, on every PR and every push to `master`, but a green run proves less than it looks.

## Routing conventions

`config/routes.rb` deliberately breaks REST in the `admin` and `upload` namespaces: **`POST` goes to
a `new` path and `PATCH` to an `edit` path**, mapped onto `create` / `update` actions.

```ruby
resources :tracks, except: [:create, :update] do
  post  'new'  => 'tracks#create', on: :collection, as: 'create'
  patch 'edit' => 'tracks#update', on: :member,     as: 'update'
end
```

Follow this shape for new admin/upload resources. Also:

- Subdomain constraints: `api.` forces `format: :json`; `gitio.` proxies git.io via `static#gitio_proxy`.
- Most public routes carry `format: false`, so `/search.json` is deliberately not a route.
- `/kernel/playlist` and friends are legacy aliases for old streaming clients — keep them working.
- **Routed but broken, both pre-existing:** `catalogs#show`, `#show_history` and `#diff` have routes
  but no actions (`CatalogsController` defines only `index`), and `Upload::AsinController#index` /
  `#show` exist while `app/views/upload/asin/` does not, so both raise `MissingTemplate`.

**The entire write surface fits in one paragraph.** Anonymous writes reach exactly three endpoints:
`POST /request` (song requests — the only live listener-facing write), `POST /login` and
`PATCH /preferences`. Every other write sits under `/admin/*` behind `authenticate` (access ≥ 5) or
`/bridge/*` behind the `secret_key` check. `upload/`, `tracks/:id/images`, `tracks/:id/lyrics` and
`/catalog` are read-only views of data that can no longer be created through the web UI.

## Authentication

Session-based and hand-rolled. **There is no Devise, and `Member` is a completely empty model** —
`MembersController#login` queries it directly and hashes with `Digest::SHA1(Digest::MD5(password))`.
Login sets `session[:identity] / [:nickname] / [:access]`; `ApplicationController#load_config!` reads
them back into `@identity`, `@nickname`, `@access` (defaulting to `0`). The admin gate is
`before_action :authenticate`, used by the four `app/controllers/admin/*` controllers and nowhere else.

`ApplicationController#authenticate` (`application_controller.rb:67`) is one line:
`render file: 'public/403.html', status: :forbidden, layout: false && return unless @access >= 5`.
`&&` binds tighter than the argument list, so `layout:` receives `false && return` → `false` and the
`return` is dead code. It works only because Rails halts the filter chain when a `before_action`
renders. Leave it alone or rewrite it properly — don't half-fix it.

## Custom pjax layer

Not turbolinks and not jquery-pjax: `app/assets/javascripts/pjax.js.coffee` plus header plumbing in
`ApplicationController`. Requests carrying `X-XHR-Referer` get `X-XHR-Route` and cache-busting
headers, and redirects travel as `X-XHR-Redirected-To` / `X-TOP-Redirected-To` via `x_redirect_to`
rather than a 302. Some actions *require* the header — `MembersController#index` renders 403 without
it — so a plain `curl` of the login page returning 403 is by design.

## `app/controllers/concerns/` is not Rails concerns

Those files define plain top-level classes and monkey patches, pulled in with `require 'cache_lock'` /
`require 'streammeta'` / `require 'yp_directory'`, never `include`. `cache_lock.rb` picks its
implementation at load time (`RedisLock` in production, `RailsLock` otherwise) and publishes it via
`Object.const_set('CacheLock', …)`, so call it as `CacheLock.synchronize(:playlist) { ... }`.
`streammeta.rb` adds `Integer#abbrtime`; `metacharacters.rb` adds `String#escape_sql_wildcard_characters`.

## Now-playing pipeline

1. The streaming server POSTs `/bridge/playlist` with a `secret_key` param checked against
   `$BRIDGE_SECRET_KEY` — not the session. Bridge controllers `skip_before_filter :verify_authenticity_token`.
2. `Bridge::PlaylistController#update` takes a **pessimistic row lock** (`playlist.with_lock`),
   rewrites `Playlist`, appends a `History` row, purges histories older than 30 days, then busts
   `Rails.cache.delete(:playlist)`. It also fires `Thread.new` calls to the danmaku service and the
   Xiph YP directory, and marks any non-`utaitedb.net` track `DELETED` once played.
3. `Json::PlaylistController#index` rebuilds the public payload inside
   `CacheLock.synchronize(:playlist)` and caches it until the current track ends.
4. `Json::RequestController#create` handles listener requests under `CacheLock.synchronize(:request)`
   with cooldown, duplicate-title and per-IP checks.

**Step 2's `DELETED` side effect is deliberate policy, not a bug — do not "fix" it.** Listener video
submissions were retired in favour of utaitedb.net as the sole source, and rather than purging them
outright each gets one farewell airing. `randlist` is `.utaitedb`-only, so only a request triggers it.
Two locks guard this path — Redis/cache lock for read rebuilds, DB row lock for writes; don't collapse them.

## Models

`Track` is the hub (`playlists`, `histories`, `images`, `lyric`). Rules that bite:

- **Status is a string column, not an enum.** `Track.status` is `'QUEUED'` / `'OK'` / `'DELETED'`;
  the `requestable` scope means `status == 'OK'` and is what gates playback. `Image.status` is
  `RANK_1`…`RANK_5` / `RANK_BAKA` and doubles as a quality rating.
- **Exactly one counter cache is still live:** `tracks.images_count`, driven by `Image belongs_to
  :track, counter_cache: true`. `tracks.track_comments_count`, `images.image_comments_count`,
  `issues.issue_replies_count` and `track_migrations.track_migration_comments_count` remain as
  columns with no association behind them — frozen at their last values; don't read or "repair" them.
- `SharedMethods#normalize_values` strips every String attribute in `before_validation`; `Track` also
  normalises its comma-joined `tags`.
- `Image` accepts only `//i.imgur.com/…` URLs (protocol stripped) with sources from
  Pixiv/piapro/NicoSeiga, and `cdn_url` rewrites them onto the app's own `/imgur/:id` proxy.

## Views: ERB *and* Slim

67 `.erb` against 26 `.slim` under `app/views` — ERB is the majority and the layout is ERB. The split
is per-subtree historical drift rather than a principled rule: Slim survives only in `default/` (all
8 files), most of `partials/` (16 of 19) and two stray partials in `admin/tracks/`; `search/`,
`admin/`, `upload/`, `images/`, `tracks/`, `notices/`, `members/`, `catalogs/` and `category/` are
ERB. **Match the neighbouring files in whichever directory you are editing** instead of converting.

## Environment variables

`config/initializers/environment_variables.rb` copies ENV into globals, and application code reads
the globals (`$BRIDGE_SECRET_KEY`), not `ENV[...]`: `ICECAST_SERVER`, `ICECAST_RELAYS`,
`OFFLINE_TRACK_ID`, `STATIC_SERVER_URL`, `BRIDGE_SECRET_KEY` (falling back to `KERNEL_SECRET_KEY`),
`DANMAKU_SECRET_KEY`, `PIXIV_AUTHORIZATION`. Production additionally needs `DATABASE_URL` and `REDIS_URL`.

`dotenv-rails` loads `.env` for the Rails process, but **`config/puma.rb` is read before Rails boots**,
so `RAILS_MAX_THREADS` and `PORT` must come from the real process environment.

## Deployment

Self-hosted Docker Compose. The image is `ruby:2.5.9-slim` (Debian buster, EOL — `sources.list`
repoints apt at `archive.debian.org`); `bundle install` runs frozen and **`rake assets:precompile`
runs at image build time**, so there is no deploy-time precompile step. Service `web` in
`compose.yaml` publishes `127.0.0.1:3030 -> 3000` (loopback only — front it with a reverse proxy),
reads secrets from the git-ignored `production.env` via `env_file`, and is capped at `cpus: 0.5` and
`mem_limit: 256m`. `config/puma.rb` keeps `workers` and `preload_app!` commented out, so Puma runs
**single mode with 5 threads** to fit that cap; `config/database.yml` uses `pool: 5` to match.
Enabling clustered mode means uncommenting both lines *and* raising the memory limit.

```bash
docker compose build
docker compose up -d
docker compose run --rm web bundle exec rake db:migrate
```

## Conventions and traps

- **No `# frozen_string_literal: true` anywhere in `app/` or `lib/`** — only `Gemfile` carries it.
  Don't add it as a "project standard"; it isn't one.
- `app/controllers/upload/asin_controller.rb` hardcodes live Amazon Product API credentials in plain
  source. Treat them as compromised pending rotation; never copy or echo the values.
- RuboCop 0.51 pins `TargetRubyVersion: 2.4` (it cannot parse 2.5.9) and excludes `db/`, `config/`, `script/`
  plus `vendor/`, `node_modules/` — `Exclude` *replaces* the defaults. Line length 120; `Documentation` off;
  `Style/ClassAndModuleChildren` off, which is why controllers are written `class Bridge::PlaylistController`.
  **`.rubocop_todo.yml` baselines 1,064 offenses**: a green `rubocop` means "no new offenses", not clean code.
- Locales are `en`, `ja`, `zh-Hans`, `zh-Hant`. `ApplicationController` maps `zh-TW/HK/MO` → `zh-Hant`
  and `zh-CN/SG/MY` → `zh-Hans`. `README.md` still links a localeapp project, but the gem and its
  config are long gone — hand-edit `config/locales/*.yml` freely; nothing will sync over it.
- `README.rdoc` is a 2015 stock Rails stub; `CONTRIBUTING.md` is deprecated; `README.md` is the live doc.
- The only project rake tasks: `tracks:create_or_update_by_utaitedb` and `images:create_or_update_from_pixiv`
  (`lib/tasks/`). Both call third-party APIs live and write to the database — don't run them casually.
