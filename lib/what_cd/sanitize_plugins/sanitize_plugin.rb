module SanitizePlugin

  def sanitize(path)
    raise 'This method should be implemented by every sanitization plugin and return the path if it has been modified, nil otherwise'
  end
end