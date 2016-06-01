# set the application version if not already set
ENV['CRIER_VERSION'] ||= `cat VERSION`.chomp
