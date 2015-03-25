module BetterPlugin

  def better(context)
    raise 'This method should be implemented by every better plugin and return the context, modified or not'
  end

  def description
    raise 'This method should be implemented by every better plugin and describe the plugin'
  end
end