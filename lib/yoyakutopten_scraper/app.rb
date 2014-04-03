module YoyakutoptenScraper
  class App
    attr_reader :title, :icon, :publisher, :release, :current_reserved, :max_reserved,
      :screenshot_urls, :description, :video_url, :bonus_id, :bonus_url, :website_url
    def initialize(app_id:, os_type:)
      @app_id = app_id
      @os_type = os_type
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

      @title            = title.text
      @icon             = (YoyakutoptenScraper.make_absolute_url (icon.get_attribute 'src'))
      @publisher        = publisher.text
      @release          = release.text
      @current_reserved = current_reserved.text
      @max_reserved     = max_reserved.text
      @screenshot_urls  = screenshot_urls
      @description      = description.text
      @video_url        = video_url
      @bonus_id         = bonus_id
      @bonus_url        = bonus_url
      @website_url      = (YoyakutoptenScraper.make_absolute_url ("#{YoyakutoptenScraper::PC_PREFIX}/#{@app_id}"))
    end

    def update
      query = "#{YoyakutoptenScraper::HOST}/#{YoyakutoptenScraper::PC_PREFIX}/#{@app_id}"
      user_agents = YoyakutoptenScraper::USER_AGENTS[@os_type]
      request = Typhoeus::Request.new query,
	method: 'get',
	headers: {:"User-Agent" => user_agents},
	followlocation: true
      response = request.run
      self.parse (Nokogiri::HTML.parse response.body)
    end
  end
end
