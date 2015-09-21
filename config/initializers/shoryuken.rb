require 'shoryuken'

config_file = File.join(Rails.root, 'config', 'shoryuken.yml')
Shoryuken::EnvironmentLoader.load(config_file: config_file)

Shoryuken.configure_server do |config|
  Rails.logger = Shoryuken::Logging.logger
end

Shoryuken.active_job_queue_name_prefixing = true
