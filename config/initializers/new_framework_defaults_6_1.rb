# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 6.1 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.

# Support for inversing belongs_to -> has_many Active Record associations.
# Rails.application.config.active_record.has_many_inversing = true

# Track Active Storage variants in the database.
# Rails.application.config.active_storage.track_variants = true

# Apply random variation to the delay when retrying failed jobs.
# Rails.application.config.active_job.retry_jitter = 0.15

# Stop executing after the first matching `when` clause in `ActiveSupport::TestCase#assert_changes` and `assert_no_changes`.
# Rails.application.config.active_support.use_assert_matching_results = true

# Specify cookies SameSite protection level: either :none, :lax, or :strict.
#
# This change is not backwards compatible with earlier Rails versions.
# It's best enabled when your entire app is migrated and stable on 6.1.
# Rails.application.config.action_dispatch.cookies_same_site_protection = :lax

# Generate CSRF tokens that are encoded in URL-safe Base64.
#
# This change is not backwards compatible with earlier Rails versions.
# It's best enabled when your entire app is migrated and stable on 6.1.
# Rails.application.config.action_controller.urlsafe_csrf_tokens = true

# Specify whether `ActiveSupport::TimeZone.utc_to_local` returns a time with an
# UTC offset or a UTC time.
# Rails.application.config.active_support.utc_to_local_returns_utc_offset_times = true

# Change the default HTTP status code to `308` when redirecting non-GET/HEAD
# requests to HTTPS in `ActionDispatch::SSL` middleware.
# Rails.application.config.action_dispatch.ssl_default_redirect_status = 308

# Use new connection handling API. For most applications this won't have any
# effect. For applications using multiple databases, this new API provides
# support for granular connection swapping.
# Rails.application.config.active_record.legacy_connection_handling = false

# Make `form_with` generate non-remote forms by default.
# Rails.application.config.action_view.form_with_generates_remote_forms = false

# Set the default queue name for the analysis job to the queue adapter default.
# Rails.application.config.active_storage.queues.analysis = nil

# Set the default queue name for the purge job to the queue adapter default.
# Rails.application.config.active_storage.queues.purge = nil

# Set the default queue name for the incineration job to the queue adapter default.
# Rails.application.config.action_mailbox.queues.incineration = nil

# Set the default queue name for the routing job to the queue adapter default.
# Rails.application.config.action_mailbox.queues.routing = nil

# Set the default queue name for the mail deliver job to the queue adapter default.
# Rails.application.config.action_mailer.deliver_later_queue_name = nil

# Generate channel and job IDs with a random alpha-numeric string instead of integers.
# If you're upgrading an existing app and need to maintain integer IDs for compatibility,
# set this to false.
# Rails.application.config.active_job.use_big_decimal_serializer = true
