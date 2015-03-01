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
      
    # Get this direciton
    current_dir = File.dirname(__FILE__)

    # Load configured plugins
    begin
      config = YAML.load_file(WhatCD::CONFIG)
      configured_plugins = config['commands']['sanitize']['plugins']

      run_plugins(configured_plugins)
    rescue Errno::ENOENT
      @log.error "Missing gem config file '~/.what_cd'"
    end 
  end

  def run_plugins(configured_plugins)
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
        new_path = plugin.new.sanitize(path)
        @log.debug "new path returns as #{new_path}"
        # Change operating path if a plugin has changed it
        path = new_path if new_path
      end
    end
  end
end