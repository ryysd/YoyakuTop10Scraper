require 'yoyakutopten_scraper'

ranking = YoyakutoptenScraper::Ranking.new os_type: :ios, feed: :daily
result = ranking.update

app = result.first

app = YoyakutoptenScraper::App.new app_id: app[:app_id]
app.update
