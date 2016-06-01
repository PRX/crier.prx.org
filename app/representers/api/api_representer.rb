# encoding: utf-8

class Api::ApiRepresenter < Api::BaseRepresenter
  property :version

  def self_url(represented)
    api_root_path(represented.version)
  end

  links :entry do
    [
      {
        title:     "Get a single entry",
        profile:   profile_url(:entry),
        href:      api_entry_path_template(api_version: represented.version, id: '{id}') + '{?zoom}',
        templated: true
      }
    ]
  end

  links :entries do
    [
      {
        title:     "Get a paged collection of entries",
        profile:   profile_url(:collection, :entry),
        href:      api_entries_path_template(api_version: represented.version) + '{?page,per,zoom}',
        templated: true
      }
    ]
  end

  links :feed do
    [
      {
        title:     "Get a single feed",
        profile:   profile_url(:feed),
        href:      api_feed_path_template(api_version: represented.version, id: '{id}') + '{?zoom}',
        templated: true
      }
    ]
  end

  links :feeds do
    [
      {
        title:     "Get a paged collection of feeds",
        profile:   profile_url(:collection, :feeds),
        href:      api_feeds_path_template(api_version: represented.version) + '{?page,per,zoom}',
        templated: true
      }
    ]
  end
end
