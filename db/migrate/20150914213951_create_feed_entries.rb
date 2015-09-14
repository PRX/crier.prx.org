class CreateFeedEntries < ActiveRecord::Migration
  def change
    create_table "feed_entries" do |t|
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
      t.string   "enclosure_length"
      t.string   "enclosure_type"
      t.string   "enclosure_url"
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
    end

    add_index "feed_entries", ["feed_id"], name: "index_feed_entries_on_feed_id", using: :btree
  end
end
