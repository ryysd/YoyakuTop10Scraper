require 'yoyakutopten_scraper'

ranking = YoyakutoptenScraper::Ranking.new os_type: :ios, feed: :daily
ranking.update
