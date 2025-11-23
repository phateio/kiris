[![Build Status](https://travis-ci.org/phateio/kiris.svg?branch=master)](https://travis-ci.org/phateio/kiris)
[![Code Climate](https://codeclimate.com/github/phateio/kiris/badges/gpa.svg)](https://codeclimate.com/github/phateio/kiris)
[![Test Coverage](https://codeclimate.com/github/phateio/kiris/badges/coverage.svg)](https://codeclimate.com/github/phateio/kiris/coverage)

## Getting Started

1. Install Bundler and Rails at the command prompt if you haven't yet:

        $ gem install bundle --no-document
        $ gem install rails --no-document

2. Install the gem dependencies using bundler:

        $ bundle install

3. Initialize the database if you haven't yet:

        $ bundle exec rake db:create
        $ bundle exec rake db:migrate
        $ bundle exec rake db:seed

4. Start the web server:

        $ rails server

5. Using a browser, go to `http://localhost:3000` and you'll see the home page.

## Test
        $ bundle exec rake db:test:prepare
        $ bundle exec rake test

## Translations
We use [phateio-i18n@Locale](https://www.localeapp.com/projects/6196) to manage our translation files.

Everyone is welcome to help correct, improve, or complete the translations.

## Rails Upgrade Guidelines

When upgrading Rails versions for this project, follow these strict guidelines to ensure a safe and systematic upgrade process.

### 1. Upgrade Path Methodology

**Adopt a step-by-step major version incremental strategy.** Never skip major versions.

**Example:** Upgrading from Rails 4.2.10 to 6.1.7.10

Follow this complete upgrade path:

1. `4.2.10` → `4.2.11` (latest patch in current major version)
2. `4.2.11` → `5.0.0` (first release of next major version)
3. `5.0.0` → `5.2.8.1` (latest patch in current major version)
4. `5.2.8.1` → `6.0.0` (first release of next major version)
5. `6.0.0` → `6.1.7.10` (target version)

**Important:** Always upgrade to the latest patch version within each major version before moving to the next major version.

### 2. Complete Diff Application Rules

- **Use [railsdiff.org](https://railsdiff.org/)** to compare differences between versions
- **Apply ALL changes completely**, including:
  - Configuration file updates
  - Comment modifications (e.g., `http://` → `https://`)
  - Framework default changes
  - Deprecation warnings
- **When encountering conflicts:**
  - **STOP the upgrade process**
  - Document the conflict
  - Ask for guidance on resolution strategy
  - Do not skip or partially apply conflicting changes

### 3. Ruby Version Synchronization

- **Consult [Rails official documentation](https://guides.rubyonrails.org/)** to determine the minimum compatible Ruby version for each Rails version
- **Upgrade Ruby synchronously** with each major Rails version upgrade
- Update both `.ruby-version` and `Gemfile` to reflect the new Ruby version
- Verify Ruby version compatibility before proceeding with Rails upgrade

### 4. Gem Dependency Handling Principles

- **Minimize changes:** Only upgrade gems that are strictly necessary for Rails compatibility
- **For deprecated gems:**
  - Research and identify trustworthy, actively maintained alternatives
  - Prefer official recommendations from Rails upgrade guides
  - Consider community adoption and maintenance status
- **When uncertain about alternatives:**
  - **STOP the upgrade process**
  - Document the deprecated gem and its usage
  - Request guidance on suitable replacements
  - Do not proceed with unverified gem substitutions

### 5. Test Completeness Requirements

**After EACH upgrade step:**

1. Run the full test suite:
   ```bash
   bundle exec rake db:test:prepare
   bundle exec rake test
   ```

2. **All previously passing tests MUST continue to pass**
   - If any test fails, investigate and fix before proceeding
   - Do not skip failing tests or mark them as pending

3. **Test coverage MUST be ≥ pre-upgrade level**
   - Verify coverage metrics before and after upgrade
   - Add tests if coverage drops
   - Never proceed if coverage decreases

4. **Manual testing checklist:**
   - Verify critical user workflows function correctly
   - Test streaming integration
   - Confirm admin panel operations
   - Validate API endpoints

**Remember:** Systematic, incremental upgrades with comprehensive testing at each step ensure a stable application throughout the upgrade process.

## License
Phate Radio is released under the [MIT License](https://opensource.org/license/MIT).
