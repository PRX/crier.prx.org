class CreateFeedResponses < ActiveRecord::Migration
  def change
    create_table "feed_responses" do |t|
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
  end
end
