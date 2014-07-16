require 'errors'
require 'json'
require 'faraday'
require 'faraday_middleware'

module InstapaperFull
  class API
    attr_accessor :options
    def initialize(options = {})
      @options = options
    end

    def connection(options = {})
      options.merge!({
        :proxy => @options[:proxy],
        :url => "https://www.instapaper.com/api/1.1/"
      })

      oauth_params = {
        :consumer_key => @options[:consumer_key],
        :consumer_secret => @options[:consumer_secret]
      }

      if authenticated?
        oauth_params[:token] = @options[:oauth_token]
        oauth_params[:token_secret] = @options[:oauth_token_secret]
      end

      Faraday.new(options) do |builder|
        builder.use Faraday::Request::Multipart
        builder.use Faraday::Request::OAuth, oauth_params
        builder.use Faraday::Request::UrlEncoded
        builder.adapter Faraday.default_adapter
      end
    end

    def authenticated?
      @options.has_key? :oauth_token and @options.has_key? :oauth_token_secret
    end

    def authenticate(username, password)
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

    def call(method, params = {}, connection_options = {})
      result = connection(connection_options).post(method) do |r|
        r.body = params unless params.empty?
      end

      if result.headers['content-type'] == 'application/json'
        JSON.parse(result.body).tap do |d|
          if error = d.find { |e| e['type'] == 'error' }
            raise InstapaperFull::API::Error.new(error['error_code'], error['message'])
          end
        end
      else
        raise InstapaperFull::API::Error.new(-1, result.body) if result.status != 200
        result.body
      end
    end

    def verify_credentials
      call('account/verify_credentials')[0]
    end

    def bookmarks_list(params = {})
      call('bookmarks/list', params)
    end

    def bookmarks_update_read_progress(params = {})
      call('bookmarks/update_read_progress', params)
    end

    def bookmarks_add(params = {})
      call('bookmarks/add', params)
    end

    def bookmarks_delete(params = {})
      call('bookmarks/delete', params)
    end

    def bookmarks_star(params = {})
      call('bookmarks/star', params)
    end

    def bookmarks_unstar(params = {})
      call('bookmarks/unstar', params)
    end

    def bookmarks_archive(params = {})
      call('bookmarks/archive', params)
    end

    def bookmarks_unarchive(params = {})
      call('bookmarks/unarchive', params)
    end

    def bookmarks_move(params = {})
      call('bookmarks/move', params)
    end

    def bookmarks_get_text(params = {})
      call('bookmarks/get_text', params)
    end

    def folders_list
      call('folders/list')
    end

    def folders_add(params = {})
      call('folders/add', params)
    end

    def folders_delete(params = {})
      call('folders/delete', params)
    end

    def folders_set_order(params = {})
      call('folders/set_order', params)
    end
  end
end
