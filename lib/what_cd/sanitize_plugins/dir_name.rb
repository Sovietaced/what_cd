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

  def sanitize(context)
    path = context[:path]
    # To get release info we need to look at an mp3
    file_path = get_first_mp3_path(path)

    if file_path
      @log.debug "Opening file_path #{file_path}"

      single_artist = is_single_artist?(path)

      Mp3Info.open(file_path) do |mp3|
        if mp3.tag.album
          new_dir = mp3.tag.album

          # Prepend artist name if all tracks are by the same artist
          if single_artist
            new_dir = "#{mp3.tag.artist} - #{new_dir}"
          end

          new_dir = handle_year_tags(mp3, new_dir)

          quality = get_quality_string(mp3.bitrate, mp3.vbr)
          new_dir = "#{new_dir} #{quality}"

          parts = path.split("/")
          parts[-1] = new_dir
          new_path = parts.join("/")
          # Add trailing '/' that was removed from splitting
          new_path << '/'
          if new_dir != path.chomp("/")
            @log.debug "Renaming directory to #{new_dir}"
            File.rename(path, new_path)
            context[:path] = new_path
          end
        end
      end
    end
    return context
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

  def is_single_artist?(path)
    artists = []
    Dir.entries(path).each do |f|
      if !File.directory?(f) and File.extname(f) == ".mp3"
        file_path = path + f
        Mp3Info.open(file_path) do |mp3|
          artists.push(mp3.tag.artist)
        end
      end
    end

    if artists.uniq.count == 1
      return true
    end

    return false
  end

  def handle_year_tags(mp3, new_dir)
    if mp3.tag.year 
      new_dir = "#{new_dir} [#{mp3.tag.year}]"
    elsif mp3.tag2.TDRC
      new_dir = "#{new_dir} [#{mp3.tag2.TDRC}]"
    end

    return new_dir
  end

  def get_quality_string(bitrate, vbr)
    if vbr
      if bitrate > 230 
        return "[MP3 V0]"
      elsif bitrate > 190
        return "[MP3 V2]"
      end
    else
      return "[MP3 #{bitrate}]"
    end
  end
end