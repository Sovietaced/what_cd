require 'mp3info'
require 'logging'
require 'active_support/all'

require File.expand_path("../sanitize_plugin", __FILE__)

class FileName
  include SanitizePlugin

  def initialize
    @log = Logging.logger[self]
    @log.appenders = Logging.appenders.stdout
    @log.level = :warn
  end

  def sanitize(path)
    Dir.entries(path).each do |f|
      if !File.directory?(f) and File.extname(f) == ".mp3"
        file_name = f
        file_path = path + file_name

        new_file_name = get_fixed_file_name(file_path)

        if new_file_name != file_name
          new_file_path = path + new_file_name
          File.rename(file_path, new_file_path)
        end
      end
    end

    return nil
  end

  def get_fixed_file_name(file_path)
    # Return the original file_path by default
    new_file_path = file_path

    Mp3Info.open(file_path) do |mp3|
      if mp3.tag.title and mp3.tag.artist and mp3.tag.tracknum
        @log.info "Reconstructing file name"
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

        new_file_path = "#{tracknum} #{artist} - #{title}" + File.extname(file_path)
      end
    end

    return new_file_path
  end
end