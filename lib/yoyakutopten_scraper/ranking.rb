module YoyakutoptenScraper
  class Ranking
    TYPE = [:daily, :total, :new]
    attr_accessor :feed, :os_type, :results

    def initialize(feed:, os_type:, options: {})
      @feed = feed
      @os_type = os_type
    end

    def parse(html)
      apps = html.css '.rank_content'

      @results = apps.map do |app|
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
	  title:           title.text,
	  price:           (price.text == 'FREE' ? 0 : price.text),
	  detail_url:      detail_url,
	  banner_img_url:  banner_url,
	  app_id:          app_id,
	  release:         release.text,
	  bonus_id:        bonus_id,
	  bonus_url:       bonus_url,
	  os_type:         @os_type
	}
      end
    end

    def update
      query = "#{YoyakutoptenScraper::HOST}/pc/r/#{@os_type}/#{@feed}"
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