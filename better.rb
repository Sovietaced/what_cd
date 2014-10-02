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

  flac_files = Dir.entries(dir).select { |e| e.include? '.flac' }

  if flac_files.empty?
    puts "No flac files found. Exiting"
    exit
  end

  flac_files.each do |flac_file|
    puts "Converting #{flac_file}"
    cmd = "cd #{Shellwords.escape(new_dir)}; flac2mp3 #{Shellwords.escape(dir +  flac_file)} > /dev/null 2>&1"
    output = system "bash -c \"#{cmd}\""
  end
end

def determine_new_dir_name(new_dir)
  if new_dir.include? 'FLAC'
    new_dir.gsub! 'FLAC', 'MP3 V0'
  else
    new_dir.gsub! '/', ' [MP3 V0]/'
  end
end

def copy_files(dir, new_dir)
  # Copy all files from dir to new_dir
  cmd = "cp -r #{Shellwords.escape(dir)}/* #{Shellwords.escape(new_dir)}"
  system "bash -c \"#{cmd}\""

  # Remove any flac files, as they will be replaced by MP#s
  cmd = "rm #{Shellwords.escape(new_dir)}*.flac"
  system "bash -c \"#{cmd}\""
end

def main

  #TODO: bring this out...
  if ARGV.empty?
    puts "Missing folder argument"
    return
  elsif ARGV.count > 1
    puts "This only takes a single arg..."
    return
  end

  # parse CLI args
  dir = ARGV[0].dup

  # clear up inconsistencies
  if dir.chars.last != '/'
    dir = dir + '/'
  end

  # Since mutable
  new_dir = dir.dup

  determine_new_dir_name(new_dir)

  # Attach to full path
  dir = Dir.pwd + "/" + dir
  new_dir = Dir.pwd + "/" + new_dir

  # Create the new directory if it does not exist
  Dir.mkdir(new_dir) unless File.exists?(new_dir)

  copy_files(dir,new_dir)

  # Finally, convert to MP3 V0 if necessary
  convert(dir, new_dir)

  puts "Woot! Conversion successful!"
  puts "Find your files in #{new_dir}"
end

# Start
main
