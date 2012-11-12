class YTAnalytics
  module YTAuth

    class UploadError < YTAnalytics::Error; end

    class AuthenticationError < YTAnalytics::Error; end

    class Authentication
      include YTAnalytics::Logging

      def initialize *params
        if params.first.is_a?(Hash)
          hash_options = params.first
          @user                          = hash_options[:username]
          @password                      = hash_options[:password]
          @dev_key                       = hash_options[:dev_key]
          @access_token                  = hash_options[:access_token]
          @authsub_token                 = hash_options[:authsub_token]
          @client_id                     = hash_options[:client_id] || "youtube_it"
          @config_token                  = hash_options[:config_token]
        else
          puts "* warning: the method YTAnalytics::Auth::Authentication.new(username, password, dev_key) is deprecated, use YouTubeIt::Upload::VideoUpload.new(:username => 'user', :password => 'passwd', :dev_key => 'dev_key')"
          @user                          = params.shift
          @password                      = params.shift
          @dev_key                       = params.shift
          @access_token                  = params.shift
          @authsub_token                 = params.shift
          @client_id                     = params.shift || "youtube_it"
          @config_token                  = params.shift
        end
      end


      def enable_http_debugging
        @http_debugging = true
      end

     

      def get_current_user
        current_user_url = "/feeds/api/users/default"
        response         = yt_session.get(current_user_url)

        return Nokogiri::XML(response.body).at("entry/author/name").text
      end

      def get_analytics(opts)
        # max_results = opts[:per_page] || 50
        # start_index = ((opts[:page] || 1) -1) * max_results +1
        get_url     = "/youtube/analytics/v1/reports?"
        get_url     << opts.collect { |k,p| [k,p].join '=' }.join('&')
        response    = yt_session('https://www.googleapis.com').get(get_url)

        return YTAnalytics::Parser::AnalyticsParser.new(response.body).parse
      end

      def temporal_totals(dimension, user_id, options)
        #dimension is either day, 7DayTotals, 30DayTotals, or month
        
        opts = {'ids' => "channel==#{user_id}", 'dimensions' => dimension}
        opts['start-date'] = (options['start-date'].strftime("%Y-%m-%d") if options['start-date']) || 1.day.ago.strftime("%Y-%m-%d")
        opts['end-date'] = (options['end-date'].strftime("%Y-%m-%d") if options['end-date']) || 1.day.ago.strftime("%Y-%m-%d")
        if options['metrics'].class == Array
          opts['metrics'] = options['metrics'].join(",")
        elsif options['metrics'].class == String
          opts['metrics'] = options['metrics'].delete(" ")
        else
          opts['metrics'] = 'views,comments,favoritesAdded,favoritesRemoved,likes,dislikes,shares,subscribersGained,subscribersLost,uniques'
        end
        
        get_url     = "/youtube/analytics/v1/reports?"
        get_url     << opts.collect { |k,p| [k,p].join '=' }.join('&')
        response    = yt_session('https://www.googleapis.com').get(get_url)
        content = JSON.parse(response.body)
        return YTAnalytics::Parser::TemporalParser.new(content).parse
      end


      def demographic_percentages(user_id, options)        
        opts = {'ids' => "channel==#{user_id}", 'dimensions' => 'ageGroup,gender'}
        opts['start-date'] = (options['start-date'].strftime("%Y-%m-%d") if options['start-date']) || 2.day.ago.strftime("%Y-%m-%d")
        opts['end-date'] = (options['end-date'].strftime("%Y-%m-%d") if options['end-date']) || 2.day.ago.strftime("%Y-%m-%d")
        if options['metrics'].class == Array
          opts['metrics'] = options['metrics'].join(",")
        elsif options['metrics'].class == String
          opts['metrics'] = options['metrics'].delete(" ")
        else
          opts['metrics'] = 'viewerPercentage'
        end
        
        get_url     = "/youtube/analytics/v1/reports?"
        get_url     << opts.collect { |k,p| [k,p].join '=' }.join('&')
        response    = yt_session('https://www.googleapis.com').get(get_url)
        content = JSON.parse(response.body)
        return YTAnalytics::Parser::DemographicParser.new(content).parse
      end

      private


      def base_url
        "http://gdata.youtube.com"
      end

      def authorization_headers
        header = {"X-GData-Client"  => "#{@client_id}"}
        header.merge!("X-GData-Key" => "key=#{@dev_key}") if @dev_key
        if @authsub_token
          header.merge!("Authorization"  => "AuthSub token=#{@authsub_token}")
        elsif @access_token.nil? && @authsub_token.nil? && @user
          header.merge!("Authorization"  => "GoogleLogin auth=#{auth_token}")
        end
        header
      end

      def parse_upload_error_from(string)
        xml = Nokogiri::XML(string).at('errors')
        if xml
          xml.css("error").inject('') do |all_faults, error|
            if error.at("internalReason")
              msg_error = error.at("internalReason").text
            elsif error.at("location")
              msg_error = error.at("location").text[/media:group\/media:(.*)\/text\(\)/,1]
            else
              msg_error = "Unspecified error"
            end
            code = error.at("code").text if error.at("code")
            all_faults + sprintf("%s: %s\n", msg_error, code)
          end
        else
          string[/<TITLE>(.+)<\/TITLE>/, 1] || string
        end
      end

      # def raise_on_faulty_response(response)
      #   response_code = response.code.to_i
      #   msg = parse_upload_error_from(response.body.gsub(/\n/, ''))

      #   if response_code == 403 || response_code == 401
      #   #if response_code / 10 == 40
      #     raise AuthenticationError.new(msg, response_code)
      #   elsif response_code / 10 != 20 # Response in 20x means success
      #     raise UploadError.new(msg, response_code)
      #   end
      # end

      def auth_token
        @auth_token ||= begin
          http  = Faraday.new("https://www.google.com", :ssl => {:verify => false})
          body = "Email=#{YTAnalytics.esc @user}&Passwd=#{YTAnalytics.esc @password}&service=youtube&source=#{YTAnalytics.esc @client_id}"
          response = http.post("/youtube/accounts/ClientLogin", body, "Content-Type" => "application/x-www-form-urlencoded")
          raise ::AuthenticationError.new(response.body[/Error=(.+)/,1], response.status.to_i) if response.status.to_i != 200
          @auth_token = response.body[/Auth=(.+)/, 1]
        end
      end

      def yt_session(url = nil)
        Faraday.new(:url => (url ? url : base_url), :ssl => {:verify => false}) do |builder|
          if @access_token
            if @config_token
              builder.use Faraday::Request::OAuth, @config_token
            else
              builder.use Faraday::Request::OAuth2, @access_token
            end
          end
          builder.use Faraday::Request::AuthHeader, authorization_headers
          builder.use Faraday::Response::YTAnalytics
          builder.adapter YTAnalytics.adapter

        end
      end
    end
  end
end
