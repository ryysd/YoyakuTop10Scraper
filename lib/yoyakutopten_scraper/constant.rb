module YoyakutoptenScraper
  HOST = 'https://yoyaku-top10.jp'.freeze
  PC_PREFIX = 'u/a'
  MOBILE_PREFIX = 'sp/r'
  ANDROID_USER_AGENT = 'Mozilla/5.0 (Linux; U; Android 1.6; ja-jp; IS01 Build/S3082) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1'
  IOS_USER_AGENT = 'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25'
  USER_AGENTS = {ios: IOS_USER_AGENT, android: ANDROID_USER_AGENT}
end
