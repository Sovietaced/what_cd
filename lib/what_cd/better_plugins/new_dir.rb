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
    path = context[:path]
    quality = context[:quality]
    new_path = determine_new_dir_name(path, quality)

    @log.info "Creating path for MP3 files at #{new_path} and copying files over"
    # Create the new directory if it does not exist
    FileUtils.cp_r path, new_path unless File.exists?(new_path)

    context[:path] = new_path
    return context
  end

    # Intelligently decide on a new directory name
  def determine_new_dir_name(path, quality)
    if path.include? 'FLAC'
      return path.gsub 'FLAC', "MP3 #{quality}"
    elsif path.include? 'flac'
      return path.gsub 'flac', "MP3 #{quality}"
    else
      return path.gsub '/', " [MP3 #{quality}]"
    end
  end

  def description
    "Creates a new directory for the MP3 files that will be converted from FLAC"
  end
end