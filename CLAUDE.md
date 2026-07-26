# CLAUDE.md - AI Assistant Guide for Kiris (Phate Radio)

This document provides comprehensive guidance for AI assistants working on the Kiris/Phate Radio codebase.

## Project Overview

**Phate Radio** (Kiris) is an internet radio streaming platform specializing in anime, games, and Japanese pop music. The application manages a music library primarily sourced from NicoNico Douga (Japanese video sharing platform) and integrates with utaitedb.net for track metadata.

**Core Features:**
- Live streaming radio with Icecast integration
- Track database with rich metadata (artist, album, tags, lyrics)
- User-submitted artwork/images from Pixiv
- Community features (comments, issues/feedback)
- Multi-language support (English, Japanese, Simplified/Traditional Chinese)
- Content moderation workflow (QUEUED → reviewed → OK/DELETED)
- Bridge API for streaming server integration

**License:** MIT

## Contributing Guidelines

**IMPORTANT:** Before making any code changes, please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code standards and style guidelines (RuboCop, ESLint, etc.)
- Commit message conventions (Conventional Commits)
- Pre-commit workflow and linter requirements
- Language and documentation standards

The CONTRIBUTING.md file is the source of truth for all contribution standards and must be followed for all code changes.

## Technology Stack

### Core Framework
- **Ruby:** 2.5.9 (defined in Gemfile, note: .ruby-version shows 2.5.8 but Gemfile uses 2.5.9)
- **Rails:** 4.2.5
- **Database:** PostgreSQL (with structure.sql format, not schema.rb)
- **Cache:** Redis (production only)
- **Web Server:** Puma 5.6.9 (single mode / 0 workers, 5 threads by default; clustered mode is opt-in by uncommenting `workers`/`preload_app!` in `config/puma.rb` and setting `WEB_CONCURRENCY`)

### Key Dependencies
- **Templates:** Slim (slim-rails)
- **Forms:** SimpleForm with Foundation integration
- **Authentication:** Custom session-based (no Devise)
- **Search:** Ransack
- **Markdown:** Redcarpet with CodeRay syntax highlighting
- **HTTP Client:** HTTParty
- **Pagination:** Kaminari
- **Frontend:** Foundation framework, Font Awesome, jQuery
- **Asset Gems:** jPlayer (HTML5 audio), NProgress, Intro.js
- **Cloud Storage:** fog-google (Google Cloud Platform)
- **CORS:** rack-cors

### External Services Integration
- **NicoNico Douga:** Video/music source
- **utaitedb.net:** Track metadata API
- **Pixiv:** Artwork sourcing
- **Amazon Product API:** ASIN-based track import
- **Imgur:** Image CDN
- **Icecast:** Streaming server
- **Xiph YP Directory:** Stream listing

## Codebase Structure

