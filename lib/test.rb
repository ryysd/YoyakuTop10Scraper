require 'yoyakutopten_scraper'

ranking = YoyakutoptenScraper::Ranking.new os_type: :ios, feed: :daily
ranking.update

app = ranking.results.first

app_detail = YoyakutoptenScraper::App.new app_id: app[:app_id], os_type: app[:os_type]
bonus_detail = YoyakutoptenScraper::Bonus.new bonus_id: app[:bonus_id], os_type: app[:os_type]

bonus_detail.update
p bonus_detail
