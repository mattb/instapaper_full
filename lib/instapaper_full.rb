require 'json'
require 'faraday/request/oauth'
require 'faraday/response/parse_json'

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
      
      Faraday.new(options) do |builder|
        builder.use Faraday::Request::OAuth, oauth_options
        builder.use Faraday::Request::UrlEncoded
        builder.use Faraday::Response::Logger 
        builder.adapter Faraday.default_adapter
        if authenticated?
          builder.use Faraday::Response::ParseJson
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
          verify_credentials.each { |k,v|
            @options[k.to_sym] = v if k != 'type'
          }
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
      return result.body
    end

    def verify_credentials
      call('account/verify_credentials')[0]
    end

    def bookmarks_list(options=nil)
      call('bookmarks/list', options)[2..-1] # slice off the 'meta' and 'user' from the front of the array
    end

    def bookmarks_update_read_progress(options=nil)
      call('bookmarks/update_read_progress', options)
    end

    def bookmarks_add(options=nil)
      call('bookmarks/add',options)
    end

    def bookmarks_delete(options=nil)
      call('bookmarks/delete', options)
    end

    def bookmarks_star(options=nil)
      call('bookmarks/star', options)
    end

    def bookmarks_unstar(options=nil)
      call('bookmarks/unstar', options)
    end

    def bookmarks_archive(options=nil)
      call('bookmarks/archive', options)
    end

    def bookmarks_unarchive(options=nil)
      call('bookmarks/unarchive', options)
    end

    def bookmarks_move(options=nil)
      call('bookmarks/move', options)
    end

    def bookmarks_get_text(options=nil)
      call('bookmarks/get_text', options)
    end

    def folders_list
      call('folders/list')
    end

    def folders_add(options=nil)
      call('folders/add', options)
    end

    def folders_delete(options=nil)
      call('folders/delete', options)
    end

    def folders_set_order(options=nil)
      call('folders/set_order', options)
    end
  end
end