```
kiris/
├── app/
│   ├── assets/
│   │   ├── javascripts/    # CoffeeScript files (player, timer, danmaku, pjax, chatroom)
│   │   ├── stylesheets/    # Sass/SCSS with Foundation framework
│   │   └── images/
│   ├── controllers/
│   │   ├── concerns/       # CacheLock, CodeRayify, Streammeta, YPDirectory
│   │   ├── admin/          # Admin namespace (tracks, images, playlist, migrations, notices)
│   │   ├── upload/         # Upload namespace (asin, niconico)
│   │   ├── bridge/         # Bridge API (playlist, tracks, caches)
│   │   ├── json/           # JSON API (playlist, status, request)
│   │   ├── tracks/         # Nested (comments, images, lyrics)
│   │   └── images/         # Nested (comments)
│   ├── models/
│   │   ├── concerns/       # SharedMethods (value normalization)
│   │   ├── track.rb        # Central model
│   │   ├── image.rb        # Artwork/covers
│   │   ├── playlist.rb     # Current/queued tracks
│   │   ├── history.rb      # Play history
│   │   ├── track_migration.rb  # Staging for track changes
│   │   ├── issue.rb        # Feedback system
│   │   ├── catalog.rb      # Wiki with versioning
│   │   ├── member.rb       # User authentication
│   │   └── [comments, lyric, category, notice].rb
│   ├── views/              # Slim templates organized by controller
│   ├── helpers/
│   └── mailers/
├── config/
│   ├── routes.rb           # Routing with subdomain constraints
│   ├── application.rb      # Main app config
│   ├── database.yml        # PostgreSQL config
│   ├── puma.rb            # Web server config
│   ├── initializers/      # Redis, session, environment variables, etc.
│   ├── locales/           # i18n files (en, ja, zh-Hans, zh-Hant)
│   └── environments/
├── db/
│   ├── migrate/           # Database migrations
│   ├── structure.sql      # PostgreSQL schema (NOT schema.rb)
│   └── seeds.rb
├── lib/
│   └── tasks/             # Rake tasks (tracks.rake, images.rake)
├── test/                  # Minitest suite
│   ├── controllers/
│   ├── models/
│   ├── fixtures/
│   ├── helpers/
│   ├── integration/
│   └── mailers/
├── public/
├── vendor/
├── .github/
│   └── workflows/         # Gemini CLI workflows
├── Gemfile
├── Dockerfile            # Container image (ruby:2.5.9-slim / Debian buster)
├── compose.yaml          # Docker Compose service
├── sources.list          # Debian buster apt repos (archive.debian.org)
├── .rubocop.yml          # Code style rules
└── .travis.yml           # Travis CI config
```

## Database Schema and Models

### Core Models and Relationships

#### Track (Central Model)
- **Location:** `app/models/track.rb`
- **Key Fields:** title, artist, album, tags, duration, szhash (file hash), niconico (video ID), asin (Amazon ID), status, uploader
- **Relationships:**
  - `has_many :playlists` (play history)
  - `has_many :histories` (broadcast history)
  - `has_many :images` (cover art)
  - `has_many :track_comments`
  - `has_one :lyric`
- **Important Scopes:** requestable, utaitedb, niconico_tracks, utattemita (cover songs)
- **Status Values:** QUEUED, OK, DELETED

#### Image
- **Location:** `app/models/image.rb`
- **Key Fields:** url, source, illustrator, status, verified, rate
- **Validates:** URLs from Imgur, sources from Pixiv/Piapro/NicoSeiga
- **Relationships:** `belongs_to :track`, `has_many :image_comments`
- **Rating System:** RANK_1 through RANK_5, RANK_BAKA

#### Playlist
- **Location:** `app/models/playlist.rb`
- **Purpose:** Manages current and queued tracks
- **Key Fields:** playedtime, track_id, nickname, userip
- **Note:** Uses pessimistic locking for updates

#### History
- **Location:** `app/models/history.rb`
- **Purpose:** Play history (cleaned up after 30 days)
- **Relationships:** `belongs_to :track`

#### TrackMigration
- **Location:** `app/models/track_migration.rb`
- **Purpose:** Staging area for reviewing track changes before committing
- **Workflow:** Create → Review → Transfer to Track model

#### Member
- **Location:** `app/models/member.rb`
- **Authentication:** Username, password hash, identity, access level
- **Note:** Custom authentication (no Devise)

#### Other Models
- **Catalog:** Wiki-style content with parent/child revision tracking
- **Issue/IssueReply:** Community feedback system
- **Lyric:** Song lyrics (`belongs_to :track`)
- **Comments:** TrackComment, ImageComment, TrackMigrationComment (all support editability by IP/identity)
- **Category, Notice:** Simple categorization and announcements

### Database Conventions
- Uses **structure.sql** instead of schema.rb for PostgreSQL-specific features
- Counter caches for performance (images_count, track_comments_count, etc.)
- Status-based workflows throughout
- Comprehensive indexes and foreign keys

## Controllers and Routes

### Routing Architecture

**Subdomain Constraints:**
- `api.phate.io` → JSON format endpoints
- `gitio.phate.io` → Git.io proxy service

