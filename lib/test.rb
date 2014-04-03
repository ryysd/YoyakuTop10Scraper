require 'yoyakutopten_scraper'

ranking = YoyakutoptenScraper::Ranking.new os_type: :ios, feed: :daily
result = ranking.update

app = result.first

app_detail = YoyakutoptenScraper::App.new app_id: app[:app_id]
bonus_detail = YoyakutoptenScraper::Bonus.new bonus_id: app[:bonus_id]

app_result = app_detail.update
bonus_result = bonus_detail.update
p bonus_result
