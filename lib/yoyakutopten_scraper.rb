require "yoyakutopten_scraper/version"
require 'typhoeus'
require 'nokogiri'

module YoyakutoptenScraper
  HOST = 'https://yoyaku-top10.jp'.freeze
  PC_PREFIX = 'u/a'
  MOBILE_PREFIX = 'sp/r'
  ANDROID_USER_AGENT = 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; IS01 Build/S3082) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
  IOS_USER_AGENT = 'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25'

  def self.make_absolute_url(url)
    "#{YoyakutoptenScraper::HOST}/#{url}"
  end

  class Bonus
    def initialize(bonus_id:)
      @bonus_id = bonus_id
    end

    def parse(html)
      img = ((html.css '.app_detail_bonus_imgArea').first.css 'img').first
      description = (html.css '.app_description').first

      detail = (html.css '.reserv_detail').first
      reserved_num = (detail.css '.reserv_detail_num').first
      current_reserved = (reserved_num.css 'li')[1]
      max_reserved     = (reserved_num.css 'li')[2]

      {
	img_url: (img.get_attribute 'src'),
	description: description.text,
	current_reserved: current_reserved.text,
	max_reserved: max_reserved.text
      }
    end

    def update
      query = "#{YoyakutoptenScraper::HOST}/#{YoyakutoptenScraper::MOBILE_PREFIX}/#{@bonus_id}/bonus"
      request = Typhoeus::Request.new query,
	method: 'get',
	headers: {:"User-Agent" => YoyakutoptenScraper::ANDROID_USER_AGENT},
	followlocation: true

      response = request.run
      self.parse (Nokogiri::HTML.parse response.body)
    end
  end

  class App
    def initialize(app_id:)
      @app_id = app_id
    end

    def parse(html)
      detail = (html.css '.app_detail_box').first
      icon = (detail.css '.app_detail_img').first
      title = (detail.css 'h1').first
      publisher = (detail.css '.app_company').first
      release = ((detail.css '.app_released').first.css 'dd').last
      reservation = (detail.css '.app_booking').first
      current_reserved = (reservation.css 'li')[1]
      max_reserved = (reservation.css 'li')[2]

      video = (html.css '.app_detail_movie').first

      unless video.nil?
        video_frame = (video.css 'iframe').first
	video_url = video_frame.get_attribute 'src'
      end

      screenshot_container = (html.css '.gallery_wrap').first
      screenshots = screenshot_container.css '.item'
      screenshot_urls = screenshots.map do |ss| 
	rel_url = (ss.css 'img').first.get_attribute 'src'
	YoyakutoptenScraper.make_absolute_url rel_url
      end

      description = (html.css '.app_description').first

      bonus_detail = (html.css '.bonus_detail').first
      unless bonus_detail.nil?
	bonus = ((bonus_detail.css '.btn_bounus').first.css 'a').first

        bonus_rel_url = bonus.get_attribute 'href'
        bonus_rel_url.match %r!/[a-zA-Z]+/[a-zA-Z]+/(\w+)!
        bonus_url = YoyakutoptenScraper.make_absolute_url bonus_rel_url
        bonus_id = $1
      else
        bonus_id = ''
        bonus_url = ''
      end

      {
        title: title.text,
	icon: (YoyakutoptenScraper.make_absolute_url (icon.get_attribute 'src')),
        publisher: publisher.text,
        release: release.text,
	current_reserved: current_reserved.text,
	max_reserved: max_reserved.text,
        screenshot_urls: screenshot_urls,
        description: description.text,
	video_url: video_url
      }
    end

    def _parse(html)
      screenshots = html.css '.app_detail_gallery'
      video       = (html.css '.app_detail_movie').first
      video_frame = (video.css 'iframe').first
      description = (html.css '.app_detail_text').first
      os_type     = (html.css '.support_app').first.css 'p'
      plan        = (html.css '.app_detail_plan').first
      plan_detail = plan.css 'dd'

      screenshot_urls = (screenshots.css 'li').map{|ss| (ss.css 'img').first.get_attribute 'src'}
      screenshot_urls = screenshot_urls.map{|ss| "#{YoyakutoptenScraper::HOST}/#{ss}"}

      header    = (html.css '.app_detail_box').first
      title     = (header.css 'h2').first
      icon      = (header.css 'img').first
      publisher = (header.css '.app_detail_company').first
      price     = (header.css '.app_detail_price').first.css 'dd'

      icon_rel_url = icon.get_attribute 'src'

      plan_detail.last.text.match %r!([0-9|,]+)/([0-9|,]+)!
      current_reserved = $1
      max_reserved     = $2

      bonus = (html.css '.bonus_btnArea').first

      {
        title:            title.text,
        detail_url:       "#{YoyakutoptenScraper::HOST}/#{YoyakutoptenScraper::PREFIX}/#{@app_id}",
        icon:             "#{YoyakutoptenScraper::HOST}/#{icon_rel_url}",
        app_id:           @app_id,
        release:          plan_detail.first.text,
        current_reserved: current_reserved,
        max_reserved:     max_reserved,
        publisher:        publisher.text,
        description:      description.text,
        screenshot_urls: screenshot_urls,
        video_url:       (video_frame.get_attribute 'src'),
        price:           price.text,
        os_type:         os_type.text,
        has_bonus:       !bonus.nil?
      }
    end

    def update
      query = "#{YoyakutoptenScraper::HOST}/#{YoyakutoptenScraper::PC_PREFIX}/#{@app_id}"
      request = Typhoeus::Request.new query,
	method: 'get',
	headers: {:"User-Agent" => YoyakutoptenScraper::ANDROID_USER_AGENT},
	followlocation: true
      response = request.run
      self.parse (Nokogiri::HTML.parse response.body)
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
      apps = html.css '.rank_content'

      apps.map do |app|
	title = (app.css '.rank_title').first
	price = (app.css '.rank_price').first
	banner = ((app.css '.rank_bnr').first.css 'a').first
	banner_img = (banner.css 'img').first

	info = (app.css '.bg_rank_summary').first
	release = ((info.css '.rank_released').first.css 'li').last

	detail_rel_url = banner.get_attribute 'href'
        detail_rel_url.match %r!/[a-zA-Z]+/[a-zA-Z]+/(\w+)!
	detail_url = YoyakutoptenScraper.make_absolute_url detail_rel_url
        app_id = $1

	special = (info.css '.btn_special').first

	unless special.nil?
	  bonus = (special.css 'a').first
	  bonus_rel_url = bonus.get_attribute 'href'
          bonus_rel_url.match %r!/[a-zA-Z]+/[a-zA-Z]+/(\w+)!
	  bonus_url = YoyakutoptenScraper.make_absolute_url bonus_rel_url
          bonus_id = $1
	else
	  bonus_id = ''
	  bonus_url = ''
	end

	banner_rel_url = (banner_img.get_attribute 'src')
	banner_url = YoyakutoptenScraper.make_absolute_url banner_rel_url

	{
	  title: title.text,
	  price: price.text,
          detail_url: detail_url,
	  banner_img_url: banner_url,
	  app_id: app_id,
	  release: release.text,
	  bonus_id: bonus_id, 
	  bonus_url: bonus_url,
	}
      end
    end

    def update
      query = "#{YoyakutoptenScraper::HOST}/pc/r/#{@os_type}/#{@feed}"
      request = Typhoeus::Request.new query,
	method: 'get',
	headers: {:"User-Agent" => YoyakutoptenScraper::ANDROID_USER_AGENT},
	followlocation: true

      response = request.run
      self.parse (Nokogiri::HTML.parse response.body)
    end
  end
end