**Custom Routing Pattern:**
Admin resources use non-standard REST:
- POST to 'new' action instead of create
- PATCH to 'edit' action instead of update

Example:
```ruby
resources :tracks, except: [:create, :update] do
  post  'new'  => 'tracks#create', on: :collection
  patch 'edit' => 'tracks#update', on: :member
end
```

### Controller Organization

#### Public Controllers
- **DefaultController:** Home, FAQ, chat, preferences, support pages
- **ListenController:** Redirects to streaming servers
- **SearchController:** Uses Ransack for searching (random, history, latest)
- **TracksController:** Individual track details
- **ImagesController:** Image galleries
- **IssuesController:** Community feedback
- **CatalogsController:** Wiki with diff viewing
- **NoticesController:** News/announcements
- **MembersController:** Login/logout
- **StaticController:** robots.txt, manifest, proxy services (imgur, gitio)
- **ErrorsController:** Custom error pages

#### Admin Namespace (`/admin/`)
- **Requires:** Authentication (access level >= 5)
- **Admin::TracksController:** CRUD, review/confirm workflow
- **Admin::ImagesController:** Management, import/export
- **Admin::PlaylistController:** Playlist management
- **Admin::TrackMigrationsController:** Migration workflow
- **Admin::NoticesController:** Notice management

#### Upload Namespace (`/upload/`)
- **Upload::AsinController:** Add tracks via Amazon ASIN
- **Upload::NiconicoController:** Add tracks from NicoNico Douga

#### Bridge API (`/bridge/`)
- **Purpose:** Streaming server integration
- **Authentication:** Protected by BRIDGE_SECRET_KEY
- **Bridge::PlaylistController:** Updates now playing, generates playlists, YP Directory integration
- **Bridge::TracksController:** Track data API
- **Bridge::CachesController:** Cache management

#### JSON API (`/json/`)
- **Json::PlaylistController:** Public playlist JSON/XML with caching
- **Json::StatusController:** Server status
- **Json::RequestController:** Song requests

### Controller Concerns

**Location:** `app/controllers/concerns/`

- **CacheLock:** Redis-based locking mechanism to prevent race conditions
- **CodeRayify:** Syntax highlighting for markdown code blocks
- **Streammeta:** Integer#abbrtime extension for duration formatting
- **YPDirectory:** Xiph directory listing integration

### ApplicationController

**Location:** `app/controllers/application_controller.rb`

**Key Functionality:**
- Locale detection (session or Accept-Language header)
- Timezone detection
- Client tracking (IP, user agent, forwarded IPs)
- Session-based authentication (`authenticate!` method)
- Access level checking (5 = admin)
- Markdown rendering with CodeRay
- HTTP request helpers
- CSRF protection

**Important Methods:**
- `set_locale` - Automatic locale detection
- `authenticate!` - Check if logged in
- `client_ip`, `client_identity` - Track users
- `md_to_html` - Markdown rendering

## Development Workflow

### Getting Started

1. **Install Dependencies:**
   ```bash
   gem install bundler --no-document
   gem install rails --no-document
   bundle install
   ```

2. **Database Setup:**
   ```bash
   bundle exec rake db:create
   bundle exec rake db:migrate
   bundle exec rake db:seed
   ```

3. **Start Server:**
   ```bash
   rails server
   # or for production-like:
   bundle exec puma
   ```

4. **Access Application:**
   - Development: http://localhost:3000

### Testing

**Framework:** Minitest (Rails default)

**Run Tests:**
```bash
bundle exec rake db:test:prepare
bundle exec rake test
```

**Test Helper:**
- Located at `test/test_helper.rb`
- Helper: `authenticate_member` (sets session[:access] = 5 for admin access)

**CI/CD:**
- Travis CI configured (.travis.yml)
- GitHub Actions with Gemini CLI workflows
- Code Climate for quality and coverage

### Code Quality

