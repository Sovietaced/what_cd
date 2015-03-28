require 'logging'
require 'active_support/all'
require 'yaml'
require 'mp3info'

module Metadata

  @log = Logging.logger[self]
  @log.appenders = Logging.appenders.stdout
  if $verbose
    @log.level = :debug
  else
    @log.level = :info
  end

  # Load from config file
  def self.run(path)

    metadata = {}
    metadata['album_title'] = self.get_album_title(path)
    metadata['artists'] = self.get_artists(path)
    metadata['year'] = self.get_year(path)
    # We only handle MP3 files at the moment
    metadata['format'] = 'MP3'
    metadata ['bitrate'] = self.get_bitrate(path)


    puts metadata
  end

  def self.get_artists(path)
    artists = []

    Dir.entries(path).each do |f|
      if !File.directory? f
        # Fix Tags
        if File.extname(f) == ".mp3"
          filename = File.basename(f, File.extname(f))
          file_path = path + f
          
          Mp3Info.open(file_path) do |mp3|
            if mp3.tag.artist
              artists.push(mp3.tag.artist)
            end
          end
        end
      end
    end

    return artists
  end

  def self.get_year(path)
    file_path = self.get_first_mp3(path)

    if file_path
      Mp3Info.open(file_path) do |mp3|
        return mp3.tag.year
      end
    end
  end

  def self.get_album_title(path)
    file_path = self.get_first_mp3(path)

    if file_path
      Mp3Info.open(file_path) do |mp3|
        return mp3.tag.album
      end
    end
  end

  def self.get_first_mp3(path)
    Dir.entries(path).each do |f|
      if !File.directory? f
        # Fix Tags
        if File.extname(f) == ".mp3"
          filename = File.basename(f, File.extname(f))
          file_path = path + f
          return file_path
        end
      end
    end
  end

  def self.get_bitrate(path)
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

    vbr_list = bitrates.values.map{|value| value[:vbr] }
    # Will only have 1-2 count (true & false)
    if vbr_list.uniq.count > 1
      raise BitrateError.new("Release has both constant and variable bitrate tracks!")
    else 
      vbr = vbr_list.first
    end

    bitrate_list = bitrates.values.map{|value| value[:bitrate] }
    # Remove duplicates
    uniq_bitrate_list = bitrate_list.uniq

    # If the only vbr value is false, this is CBR
    if not vbr and uniq_bitrate_list.uniq.count > 1
      raise BitrateError.new("Release tracks are constant bit rate but multiple bitrates found!")
    elsif vbr 
      puts  "Calculating average bitrate"
      # Determine average VBR of release
      avg_bitrate = bitrate_list.inject(:+) / bitrate_list.length
      if avg_bitrate > 220
        return 'V0 (VBR)'
      elsif avg_bitrate > 192
        return 'V2 (VBR)'
      else 
        raise BitrateError.new("Release average bit rate is too low")
      end
    else
      return bitrate_list.first
    end
  end

  class BitrateError < StandardError

end

end