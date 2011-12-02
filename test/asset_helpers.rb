module AssetHelpers

  def http_response(name)
    name += ".txt"
    path = File.join(File.dirname(__FILE__), 'http_responses', name)
    File.read(path)
  end

end