**RuboCop Configuration (.rubocop.yml):**
- Rails cops enabled
- Documentation disabled
- Max line length: 120 characters
- Class/module nesting style disabled
- Excludes: db/, config/, script/

**Run Linter:**
```bash
bundle exec rubocop
```

### Common Development Tasks

#### Import Tracks from utaitedb.net
```bash
bundle exec rake tracks:create_or_update_by_utaitedb
```
- Fetches songs with >10,000 views
- Creates tracks with status QUEUED
- Updates existing tracks

#### Import Artwork from Pixiv
```bash
bundle exec rake images:create_or_update_from_pixiv
```
- Searches Pixiv for track artwork
- Tag matching algorithm
- Uploads to Google Cloud Storage
- Filters age-restricted content

#### Database Operations
```bash
# Reset database
bundle exec rake db:reset

# Load structure
bundle exec rake db:structure:load

# Dump structure (after migrations)
bundle exec rake db:structure:dump
```

### Content Management Workflow

#### Track Management Workflow
1. **Import/Create:** Track created with status QUEUED
2. **Review:** Admin reviews at `/admin/tracks/:id/review`
3. **Confirm:** Admin confirms, status changes to OK
4. **Delete:** Admin can mark as DELETED

#### Track Migration Workflow
1. **Create Migration:** User proposes changes via TrackMigration
2. **Review:** Community/admin reviews
3. **Migrate:** Admin transfers changes to actual Track
4. **Cleanup:** Migration record removed

#### Image Upload Workflow
1. **Upload:** User submits image URL (Imgur) with source (Pixiv/etc)
2. **Verification:** Admin verifies and rates
3. **Publish:** Image marked as verified

## Key Conventions

### Ruby/Rails Conventions
- **Frozen String Literals:** Use `# frozen_string_literal: true` at top of files
- **Strong Parameters:** Always use `.permit!` or explicit whitelisting
- **Before Actions:** Use for common operations (set_locale, authenticate!)
- **Concerns:** Extract shared functionality into concerns
- **Scopes:** Prefer scopes over class methods in models
- **Counter Caches:** Use for performance on associations with counts

### Naming Conventions
- **Models:** Singular, CamelCase (Track, Image, Playlist)
- **Controllers:** Plural, CamelCase with Controller suffix
- **Views:** Organized by controller name, use Slim templates
- **Helpers:** Match controller names
- **Database Tables:** Plural, snake_case

### Authentication Pattern
```ruby
# In controller
before_action :authenticate!

# Sets these variables:
@identity  # Client identity (session or anonymous)
@access    # Access level (5 = admin, nil = guest)
```

### Client Tracking Pattern
```ruby
# Available in ApplicationController
client_ip         # User's IP address (handles proxies)
client_agent      # User agent string
client_identity   # Identity for tracking (uses session)
```

### Status Workflows

**Track Status:**
- `nil` or `QUEUED` → Under review
- `OK` → Published
- `DELETED` → Removed

**Image Status:**
- `nil` → Pending verification
- `verified: true` → Published

### Markdown Rendering
```ruby
# In views/controllers
md_to_html(text)  # Converts markdown to HTML with syntax highlighting
```

### Caching Patterns
```ruby
# Use CacheLock concern for preventing race conditions
include CacheLock

cache_lock('unique_key') do
  # Critical section
end
```

### API Authentication (Bridge)
```ruby
# Bridge controllers check BRIDGE_SECRET_KEY
params[:key] == ENV['BRIDGE_SECRET_KEY']
```

## Environment Variables

**Required in Production:**
- `DATABASE_URL` - PostgreSQL connection string
- `BRIDGE_SECRET_KEY` - Bridge API authentication
- `DANMAKU_SECRET_KEY` - Danmaku service authentication
- `REDIS_URL` - Redis connection (for caching)

