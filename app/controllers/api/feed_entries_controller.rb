class Api::FeedEntriesController < Api::BaseController
  represent_with Api::FeedEntryRepresenter
  filter_resources_by :feed_id
end
