require 'logging'
require 'mp3info'

require File.expand_path("../sanitize_plugin", __FILE__)

class Bitrate

  include SanitizePlugin

  def initialize
    @log = Logging.logger[self]
    @log.appenders = Logging.appenders.stdout
    if $verbose
      @log.level = :debug
    else
      @log.level = :info
    end
  end

  def sanitize(context)
    path = context[:path]
    files = Dir.chdir(path) { Dir["*.mp3"] }
    return if files.empty?

    bitrates = {}

    files.each do |file_name|
      file_path = path + file_name
      Mp3Info.open(file_path) do |mp3|
        hash = {:bitrate => mp3.bitrate, :vbr => mp3.vbr}
        bitrates[file_name] = hash
      end
    end

    # TODO: Improve this to print out the violating file name
    vbr_list = bitrates.values.map{|value| value[:vbr] }
    if vbr_list.uniq.count > 1
      raise BitrateError.new("Release has both constant and variable bitrate tracks!")
    else 
      vbr = vbr_list.first
    end

    bitrate_list = bitrates.values.map{|value| value[:bitrate] }
    # Remove duplicates
    bitrate_list = bitrate_list.uniq

    # If the only vbr value is false, this is CBR
    if not vbr and bitrate_list.uniq.count > 1
      raise BitrateError.new("Release tracks are constant bit rate but multiple bitrates found!")
    else
      bitrate = bitrate_list.first
    end

    if vbr
      @log.info "Variable bitrate detected"
    else
      @log.info "Constant bitrate detected at #{bitrate} kbps"
    end

    return context
  end
end

class BitrateError < StandardError

end