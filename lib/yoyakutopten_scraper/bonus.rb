module YoyakutoptenScraper
  class Bonus
    attr_reader :img_url, :description

    def initialize(bonus_id:, os_type:)
      @bonus_id = bonus_id
      @os_type = os_type
    end

    def parse(html)
      img = ((html.css '.app_detail_bonus_imgArea').first.css 'img').first
      description = (html.css '.app_description').first

      detail = (html.css '.reserv_detail').first
      reserved_num = (detail.css '.reserv_detail_num').first
      current_reserved = (reserved_num.css 'li')[1]
      max_reserved     = (reserved_num.css 'li')[2]

      @img_url          = (img.get_attribute 'src')
      @description      = description.text
      @current_reserved = current_reserved.text
      @max_reserved     = max_reserved.text
    end

    def update
      query = "#{YoyakutoptenScraper::HOST}/#{YoyakutoptenScraper::MOBILE_PREFIX}/#{@bonus_id}/bonus"
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
