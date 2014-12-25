require 'mp3info'

module Escort
  class ArtistsCommand < ::Escort::ActionCommand::Base

    def run(dir)

      artists = []

      Dir.entries(dir).each do |f|
        if !File.directory? f
          # Fix Tags
          if File.extname(f) == ".mp3"
            filename = File.basename(f, File.extname(f))
            path = dir + f
            
            Mp3Info.open(path) do |mp3|
              if mp3.tag.artist
                artists.push(mp3.tag.artist)
              end
            end
          end
        end
      end

      puts artists.join(",")
    end

    def execute
      #Escort::Logger.output.puts "Command: #{command_name}"
      #Escort::Logger.output.puts "Options: #{options}"
      Escort::Logger.output.puts "Command options: #{command_options}"
      Escort::Logger.output.puts "Arguments: #{arguments}"
      if arguments.length > 0
        dir = arguments[0]
        run(dir)
      else
        puts "Missing directory argument"
      end
    end
  end
end