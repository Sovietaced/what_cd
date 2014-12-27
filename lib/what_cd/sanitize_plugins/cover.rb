require 'logging'

require File.expand_path("../sanitize_plugin", __FILE__)

class Cover 

  include SanitizePlugin

  def initialize
    @log = Logging.logger[self]
    @log.appenders = Logging.appenders.stdout
    @log.level = :info
  end

  def sanitize(path)
    images = Dir.chdir(path) { Dir["*.jpg"] }

    if images.count == 1
      file_name = images[0]
      file_path = path + file_name
      new_file_path = path + '00. cover.jpg'
      File.rename(file_path, new_file_path)
    elsif images.count > 1
      @log.info "Several .jpg files in release directory. Unable to determine cover art."
    else
      @log.debug "No .jpg files found in release directory."
    end

    return nil
  end
end