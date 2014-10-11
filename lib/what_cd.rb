$:.unshift File.dirname(__FILE__)

class WhatCD

  def initialize(options = {})
    #load_config
    set_options(options)
  end

  def convert(dir)
    raise TypeError, "'#{dir}' is not a directory" unless File.directory?(dir)
    dir = dir.chomp("/")
    process_conversion(dir)
  end

  def process_conversion(dir)
    output_dir = output_dir(dir)
    puts output_dir
    #convert_data(filename, outfile)
  end

  def load_config
    #
  end

  def set_options(options)
    raise TypeError, 'options must be a hash' unless options.is_a?(Hash)
    #@options = config.merge(options)
  end

  def output_dir(dir)
    return dir.gsub 'FLAC', 'MP3 V0' if dir.include? 'FLAC'
    return dir.gsub 'flac', 'MP3 V0' if dir.include? 'flac'
    return dir + ' [MP3 V0]'
  end

  def options
    @options.dup
  end

  def config
    @config.dup
  end

  def encoding
    options[:encoding] || self.class.default_encoding
  end

  def tracker
    options[:tracker]
  end

  class << self

    def convert(dir, options = {})
      new(options).convert(dir)
    end
    
    # V0
    def default_encoding
      '--preset extreme'
    end
  end
end