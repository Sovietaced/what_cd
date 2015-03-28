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

    puts artists.join(",")
  end

end