**Optional:**
- `ICECAST_SERVER` - Primary Icecast server URL
- `ICECAST_RELAYS` - Comma-separated relay servers
- `STATIC_SERVER_URL` - CDN/static file server
- `PIXIV_AUTHORIZATION` - Pixiv API token
- `OFFLINE_TRACK_ID` - Track to show when offline
- `WEB_CONCURRENCY` - Puma worker count. `workers` is commented out in `config/puma.rb`, so the app runs in single mode (0 workers) by default to fit the 256 MB container limit. To enable clustered mode, uncomment `workers`/`preload_app!` in `config/puma.rb` and set this.
- `RAILS_MAX_THREADS` - Puma thread count (default: 5; keep ≤ the `config/database.yml` `pool: 5`).

**Note:** Puma reads `config/puma.rb` before Rails (and thus dotenv-rails) boots, so puma-level vars like `WEB_CONCURRENCY` and `RAILS_MAX_THREADS` must come from the real process environment (e.g. `production.env` via the Docker Compose `env_file`, or the shell). Putting them in a dotenv `.env` file does not affect puma config.

## Deployment

### Docker Compose Deployment

**Platform:** Self-hosted via Docker Compose (`Dockerfile` + `compose.yaml` at the repo root).

**Image (`Dockerfile`):**
- Base image `ruby:2.5.9-slim` (Debian buster).
- `COPY sources.list /etc/apt/sources.list` — points apt at `archive.debian.org` because buster is EOL/archived.
- Sets `ENV RAILS_ENV=production`, apt-installs `build-essential ruby-dev libpq-dev nodejs`.
- Runs `bundle install` (with `bundle config --global frozen 1`), then `bundle exec rake assets:precompile` — **assets are precompiled at image build time**, so there is no separate precompile step at deploy.
- `EXPOSE 3000` and `CMD ["bundle", "exec", "puma"]` (puma auto-loads `config/puma.rb`).

**Service (`compose.yaml`):**
- One service `web`: builds for `linux/amd64`, image `denpaio/phateio:latest`, `container_name: phateio`.
- Port mapping `127.0.0.1:3030:3000` — bound to loopback only (front with a reverse proxy for public access).
- `env_file: [production.env]` supplies env/secrets (see below). No `command:` override, so it uses the Dockerfile `CMD`.
- Resource caps: `cpus: 0.5`, `mem_limit: 256m`. `restart: always`.
- Puma runs in **single mode** (workers commented out) binding `tcp://0.0.0.0:3000` inside the container, fitting the 256 MB limit.

**Environment / secrets:**
- Provided via `production.env`, loaded by the Compose `env_file:` as real process ENV (not dotenv). It is git-ignored (`.gitignore` has `/production.env`).
- Holds `RACK_ENV=production`, `DATABASE_URL`, `BRIDGE_SECRET_KEY`, and the other vars from the Environment Variables section.

**Production gems:** The Heroku-era gems `rails_12factor`, `lograge`, and `cloudflare-rails` are still in the Gemfile (removing them is a separate future task). They remain useful under Docker: `rails_12factor` gives stdout logging + static asset serving, `lograge` structures logs, and `cloudflare-rails` filters CloudFlare IPs.

**Deploy steps:**

1. **Build the image:**
   ```bash
   docker compose build
   ```

2. **Start the service:**
   ```bash
   docker compose up -d
   ```

