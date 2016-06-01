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

ActiveRecord::Schema.define(version: 20160425140442) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "feed_entries", force: :cascade do |t|
    t.integer  "feed_id"
    t.string   "digest"
    t.string   "entry_id"
    t.string   "url"
    t.string   "author"
    t.text     "title"
    t.text     "subtitle"
    t.text     "content"
    t.text     "summary"
    t.datetime "published"
    t.datetime "updated"
    t.string   "image_url"
    t.integer  "duration"
    t.string   "explicit"
    t.text     "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.text     "categories"
    t.string   "comment_url"
    t.boolean  "block"
    t.boolean  "is_closed_captioned"
    t.integer  "position"
    t.string   "comment_rss_url"
    t.string   "comment_count"
    t.string   "feedburner_orig_link"
    t.string   "feedburner_orig_enclosure_link"
    t.datetime "deleted_at"
    t.boolean  "is_perma_link"
  end

  add_index "feed_entries", ["deleted_at"], name: "index_feed_entries_on_deleted_at", using: :btree
  add_index "feed_entries", ["feed_id"], name: "index_feed_entries_on_feed_id", using: :btree

  create_table "feed_responses", force: :cascade do |t|
    t.integer  "feed_id"
    t.string   "url"
    t.string   "etag"
    t.datetime "last_modified"
    t.text     "request"
    t.text     "request_headers"
    t.string   "status"
    t.string   "method"
    t.text     "response_headers"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", force: :cascade do |t|
    t.string   "url"
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "subtitle"
    t.text     "description"
    t.text     "summary"
    t.text     "owners"
    t.string   "author"
    t.text     "keywords"
    t.text     "categories"
    t.string   "image_url"
    t.string   "feed_url"
    t.string   "explicit"
    t.string   "language"
    t.string   "copyright"
    t.string   "managing_editor"
    t.string   "web_master"
    t.string   "generator"
    t.integer  "ttl"
    t.datetime "published"
    t.datetime "last_built"
    t.boolean  "block"
    t.boolean  "complete"
    t.string   "new_feed_url"
    t.string   "update_period"
    t.integer  "update_frequency"
    t.string   "feedburner_name"
    t.string   "hub_url"
    t.datetime "last_modified"
    t.datetime "pub_date"
    t.string   "thumb_url"
    t.datetime "deleted_at"
  end

  add_index "feeds", ["deleted_at"], name: "index_feeds_on_deleted_at", using: :btree

  create_table "media_resources", force: :cascade do |t|
    t.string   "type"
    t.integer  "feed_entry_id"
    t.string   "url"
    t.string   "mime_type"
    t.integer  "file_size"
    t.boolean  "is_default"
    t.string   "medium"
    t.string   "expression"
    t.integer  "bitrate"
    t.integer  "framerate"
    t.decimal  "samplingrate"
    t.integer  "channels"
    t.decimal  "duration"
    t.integer  "height"
    t.integer  "width"
    t.string   "lang"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "position"
    t.string   "etag"
  end

  add_index "media_resources", ["feed_entry_id"], name: "index_media_resources_on_feed_entry_id", using: :btree

  create_table "say_when_job_executions", force: :cascade do |t|
    t.integer  "job_id"
    t.string   "status"
    t.text     "result"
    t.datetime "start_at"
    t.datetime "end_at"
  end

  add_index "say_when_job_executions", ["job_id"], name: "index_say_when_job_executions_on_job_id", using: :btree
  add_index "say_when_job_executions", ["status", "start_at", "end_at"], name: "index_say_when_job_executions_on_status_and_start_at_and_end_at", using: :btree

  create_table "say_when_jobs", force: :cascade do |t|
    t.string   "group"
    t.string   "name"
    t.string   "status"
    t.string   "trigger_strategy"
    t.text     "trigger_options"
    t.datetime "last_fire_at"
    t.datetime "next_fire_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "job_class"
    t.string   "job_method"
    t.text     "data"
    t.string   "scheduled_type"
    t.integer  "scheduled_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "say_when_jobs", ["next_fire_at", "status"], name: "index_say_when_jobs_on_next_fire_at_and_status", using: :btree
  add_index "say_when_jobs", ["scheduled_type", "scheduled_id"], name: "index_say_when_jobs_on_scheduled_type_and_scheduled_id", using: :btree

end
