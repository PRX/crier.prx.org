require 'say_when'
# require 'say_when/poller/concurrent_poller'

# you can specify a the logger
SayWhen.logger = Rails.logger

# configure the scheduler for how to store and process scheduled jobs
# it will default to a :memory strategy and :simple processor
SayWhen.configure do |options|
  # options[:storage_strategy]   = :memory
  options[:storage_strategy] = :active_record

  # options[:processor_strategy] = :simple
  options[:processor_strategy] = :active_job

  options[:queue] = :crier_default
end

# # for use with Shoryuken >= 3.x
# poller = SayWhen::Poller::ConcurrentPoller.new(5)
# poller.start