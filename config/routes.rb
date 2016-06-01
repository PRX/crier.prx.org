require 'ping'

Rails.application.routes.draw do

  namespace :api do
    scope ':api_version', api_version: 'v1' do

      root to: 'base#entrypoint'
      match '*any', via: [:options], to: 'base#options'

      resources :feeds, only: [:show, :index] do
        resources :entries, controller: 'feed_entries', only: [:show, :index]
      end
      resources :entries, controller: 'feed_entries', only: [:show, :index]
    end
  end

  mount Ping, at: 'ping'
end
