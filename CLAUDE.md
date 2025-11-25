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

## Technology Stack

### Core Framework
- **Ruby:** 2.5.9 (defined in Gemfile, note: .ruby-version shows 2.5.8 but Gemfile uses 2.5.9)
- **Rails:** 4.2.5
- **Database:** PostgreSQL (with structure.sql format, not schema.rb)
- **Cache:** Redis (production only)
- **Web Server:** Puma (2 workers, 5 threads default)

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
├── Procfile              # Heroku deployment
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

## Rails Upgrade Workflow

**CRITICAL REFERENCE:** This project has comprehensive Rails Upgrade Guidelines in `README.md`. **ALWAYS read and follow README.md Rails Upgrade Guidelines before starting any Rails upgrade.**

### Step-by-Step Rails Upgrade Process

When asked to upgrade Rails, follow this exact workflow:

1. **Read README.md Guidelines First**
   - Open and read the "Rails Upgrade Guidelines" section in README.md
   - Understand the upgrade path methodology
   - Note the complete diff application rules

2. **Plan the Upgrade Path**
   - Determine current Rails version (check `Gemfile.lock`)
   - Determine target Rails version
   - Create step-by-step upgrade path following major version increments
   - Example: 4.2.5 → 4.2.11 → 5.0.0 → 5.2.8 → 6.0.0 → 6.1.7

3. **For EACH Major Version Step**

   **A. Visit railsdiff.org**
   - Open the exact URL: `https://railsdiff.org/{from_version}/{to_version}`
   - Review ALL file changes in the diff
   - Make a mental note of:
     - Files to modify
     - **Files to create (marked as "new file")**
     - Files to delete
     - Directory structure changes

   **B. Update Gemfile**
   - Update Rails version
   - Update related gems if needed for compatibility
   - Run `bundle update rails`

   **C. Apply ALL railsdiff.org Changes**

   **CRITICAL: Copy files EXACTLY as shown in railsdiff.org, including:**
   - All code lines
   - **ALL comments** (even if they look like documentation or examples)
   - All whitespace and formatting
   - All empty lines

   **Must create these files if they don't exist (with EXACT content from railsdiff.org):**
   - `config/cable.yml` (Rails 5.0+)
   - `config/storage.yml` (Rails 5.2+)
   - `config/initializers/content_security_policy.rb` (Rails 5.2+)
   - `config/initializers/permissions_policy.rb` (Rails 6.1+)
   - `config/initializers/new_framework_defaults_X_Y.rb` (each major version)
   - `bin/update` (Rails 5.0+)
   - `app/models/application_record.rb` (Rails 5.0+)
   - `app/jobs/application_job.rb` (Rails 5.0+) - **including retry_on and discard_on comments**
   - `app/mailers/application_mailer.rb` (Rails 5.0+)
   - `app/views/layouts/mailer.html.erb` and `.text.erb` (Rails 5.0+)

   **Must update these files:**
   - `.gitattributes` - Update to Rails standard format
   - `.gitignore` - Add new ignore patterns (storage/, tmp/storage/, config/master.key, etc.)
   - `bin/rails`, `bin/rake`, `bin/setup` - Update to modern format (remove `.exe`, use `__dir__`)
   - `config/application.rb` - Update `config.load_defaults`
   - `config/boot.rb` - Update requires, add bootsnap
   - `config/environment.rb` - Update requires to use `require_relative`
   - `config/puma.rb` - Update to Rails 6.1 format
   - `config/environments/*.rb` - Add all new configuration options
   - `config/database.yml` - Update comments and format if needed

   **Must create directory structure:**
   - `tmp/.keep`, `tmp/pids/.keep`, `tmp/storage/.keep`
   - `storage/.keep`

   **D. Verification Checklist**
   - [ ] All files marked "new file" in railsdiff.org are created **with EXACT content including ALL comments**
   - [ ] All files marked "modified" in railsdiff.org are updated **line by line, including comment changes**
   - [ ] .gitattributes updated to Rails standard
   - [ ] .gitignore includes all new patterns
   - [ ] All bin/ scripts use modern format
   - [ ] config/application.rb has correct load_defaults version
   - [ ] All new initializers are created
   - [ ] Directory structure is complete
   - [ ] **Content verification**: For new files (especially ApplicationJob, ApplicationRecord, ApplicationMailer), verify comments match railsdiff.org

   **E. Commit Changes**
   - Commit gem updates separately from config updates
   - Use descriptive commit messages
   - Follow the commit message format from previous upgrades

4. **After All Upgrades Complete**
   - Review all commits
   - Ensure no files were missed
   - Push to remote branch

### Common Mistakes to Avoid

❌ **DO NOT:**
- Skip creating new files from railsdiff.org
- Only update gems without applying config changes
- Assume existing files are sufficient
- Skip updating .gitattributes or .gitignore
- Forget to create new initializers
- Leave bin/ scripts in old format
- **Create files from memory/common knowledge - ALWAYS copy from railsdiff.org**
- **Skip comments thinking they are optional - ALL comments must be included**
- Create minimal/skeleton versions of files - use EXACT content

✓ **DO:**
- Create EVERY file marked as "new file" in railsdiff.org **with EXACT content**
- Update EVERY file marked as "modified" in railsdiff.org **line by line**
- **Include ALL comments, even if they look like documentation or examples**
- Use the verification checklist for each version
- Ask user if uncertain about any file
- Follow the README.md guidelines strictly

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
   bundle exec puma -C config/puma.rb
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
- `WEB_CONCURRENCY` - Puma worker count (default: 2, set to 0 in dev)
- `MAX_THREADS` - Puma thread count (default: 5, set to 3 in dev)

**Development (.env file):**
```
WEB_CONCURRENCY=0
MAX_THREADS=3
```

## Deployment

### Heroku Deployment

**Platform:** Primary deployment target is Heroku

**Procfile:**
```
web: bundle exec puma -C config/puma.rb
```

**Production Gems:**
- rails_12factor - Heroku integration (logging, static assets)
- lograge - Structured logging
- cloudflare-rails - CloudFlare IP filtering

**Database:**
- Uses DATABASE_URL environment variable
- PostgreSQL with structure.sql

**Buildpacks:**
- Ruby buildpack (detects Ruby version from Gemfile)

**Configuration:**
- Set all required environment variables in Heroku config
- Enable Redis add-on for caching
- Configure DATABASE_URL (automatic with Postgres add-on)

### Manual Deployment

1. **Precompile Assets:**
   ```bash
   RAILS_ENV=production bundle exec rake assets:precompile
   ```

2. **Database Migration:**
   ```bash
   RAILS_ENV=production bundle exec rake db:migrate
   ```

3. **Start Server:**
   ```bash
   bundle exec puma -C config/puma.rb
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
- **Procfile:** `Procfile` (Heroku)

## Additional Resources

- **Repository:** https://github.com/phateio/kiris
- **License:** MIT (see LICENSE file)
- **Issue Tracker:** GitHub Issues
- **Translation:** https://www.localeapp.com/projects/6196
- **CI Status:** https://travis-ci.org/phateio/kiris
- **Code Climate:** https://codeclimate.com/github/phateio/kiris

---

**Last Updated:** 2025-11-15

This document should be updated whenever significant architectural changes are made to the codebase.
