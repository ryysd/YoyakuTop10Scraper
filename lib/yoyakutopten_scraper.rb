require "yoyakutopten_scraper/version"
require 'typhoeus'
require 'nokogiri'

module YoyakutoptenScraper
  HOST = 'https://yoyaku-top10.jp'.freeze
  class Ranking
    TYPE = [:daily, :total, :new]
    attr_accessor :feed, :os_type

    def initialize(feed:, os_type:, options: {})
      @feed = feed
      @os_type = os_type
    end

    def parse(html)
      apps = html.css '.list_app > .clearfix'

      apps.map{|app|
	icon_container = (app.css '.img_hvr').first
	icon = (app.css '.app_detail_img').first
	title = (app.css 'h2').first
	publisher = (app.css '.app_list_company').first
	plan = (app.css '.app_detail_plan').first
	plan_detail = plan.css 'dd'

        detail_rel_url = icon_container.get_attribute 'href'
	icon_rel_url = icon.get_attribute 'src'
	detail_rel_url.match %r!/[a-zA-Z]+/[a-zA-Z]+/(\w+)!

	{
	  title: title.text,
	  detail_url: "#{YoyakutoptenScraper::HOST}/#{detail_rel_url}",
	  icon: "#{YoyakutoptenScraper::HOST}/#{icon_rel_url}",
	  app_id: $1,
	  release: plan_detail.first.text,
	  reservation: plan_detail.last.text,
	  publisher: publisher.text
	}
      }
    end

    def update
      query = "#{YoyakutoptenScraper::HOST}/pc/r/#{@os_type}/#{@feed}"
      response = Typhoeus.get query
      result = self.parse (Nokogiri::HTML.parse response.body)
      p result
    end
  end
end
