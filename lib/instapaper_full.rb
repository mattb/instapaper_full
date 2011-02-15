require 'faraday/oauth'

module InstapaperFull
  class API
    attr_accessor :options
    def initialize(options={})
      @options = options
    end

    def connection
      options = {
        :proxy => @options[:proxy],
        :ssl => {:verify => false},
        :url => "https://www.instapaper.com/api/1/"
      }
      oauth_options = { 
        :consumer_key => @options[:consumer_key],
        :consumer_secret => @options[:consumer_secret]
      }
      if authenticated?
        oauth_options[:token] = @options[:oauth_token]
        oauth_options[:token_secret] = @options[:oauth_token_secret]
      end
      
      Faraday::Connection.new(options) do |builder|
        builder.use Faraday::Request::OAuth, oauth_options
        builder.adapter Faraday.default_adapter
        if authenticated?
          builder.response :yajl
        end
      end
    end

    def authenticated?
      @options.has_key? :oauth_token and @options.has_key? :oauth_token_secret
    end

    def authenticate(username,password)
      @options.delete(:oauth_token)
      @options.delete(:oauth_token_secret)
      result = connection.post 'oauth/access_token' do |r| 
        r.body = { :x_auth_username => username, :x_auth_password => password, :x_auth_mode => "client_auth" }
      end
      if result.status == 200
        data = CGI.parse(result.body)
        if data.has_key? 'oauth_token_secret'
          @options[:oauth_token] = data['oauth_token'][0]
          @options[:oauth_token_secret] = data['oauth_token_secret'][0]
        end
        return true
      else
        return false
      end
    end

    def call(method, body = nil)
      result = connection.post(method) do |r|
        if body
          r.body = body
        end
      end
      if result.status == 200
        return result.body[0]
      end
      return nil
    end

    def verify_credentials
      call('account/verify_credentials')
    end

    def bookmarks_list(options=nil)
      call('bookmarks/list', options)
    end
  end
end
