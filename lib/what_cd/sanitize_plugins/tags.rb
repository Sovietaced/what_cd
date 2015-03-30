require 'mp3info'
require 'logging'

require File.expand_path("../sanitize_plugin", __FILE__)

class Tags 

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
    
    Dir.entries(path).each do |f|
      if !File.directory?(f) and File.extname(f) == ".mp3"
        file_path = path + f
        Mp3Info.open(file_path) do |mp3|
          # Remove all comments
          if not mp3.tag.comments.nil? or not mp3.tag2.COMM.nil?
            mp3.tag.comments = nil
            mp3.tag2.COMM = nil
          end

          # Handle publisher tag
          mp3.tag2.TPUB = nil         
        end
      end
    end
    return context
  end
end