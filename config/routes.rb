require 'ping'

Rails.application.routes.draw do

  namespace :api do
    scope ':api_version', api_version: 'v1' do

      root to: 'base#entrypoint'
      match '*any', via: [:options], to: 'base#options'

      resources :feeds do
        resources :entries, controller: 'feed_entries', except: [:new, :edit]
      end
      resources :entries, controller: 'feed_entries'
    end
  end

  mount Ping, at: 'ping'
end
