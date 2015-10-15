# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150810142823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "catalogs", force: :cascade do |t|
    t.text     "text",       default: "", null: false
    t.text     "html",       default: "", null: false
    t.string   "comment",    default: "", null: false
    t.string   "nickname",   default: "", null: false
    t.string   "ipaddress",  default: "", null: false
    t.string   "forwarded",  default: "", null: false
    t.string   "useragent",  default: "", null: false
    t.string   "sessionid",  default: "", null: false
    t.integer  "length",     default: 0,  null: false
    t.string   "revision",   default: "", null: false
    t.integer  "parent_id",  default: 0,  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "categories", force: :cascade do |t|
    t.integer  "gid",                    default: 0,  null: false
    t.integer  "tid",                    default: 0,  null: false
    t.string   "title",      limit: 255, default: "", null: false
    t.string   "keyword",    limit: 255, default: "", null: false
    t.string   "comment",    limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories", force: :cascade do |t|
    t.datetime "playedtime", default: '1970-01-01 00:00:00', null: false
    t.integer  "track_id",   default: 0,                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "histories", ["track_id"], name: "index_histories_on_track_id", using: :btree

  create_table "image_comments", force: :cascade do |t|
    t.integer  "image_id",               default: 0,  null: false
    t.text     "message",                default: "", null: false
    t.string   "nickname",   limit: 255, default: "", null: false
    t.string   "useragent",  limit: 255, default: "", null: false
    t.string   "userip",     limit: 255, default: "", null: false
    t.string   "status",     limit: 255, default: "", null: false
    t.string   "identity",   limit: 255, default: "", null: false
    t.integer  "rate",                   default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "image_comments", ["image_id"], name: "index_image_comments_on_image_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "track_id",                         default: 0,     null: false
    t.string   "url",                  limit: 255, default: "",    null: false
    t.string   "source",               limit: 255, default: "",    null: false
    t.string   "nickname",             limit: 255, default: "",    null: false
    t.string   "userip",               limit: 255, default: "",    null: false
    t.string   "status",               limit: 255, default: "",    null: false
    t.string   "identity",             limit: 255, default: "",    null: false
    t.boolean  "verified",                         default: false, null: false
    t.integer  "rate",                             default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "image_comments_count",             default: 0,     null: false
    t.string   "illustrator",                      default: "",    null: false
  end

  add_index "images", ["track_id"], name: "index_images_on_track_id", using: :btree

  create_table "issue_replies", force: :cascade do |t|
    t.datetime "dateline",               default: '1970-01-01 00:00:00', null: false
    t.integer  "issue_id",               default: 0,                     null: false
    t.text     "message",                default: "",                    null: false
    t.string   "nickname",   limit: 255, default: "",                    null: false
    t.string   "useragent",  limit: 255, default: "",                    null: false
    t.string   "userip",     limit: 255, default: "",                    null: false
    t.string   "status",     limit: 255, default: "",                    null: false
    t.string   "identity",   limit: 255, default: "",                    null: false
    t.integer  "rate",                   default: 0,                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_replies", ["issue_id"], name: "index_issue_replies_on_issue_id", using: :btree

  create_table "issues", force: :cascade do |t|
    t.datetime "dateline",                        default: '1970-01-01 00:00:00', null: false
    t.string   "typeid",              limit: 255, default: "",                    null: false
    t.string   "subject",             limit: 255, default: "",                    null: false
    t.text     "message",                         default: "",                    null: false
    t.string   "nickname",            limit: 255, default: "",                    null: false
    t.string   "useragent",           limit: 255, default: "",                    null: false
    t.string   "userip",              limit: 255, default: "",                    null: false
    t.string   "status",              limit: 255, default: "",                    null: false
    t.string   "identity",            limit: 255, default: "",                    null: false
    t.integer  "rate",                            default: 0,                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "issue_replies_count",             default: 0,                     null: false
  end

  create_table "lyrics", force: :cascade do |t|
    t.integer  "track_id",               default: 0,  null: false
    t.text     "text",                   default: "", null: false
    t.string   "nickname",   limit: 255, default: "", null: false
    t.string   "userip",     limit: 255, default: "", null: false
    t.string   "status",     limit: 255, default: "", null: false
    t.string   "identity",   limit: 255, default: "", null: false
    t.integer  "version",                default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: :cascade do |t|
    t.string   "username",   limit: 255, default: "",                    null: false
    t.string   "password",   limit: 255, default: "",                    null: false
    t.string   "identity",   limit: 255, default: "",                    null: false
    t.string   "nickname",   limit: 255, default: "",                    null: false
    t.integer  "access",                 default: 0,                     null: false
    t.datetime "lastact",                default: '1970-01-01 00:00:00', null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["identity"], name: "index_members_on_identity", using: :btree

  create_table "notices", force: :cascade do |t|
    t.string   "dateline",   limit: 255, default: "", null: false
    t.string   "subject",    limit: 255, default: "", null: false
    t.string   "message",    limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "playlist", force: :cascade do |t|
    t.datetime "playedtime",             default: '1970-01-01 00:00:00', null: false
    t.integer  "track_id",               default: 0,                     null: false
    t.string   "nickname",   limit: 255, default: "",                    null: false
    t.string   "userip",     limit: 255, default: "",                    null: false
    t.string   "aliasip",    limit: 255, default: "",                    null: false
    t.string   "useragent",  limit: 255, default: "",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "playlist", ["track_id"], name: "index_playlist_on_track_id", using: :btree

  create_table "track_comments", force: :cascade do |t|
    t.integer  "track_id",               default: 0,  null: false
    t.text     "message",                default: "", null: false
    t.string   "nickname",   limit: 255, default: "", null: false
    t.string   "useragent",  limit: 255, default: "", null: false
    t.string   "userip",     limit: 255, default: "", null: false
    t.string   "status",     limit: 255, default: "", null: false
    t.string   "identity",   limit: 255, default: "", null: false
    t.integer  "rate",                   default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "track_comments", ["track_id"], name: "index_track_comments_on_track_id", using: :btree

  create_table "track_migration_comments", force: :cascade do |t|
    t.integer  "track_migration_id",             default: 0,  null: false
    t.text     "message",                        default: "", null: false
    t.string   "nickname",           limit: 255, default: "", null: false
    t.string   "useragent",          limit: 255, default: "", null: false
    t.string   "userip",             limit: 255, default: "", null: false
    t.string   "status",             limit: 255, default: "", null: false
    t.string   "identity",           limit: 255, default: "", null: false
    t.integer  "rate",                           default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "track_migration_comments", ["track_migration_id"], name: "index_track_migration_comments_on_track_migration_id", using: :btree

  create_table "track_migrations", force: :cascade do |t|
    t.integer  "number",                                     default: 0,                     null: false
    t.string   "szhash",                         limit: 255, default: "",                    null: false
    t.string   "title",                          limit: 255, default: "",                    null: false
    t.string   "tags",                           limit: 255, default: "",                    null: false
    t.string   "artist",                         limit: 255, default: "",                    null: false
    t.string   "album",                          limit: 255, default: "",                    null: false
    t.integer  "duration",                                   default: 0,                     null: false
    t.integer  "count",                                      default: 0,                     null: false
    t.datetime "mtime",                                      default: '1970-01-01 00:00:00', null: false
    t.datetime "nexttime",                                   default: '1970-01-01 00:00:00', null: false
    t.string   "label",                          limit: 255, default: "",                    null: false
    t.string   "asin",                           limit: 255, default: "",                    null: false
    t.string   "niconico",                       limit: 255, default: "",                    null: false
    t.string   "album_cover",                    limit: 255, default: "",                    null: false
    t.string   "release_date",                   limit: 255, default: "",                    null: false
    t.string   "detail_page_url",                limit: 255, default: "",                    null: false
    t.string   "uploader",                       limit: 255, default: "",                    null: false
    t.string   "source_format",                  limit: 255, default: "",                    null: false
    t.string   "source_bitrate",                 limit: 255, default: "",                    null: false
    t.string   "source_bitrate_type",            limit: 255, default: "",                    null: false
    t.string   "source_frequency",               limit: 255, default: "",                    null: false
    t.string   "source_channels",                limit: 255, default: "",                    null: false
    t.string   "action",                         limit: 255, default: "",                    null: false
    t.string   "userip",                         limit: 255, default: "",                    null: false
    t.string   "status",                         limit: 255, default: "",                    null: false
    t.string   "identity",                       limit: 255, default: "",                    null: false
    t.integer  "version",                                    default: 0,                     null: false
    t.boolean  "committed",                                  default: false,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "track_migration_comments_count",             default: 0,                     null: false
    t.integer  "cooldown_time",                              default: 0,                     null: false
  end

  add_index "track_migrations", ["szhash"], name: "index_track_migrations_on_szhash", using: :btree

  create_table "tracks", force: :cascade do |t|
    t.string   "szhash",               limit: 255, default: "",                    null: false
    t.string   "title",                limit: 255, default: "",                    null: false
    t.string   "tags",                 limit: 255, default: "",                    null: false
    t.string   "artist",               limit: 255, default: "",                    null: false
    t.string   "album",                limit: 255, default: "",                    null: false
    t.integer  "duration",                         default: 0,                     null: false
    t.datetime "mtime",                            default: '1970-01-01 00:00:00', null: false
    t.integer  "count",                            default: 0,                     null: false
    t.datetime "nexttime",                         default: '1970-01-01 00:00:00', null: false
    t.string   "asin",                 limit: 255, default: "",                    null: false
    t.string   "niconico",             limit: 255, default: "",                    null: false
    t.boolean  "legacy",                           default: false,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label",                limit: 255, default: "",                    null: false
    t.integer  "number",                           default: 0,                     null: false
    t.string   "album_cover",          limit: 255, default: "",                    null: false
    t.string   "release_date",         limit: 255, default: "",                    null: false
    t.string   "detail_page_url",      limit: 255, default: "",                    null: false
    t.string   "uploader",             limit: 255, default: "",                    null: false
    t.string   "source_format",        limit: 255, default: "",                    null: false
    t.string   "source_bitrate",       limit: 255, default: "",                    null: false
    t.string   "source_bitrate_type",  limit: 255, default: "",                    null: false
    t.string   "source_frequency",     limit: 255, default: "",                    null: false
    t.string   "source_channels",      limit: 255, default: "",                    null: false
    t.integer  "images_count",                     default: 0,                     null: false
    t.integer  "cooldown_time",                    default: 0,                     null: false
    t.string   "userip",               limit: 255, default: "",                    null: false
    t.string   "status",               limit: 255, default: "",                    null: false
    t.string   "identity",             limit: 255, default: "",                    null: false
    t.integer  "track_comments_count",             default: 0,                     null: false
  end

  add_index "tracks", ["szhash"], name: "index_tracks_on_szhash", using: :btree

end
