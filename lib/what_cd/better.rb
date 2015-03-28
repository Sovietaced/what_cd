require 'logging'
require 'active_support/all'
require 'yaml'

''' 
  This tool is primarily for working through better.php with ease. 
  Essentially this tool will look at an existing release directory with 
  FLAC files and create a matching release with MP3 files. A best attempt
  is made to create an appropriate folder name. Any non-flac files are moved
  over and then flac files are converted to an MP3. 

'''

module Better

  @log = Logging.logger[self]
  @log.appenders = Logging.appenders.stdout

  def self. setup_log(verbose)
    if verbose
      @log.level = :debug
    else
      @log.level = :info
    end
  end

  # Load from config file
  def self.run(path, quality, verbose=false)
    setup_log(verbose)

    # Load configured plugins
    begin
      # Get config
      config = YAML.load_file(WhatCD::CONFIG)
      # Get configured plugins
      configured_plugins = config['commands']['better']['plugins']

      if configured_plugins
        # Run them
        self.run_plugins(path, configured_plugins)
      else
        @log.info "No plugins to run. Edit your config to enable plugins."
      end
    rescue Errno::ENOENT
      @log.error "Missing gem config file '~/.what_cd'"
    end 
  end

  def self.run_plugins(path, configured_plugins)
    # Get this directory
    current_dir = File.dirname(__FILE__)

    # Set the context to be passed around between plugins
    context = {}
    context[:path] = path

    # Iterate over the configured plugins and dynamically execute them
    configured_plugins.each do |configured_plugin|
      file = "#{current_dir}/better_plugins/#{configured_plugin}.rb"
      require file
      file_name = File.basename(file, '.rb')
       # using ActiveSupport for camelcase and constantize
      plugin = file_name.camelcase.constantize
      # Check to ensure ruby file defines a class
      if plugin.class == Class
        @log.info "Bettering with plugin #{plugin}"
        context = plugin.new.better(context)
        @log.debug "context returned as #{context}"
      end
    end
  end
end