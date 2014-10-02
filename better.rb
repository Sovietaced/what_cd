#!/usr/bin/ruby 
require 'shellwords'

''' 
  This tool is primarily for working through better.php with ease. 
  Essentially this tool will look at an existing release directory with 
  FLAC files and create a matching release with MP3 V0 files. A best attempt
  is made to create an appropriate folder name. Any non-flac files are moved
  over and then flac files are converted to MP3 V0. 

  Dependencies: 
    flac2mp3: https://github.com/ymendel/flac2mp3

'''

def convert(dir, new_dir) 
  mp3_files = `ls #{Shellwords.escape(dir)}| grep mp3`

  if mp3_files.empty?
    puts "No MP3 files found. Converting!"

    flac_files = Dir.entries(dir).select { |e| e.include? '.flac' }

    flac_files.each do |flac_file|
      cmd = "cd #{Shellwords.escape(new_dir)}; flac2mp3 #{Shellwords.escape(dir +  flac_file)}"
      system "bash -c \"#{cmd}\""
    end
  end
end

def main

  if ARGV.empty?
    puts "Missing folder argument"
    return
  elsif ARGV.count > 1
    puts "This only takes a single arg..."
    return
  end
  # parse CLI args
  dir = ARGV[0].dup
  # Since mutable
  new_dir = dir.dup

  if dir.include? 'FLAC'
    new_dir.gsub! 'FLAC', 'MP3 V0'
  else
    # append new name
    new_dir.gsub! '/', ' [MP3 V0]/'
  end

  # Attach to full path
  dir = Dir.pwd + "/" + dir
  new_dir = Dir.pwd + "/" + new_dir

  # Create the new directory if it does not exist
  Dir.mkdir(new_dir) unless File.exists?(new_dir)


  # Copy all files from dir to new_dir
  cmd = "cp -r #{Shellwords.escape(dir)} #{Shellwords.escape(new_dir)}"
  system "bash -c \"#{cmd}\""

  # Remove any flac files, as they will be replaced by MP#s
  cmd = "rm #{Shellwords.escape(new_dir)}*.flac"
  system "bash -c \"#{cmd}\""

  # Finally, convert to MP3 V0 if necessary
  convert(dir, new_dir)
end

# Start
main
