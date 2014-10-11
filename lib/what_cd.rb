#$:.unshift File.dirname(__FILE__)

class WhatCD

  def initialize(options = {})
  end

  class << self
    # V0
    def default_encoding
      '--preset extreme'
    end
  end
end