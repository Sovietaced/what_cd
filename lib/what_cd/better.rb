require 'logging'
require 'active_support/all'
require 'yaml'

module Better

  @log = Logging.logger[self]
  @log.appenders = Logging.appenders.stdout
  if $verbose
    @log.level = :debug
  else
    @log.level = :info
  end

  # Load from config file
  def self.run(path, quality)

  end
end