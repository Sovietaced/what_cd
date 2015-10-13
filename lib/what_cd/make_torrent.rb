require 'logging'
require 'active_support/all'
require 'yaml'
require 'mktorrent'

module MakeTorrent

  @log = Logging.logger[self]
  @log.appenders = Logging.appenders.stdout

  def self.setup_log(verbose)
    if verbose
      @log.level = :debug
    else
      @log.level = :info
    end
  end

  # Load from config file
  def self.run(path, output_path, verbose=false)
    setup_log(verbose)

    # Load configured plugins
    begin
      # Get config
      config = YAML.load_file(WhatCD::CONFIG)
    rescue Errno::ENOENT
      @log.error "Missing gem config file '~/.what_cd'"
      return
    end 

    # Get configured plugins
    tracker = config['commands']['torrent']['tracker']

    t = Torrent.new(tracker)
    t.set_private
    t.add_directory(path)

    # Determine dir name
    dirs = path.split("/")
    # dir name is last 
    dir_name = dirs[-1]

    t.defaultdir = dir_name

    # Change path to output path before writing file
    Dir.chdir output_path
    t.write_torrent("#{dir_name}.torrent")
  end
end