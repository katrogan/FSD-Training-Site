require 'open-uri'
class Prezi < Component

  belongs_to :lesson

  def self.isValidUrl?(url)
    reg = /^http(s)?:\/\/prezi\.com\/([^\/]+)\/(.*)$/
    super(url, reg)
  end

  def self.embeddableUrl(url)
    reg = /^http(s)?:\/\/prezi\.com\/([^\/]+)\/(.*)$/
    matches = reg.match(url)
    return matches[2]
  end
end
