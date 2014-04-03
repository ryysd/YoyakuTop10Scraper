module YoyakutoptenScraper
  def self.make_absolute_url(url)
    "#{YoyakutoptenScraper::HOST}/#{url}"
  end
end