ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Rails 4.2 resets primary key sequences by selecting increment_by and min_value
# as if they were columns of the sequence relation. PostgreSQL 10 moved them into
# the pg_sequence catalog, so fixture loading raises PG::UndefinedColumn on every
# modern server. Nothing in the application calls reset_pk_sequence! at runtime -
# only the fixture loader does - so this override is confined to the test suite.
module PostgreSQLSequenceResetCompatibility
  def reset_pk_sequence!(table, pk = nil, sequence = nil)
    return super if postgresql_version < 100_000

    unless pk && sequence
      default_pk, default_sequence = pk_and_sequence_for(table)
      pk ||= default_pk
      sequence ||= default_sequence
    end
    return unless pk && sequence

    quoted_sequence = quote_table_name(sequence)
    max_pk = select_value("SELECT MAX(#{quote_column_name(pk)}) FROM #{quote_table_name(table)}")

    if max_pk.nil?
      select_value(
        "SELECT setval('#{quoted_sequence}', " \
        "(SELECT seqmin FROM pg_sequence WHERE seqrelid = '#{quoted_sequence}'::regclass), false)"
      )
    else
      select_value("SELECT setval('#{quoted_sequence}', #{max_pk})")
    end
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  .prepend(PostgreSQLSequenceResetCompatibility)

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def authenticate_member
    session[:access] = 5
  end
end
