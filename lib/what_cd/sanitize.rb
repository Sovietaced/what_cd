require 'logging'
require 'active_support/all'
require 'yaml'

module Sanitize

  @log = Logging.logger[self]
  @log.appenders = Logging.appenders.stdout
  if $verbose
    @log.level = :debug
  else
    @log.level = :info
  end

  # Load from config file
  def self.run(path)

    # Load configured plugins
    begin
      # Get config
      config = YAML.load_file(WhatCD::CONFIG)
      # Get configured plugins
      configured_plugins = config['commands']['sanitize']['plugins']
      # Run them
      self.run_plugins(path, configured_plugins)
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
      file = "#{current_dir}/sanitize_plugins/#{configured_plugin}.rb"
      require file
      file_name = File.basename(file, '.rb')
       # using ActiveSupport for camelcase and constantize
      plugin = file_name.camelcase.constantize
      # Check to ensure ruby file defines a class
      if plugin.class == Class
        @log.info "Sanitizing with plugin #{plugin}"
        context = plugin.new.sanitize(context)
        @log.debug "Context returned as #{context}"
      end
    end
  end
end