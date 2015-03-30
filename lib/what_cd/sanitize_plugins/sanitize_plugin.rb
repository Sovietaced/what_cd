module SanitizePlugin

  def sanitize(path)
    raise 'This method should be implemented by every sanitization plugin and return the context regardless of whether it has been modified or not'
  end
end