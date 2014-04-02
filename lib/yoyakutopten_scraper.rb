require "yoyakutopten_scraper/version"
require 'typhoeus'
require 'nokogiri'

module YoyakutoptenScraper
  HOST = 'https://yoyaku-top10.jp'.freeze
  PREFIX = 'u/a'

  class App
    def initialize(app_id:)
      @app_id = app_id
    end

    def parse(html)
      screenshots = html.css '.app_detail_gallery'
      video = (html.css '.app_detail_movie').first
      video_frame = (video.css 'iframe').first
      description = (html.css '.app_detail_text').first
      os_type = (html.css '.support_app').first.css 'p'

      screenshot_urls = (screenshots.css 'li').map{|ss| (ss.css 'img').first.get_attribute 'src'}
      screenshot_urls = screenshot_urls.map{|ss| "#{YoyakutoptenScraper::HOST}/#{ss}"}

      header = (html.css '.app_detail_box').first
      title = (header.css 'h2').first
      icon = (header.css 'img').first
      publisher = (header.css '.app_detail_company').first
      price = (header.css '.app_detail_price').first.css 'dd'

      icon_rel_url = icon.get_attribute 'src'

      plan = (html.css '.app_detail_plan').first
      plan_detail = plan.css 'dd'

      plan_detail.last.text.match %r!([0-9|,]+)/([0-9|,]+)!
      current_reserved = $1
      max_reserved = $2

      {
	title: title.text,
	detail_url: "#{YoyakutoptenScraper::HOST}/#{YoyakutoptenScraper::PREFIX}/#{@app_id}",
	icon: "#{YoyakutoptenScraper::HOST}/#{icon_rel_url}",
	app_id: @app_id,
	release: plan_detail.first.text,
	current_reserved: current_reserved,
	max_reserved: max_reserved,
	publisher: publisher.text,
	description: description.text,
	screenshot_urls: screenshot_urls,
	video_url: (video_frame.get_attribute 'src'),
	price: price.text,
	os_type: os_type.text
      }
    end

    def update
      query = "#{YoyakutoptenScraper::HOST}/#{YoyakutoptenScraper::PREFIX}/#{@app_id}"
      response = Typhoeus.get query
      result = self.parse (Nokogiri::HTML.parse response.body)
      p result
    end
  end

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
	app_id = $1

	plan_detail.last.text.match %r!(\d+) / (\d+)!
	current_reserved = $1
	max_reserved = $2

	{
	  title: title.text,
	  detail_url: "#{YoyakutoptenScraper::HOST}/#{detail_rel_url}",
	  icon: "#{YoyakutoptenScraper::HOST}/#{icon_rel_url}",
	  app_id: app_id,
	  release: plan_detail.first.text,
	  current_reserved: current_reserved,
	  max_reserved: max_reserved,
	  publisher: publisher.text
	}
      }
    end

    def update
      query = "#{YoyakutoptenScraper::HOST}/pc/r/#{@os_type}/#{@feed}"
      response = Typhoeus.get query
      self.parse (Nokogiri::HTML.parse response.body)
    end
  end
end
