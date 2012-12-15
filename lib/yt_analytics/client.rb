class YTAnalytics
  class Client
    include YTAnalytics::Logging
    # Previously this was a logger instance but we now do it globally

    def initialize *params
      if params.first.is_a?(Hash)
        hash_options = params.first
        @user = hash_options[:username]
        @pass = hash_options[:password]
        @dev_key = hash_options[:dev_key]
        @client_id = hash_options[:client_id] || "yt_analytics"
        @legacy_debug_flag = hash_options[:debug]
      elsif params.first
        puts "* warning: the method YTAnalytics::Client.new(user, passwd, dev_key) is deprecated, use YTAnalytics::Client.new(:username => 'user', :password => 'passwd', :dev_key => 'dev_key')"
        @user = params.shift
        @pass = params.shift
        @dev_key = params.shift
        @client_id = params.shift || "youtube_it"
        @legacy_debug_flag = params.shift
      end
    end

    def enable_http_debugging
      client.enable_http_debugging
    end

    def current_user
      client.get_current_user
    end

    def analytics(options = {})
      client.get_analytics(options)
    end

    def seven_day_totals(options = {})
      client.temporal_totals('7DayTotals',self.user_id, options)
    end

    def thirty_day_totals(options = {})
      client.temporal_totals('30DayTotals',self.user_id, options)
    end

    def day_totals(options = {})
      client.temporal_totals('day',self.user_id, options)
    end

    def month_totals(options = {})
      client.temporal_totals('month',self.user_id, options)
    end

    ### DEMOGRAPHICS METRICS
    def demographic_percentages(options = {})
      client.demographic_percentages(self.user_id, options)
    end

    ### WATCH TIME METRICS
    def day_watch_time(options = {})
      client.watch_time_metrics('day', self.user_id, options)
    end

    private

    def client
      @client ||= YTAnalytics::YTAuth::Authentication.new(:username => @user, :password => @pass, :dev_key => @dev_key)
    end

    def calculate_offset(page, per_page)
      page == 1 ? 1 : ((per_page * page) - per_page + 1)
    end

    def integer_or_default(value, default)
      value = value.to_i
      value > 0 ? value : default
    end
  end

  class OAuth2Client < YTAnalytics::Client
    def initialize(options)
      @client_id = options[:client_id]
      @client_secret = options[:client_secret]
      @client_access_token = options[:client_access_token]
      @client_refresh_token = options[:client_refresh_token]
      @client_token_expires_at = options[:client_token_expires_at]
      @dev_key = options[:dev_key]
      @legacy_debug_flag = options[:debug]
    end

    def oauth_client
      options = {:site => "https://accounts.google.com",
        :authorize_url => '/o/oauth2/auth',
        :token_url => '/o/oauth2/token'
       }
      options.merge(:connection_opts => @connection_opts) if @connection_opts
      @oauth_client ||= ::OAuth2::Client.new(@client_id, @client_secret, options)
    end

    def access_token
      @access_token ||= ::OAuth2::AccessToken.new(oauth_client, @client_access_token, :refresh_token => @client_refresh_token, :expires_at => @client_token_expires_at)
    end

    def refresh_access_token!
      new_access_token = access_token.refresh!
      require 'thread' unless Thread.respond_to?(:exclusive)
      Thread.exclusive do
        @access_token = new_access_token
        @client = nil
      end
      @access_token
    end
        
    def session_token_info
      response = Faraday.get("https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=#{@client_access_token}")
      {:code => response.status, :body => response.body }
    end

    def current_user
      profile = access_token.get("http://gdata.youtube.com/feeds/api/users/default")
      response_code = profile.status

      if response_code/10 == 20 # success
        Nokogiri::XML(profile.body).at("entry/author/name").text
      elsif response_code == 403 || response_code == 401 # auth failure
        raise YTAnalytics::YTAuth::AuthenticationError.new(profile.inspect, response_code)
      else
        raise YTAnalytics::YTAuth::UploadError.new(profile.inspect, response_code)
      end
    end

    def user_id
      profile ||= access_token.get("http://gdata.youtube.com/feeds/api/users/default?v=2&alt=json").parsed
      profile['entry']['author'][0]["yt$userId"]["$t"]
    end

    private

    def client
      @client ||= YTAnalytics::YTAuth::Authentication.new(:username => current_user, :access_token => access_token, :dev_key => @dev_key)
    end
  end
end
