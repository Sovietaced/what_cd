require 'mp3info'
require 'logging'
require 'active_support/all'

require File.expand_path("../sanitize_plugin", __FILE__)

class FileName
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
    Dir.chdir(path) { Dir["*.mp3"] }.each do |f|
      file_name = f
      file_path = path + file_name

      new_file_path = get_fixed_file_path(path, file_name)

      if new_file_path != file_path
        File.rename(file_path, new_file_path)
      end
    end

    return context
  end

  def get_fixed_file_path(path, file_name)
    # Return the original file_path by default
    old_file_path = path + file_name
    new_file_path = old_file_path

    Mp3Info.open(old_file_path) do |mp3|
      if mp3.tag.title and mp3.tag.artist and mp3.tag.tracknum
        @log.debug "Reconstructing file name for #{file_path}"
        title = mp3.tag.title
        artist = mp3.tag.artist
        tracknum = mp3.tag.tracknum.to_s
        # Append a 0 to tracknum if necessary
        if tracknum.length == 1
          tracknum = "0" + tracknum
        end

        # Append a period to the trackname
        tracknum = tracknum + "."

        # Handle any remix parenthesis
        title_parts = title.split('-')
        if title_parts.length > 1
          title_part = title_parts[0].strip
          remix_part = title_parts[1].strip
          
          title = title_part + " (#{remix_part})"
        end

        new_file_path = path + "#{tracknum} #{artist} - #{title}" + File.extname(file_path)
      end
    end

    return new_file_path
  end
end