require 'mp3info'
require 'logging'

require File.expand_path("../sanitize_plugin", __FILE__)

class DirName
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

  def sanitize(path)
    
    # To get release info we need to look at an mp3
    file_path = get_first_mp3_path(path)

    if file_path
      Mp3Info.open(file_path) do |mp3|
        if mp3.tag.album
          new_dir = mp3.tag.album
          # Add year if available
          if mp3.tag.year 
            new_dir = new_dir + " [#{mp3.tag.year}]"
          end

          parts = path.split("/")
          parts[-1] = new_dir
          new_path = parts.join("/")
          # Add trailing '/' that was removed from splitting
          new_path << '/'
          if new_dir != path.chomp("/")
            @log.debug "Renaming directory to #{new_dir}"
            File.rename(path, new_path)
            return new_path
          end
        end
      end
    end
    return nil
  end

  def get_first_mp3_path(path)
    Dir.entries(path).each do |f|
      if !File.directory?(f) and File.extname(f) == ".mp3"
        file_path = path + f
        return file_path
      end
    end

    return nil
  end
end