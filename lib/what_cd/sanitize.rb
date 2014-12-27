require 'logging'
require 'active_support/all'

class Sanitize

  @log = Logging.logger[self]
  @log.appenders = Logging.appenders.stdout
  if $verbose
    @log.level = :debug
  else
    @log.level = :info
  end

  def self.run(path)
    
    current_dir = File.dirname(__FILE__)

    # Sort for consistency
    Dir["#{current_dir}/sanitize_plugins/*.rb"].sort.each do |file| 
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