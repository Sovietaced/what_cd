require 'mp3info'
require 'logging'
require 'active_support/all'

require File.expand_path("../sanitize_plugin", __FILE__)

class Hidden
  include SanitizePlugin

  def initialize
    @log = Logging.logger[self]
    @log.appenders = Logging.appenders.stdout
    @log.level = :warn
  end

  def sanitize(path)
    Dir.entries(path).each do |entry|
      # We only want to remove hidden files... not directories. ASK ME HOW I KNOW!
      if !File.directory? entry
        # Remove hidden files
        if entry.start_with? "."
          @log.debug "Deleting hidden file #{entry}"
          FileUtils.rm_rf entry
        end
      end
    end

    return nil
  end
end