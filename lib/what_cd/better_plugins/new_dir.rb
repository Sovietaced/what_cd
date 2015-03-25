require 'logging'

require File.expand_path("../better_plugin", __FILE__)

class NewDir

  include BetterPlugin

  def initialize
    @log = Logging.logger[self]
    @log.appenders = Logging.appenders.stdout
    if $verbose
      @log.level = :debug
    else
      @log.level = :info
    end
  end

  def better(context)
    context
  end

  def description
    "Creates a new directory for the MP3 files that will be converted from FLAC"
  end
end