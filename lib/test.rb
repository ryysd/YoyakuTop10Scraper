require 'yoyakutopten_scraper'

ranking = YoyakutoptenScraper::Ranking.new os_type: :ios, feed: :daily
ranking.update

app = ranking.results.first

#app_detail = YoyakutoptenScraper::App.new app_id: app[:app_id], os_type: app[:os_type]
app_detail = YoyakutoptenScraper::App.new app_id: 'MzI5MA', os_type: 'ios'
bonus_detail = YoyakutoptenScraper::Bonus.new bonus_id: app[:bonus_id], os_type: app[:os_type]

app_detail.update
p app_detail
bonus_detail.update
p bonus_detail