3. **Run database migrations** (against the container's configured DB):
   ```bash
   docker compose run --rm web bundle exec rake db:migrate
   ```

## Important Notes for AI Assistants

### Do's ✓
- **Always use structure.sql:** This project uses PostgreSQL-specific features; never convert to schema.rb
- **Follow custom REST patterns:** Admin routes use POST to 'new' and PATCH to 'edit'
- **Use Slim templates:** Views are in Slim, not ERB
- **Respect status workflows:** Tracks go through QUEUED → OK/DELETED states
- **Use counter caches:** Don't manually count associations; use counter_cache columns
- **Include frozen_string_literal:** Add `# frozen_string_literal: true` to new Ruby files
- **Follow RuboCop rules:** Max 120 char lines, no documentation requirement
- **Test authentication:** Use `authenticate_member` helper in tests
- **Use concerns:** Extract shared logic into concerns, not modules

### Don'ts ✗
- **Don't use Devise:** This project has custom authentication
- **Don't use schema.rb:** Use structure.sql for database schema
- **Don't bypass status checks:** Always respect Track/Image status fields
- **Don't skip authentication:** Admin actions require access level >= 5
- **Don't use ERB:** Templates are Slim format
- **Don't ignore IP tracking:** Many features depend on client_ip/client_identity
- **Don't remove frozen_string_literal:** It's a project standard
- **Don't create standard REST routes for admin:** Follow the custom pattern
- **Don't bypass CacheLock:** Use it for playlist updates and critical sections

### Common Pitfalls
1. **Database Schema:** Modifying structure.sql manually is tricky; prefer migrations
2. **Custom Routes:** Don't expect standard REST routes in admin namespace
3. **Authentication:** Session-based, not token-based; stored in session[:access]
4. **Slim Syntax:** Different from ERB; `=` outputs, `-` doesn't, `==` outputs without escaping
5. **PostgreSQL Features:** Don't use MySQL-specific features; this is PostgreSQL only
6. **Counter Caches:** Must be manually updated if bypassing ActiveRecord

### External Service Dependencies
- **NicoNico Douga:** May require authentication; video IDs stored in `niconico` field
- **utaitedb.net:** API may have rate limits; rake task handles this
- **Pixiv:** Requires PIXIV_AUTHORIZATION token; may change API
- **Imgur:** Used for image hosting; URLs validated in Image model
- **Icecast:** Streaming server; Bridge API integrates with it

### Localization Notes
- **Supported Locales:** en, ja, zh-Hans, zh-Hant
- **Locale Detection:** Automatic from Accept-Language header
- **Session Override:** User can set preferred locale
- **Translation Service:** Uses Locale app (localeapp.com)
- **Chinese Variants:** Distinguish between Simplified (Hans) and Traditional (Hant)

### Performance Considerations
- **Redis Caching:** Only in production; development uses memory
- **Counter Caches:** Used extensively; don't count manually
- **N+1 Queries:** Use includes/joins for associations
- **Playlist Locking:** Uses pessimistic locking to prevent race conditions
- **History Cleanup:** Histories older than 30 days are purged
- **Asset Pipeline:** Precompile assets for production

## File Locations Quick Reference

### Key Files
- **Routes:** `config/routes.rb`
- **Application Config:** `config/application.rb`
- **Database Config:** `config/database.yml`
- **Environment Variables:** `config/initializers/environment_variables.rb`
- **Puma Config:** `config/puma.rb`
- **Redis Config:** `config/initializers/redis.rb`

### Key Models
- **Track:** `app/models/track.rb`
- **Image:** `app/models/image.rb`
- **Playlist:** `app/models/playlist.rb`
- **Member:** `app/models/member.rb`

### Key Controllers
- **Application:** `app/controllers/application_controller.rb`
- **Bridge Playlist:** `app/controllers/bridge/playlist_controller.rb`
- **Admin Tracks:** `app/controllers/admin/tracks_controller.rb`

### Key Tasks
- **Track Import:** `lib/tasks/tracks.rake`
- **Image Import:** `lib/tasks/images.rake`

### Configuration
- **RuboCop:** `.rubocop.yml`
- **Travis CI:** `.travis.yml`
- **Gemfile:** `Gemfile` (dependencies)
- **Dockerfile:** `Dockerfile` (container image)
- **Docker Compose:** `compose.yaml` (Docker Compose service)

## Additional Resources

- **Repository:** https://github.com/phateio/kiris
- **License:** MIT (see LICENSE file)
- **Issue Tracker:** GitHub Issues
- **Translation:** https://www.localeapp.com/projects/6196
- **CI Status:** https://travis-ci.org/phateio/kiris
- **Code Climate:** https://codeclimate.com/github/phateio/kiris

---

**Last Updated:** 2026-07-26

This document should be updated whenever significant architectural changes are made to the codebase.
