require 'logging'

require File.expand_path("../better_plugin", __FILE__)

class Convert

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

    if quality == "320"
      convert(path, "insane")
    elsif quality == "V0"
      convert(path, "extreme")
    else 
      # rage
    end

    # Remove old flac files
    cleanup(path)

    return context
  end

  def convert(path, preset) 

    files = Dir.chdir(path) { Dir["*.flac"] }

    files.each do |flac_file|
      @log.info "Converting #{flac_file}"
      cmd = "cd #{Shellwords.escape(path)}; flac2mp3 #{Shellwords.escape(flac_file)} --encoding='--preset #{preset}' > /dev/null 2>&1"
      output = system "bash -c \"#{cmd}\""
    end
  end

  def cleanup(path)
    files = Dir.chdir(path) { Dir["*.flac"] }

    files.each do |flac_file|
      @log.info "Deleting #{flac_file}"
      FileUtils.rm_rf(path + flac_file)
    end
  end

  def description
    "Creates a new directory for the MP3 files that will be converted from FLAC"
  end
end