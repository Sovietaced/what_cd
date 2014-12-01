require 'mp3info'

module Escort
  class CleanCommand < ::Escort::ActionCommand::Base

    def fix_tags(old_path, filename)
      Mp3Info.open(old_path) do |mp3|
        # Remove all comments
        if mp3.tag.comments or mp3.tag2.COMM
          puts "Removing tags"
          mp3.tag.comments = nil
          mp3.tag2.COMM = nil
        end

        # Create a perfect file name if possible
        if mp3.tag.title and mp3.tag.artist and mp3.tag.tracknum
          puts "Reconstructing file name"
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

          filename = "#{tracknum} #{artist} - #{title}"
        end
      end
      return filename
    end

    # Determines if the track number is properly formatted
    # Returns an improved name if it isn't
    def fix_track_num(filename)
      # Track # -> Track # with period
      # Check to see if name conforms
      if not /^\d+\./.match(filename)
        # Does not conform, let's make it conform
        match = /^\d+/.match(filename)

        if match
          track_num = match.to_s
          track_num_with_period = track_num + "."
          return filename.sub(track_num, track_num_with_period)
        else
          puts "Cannot format track \# for #{filename}"
        end
      end

      return filename
    end

    def sub_paren(str, filename)
      if /#{str}/.match(filename)
        if not /\(#{str}\)/.match(filename)
          filename = filename.sub("#{str}", "(#{str})")
        end
      end

      return filename
    end

    def add_mix_paren(filename)
      filename = sub_paren("Radio Edit", filename)
      filename = sub_paren("Radio Mix", filename)
      filename = sub_paren("Radio Cut", filename)
      return filename
    end

    def run(dir)

      Dir.entries(dir).each do |f|
        if !File.directory? f
          filename = File.basename(f, File.extname(f))
          old_path = dir + f
          puts "Processing #{filename}"

          # Fix Tags
          if File.extname(f) == ".mp3"
            # fix tags
            filename = fix_tags(old_path, filename)
            # Fix track number
            filename = fix_track_num(filename)
            # Add paren to mix
            filename = add_mix_paren(filename)
          end

          # Underscore -> Space
          filename = filename.gsub('_', ' ')

          # Finally rename the file
          new_path = dir + filename + File.extname(f)
            
          # Only rename the file if nothing has changed.
          if old_path != new_path
            File.rename(old_path, new_path)
          else
            puts "Nothing has changed. Not renaming file"
          end

        end
      end
    end

    def execute
      #Escort::Logger.output.puts "Command: #{command_name}"
      #Escort::Logger.output.puts "Options: #{options}"
      Escort::Logger.output.puts "Command options: #{command_options}"
      Escort::Logger.output.puts "Arguments: #{arguments}"
      if command_options[:dir]
        dir = command_options[:dir]
        run(dir)
      else
        puts "Missing directory option"
      end
    end
  end
end