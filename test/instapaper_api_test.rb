require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class InstapaperAPITest < Test::Unit::TestCase

  include AssetHelpers

  def stub_successful_authentication
    stub_request(:post, "https://www.instapaper.com/api/1.1/oauth/access_token").to_return(
      http_response('access_token_success')
    )
  end

  def stub_failed_authentication
    stub_request(:post, "https://www.instapaper.com/api/1.1/oauth/access_token").to_return(
      http_response('access_token_failure')
    )
  end

  def stub_successful_verify_credentials
    stub_request(:post, "https://www.instapaper.com/api/1.1/account/verify_credentials").to_return(
      http_response('verify_credentials_success')
    )
  end

  def stub_successful_bookmarks_list
    stub_request(:post, "https://www.instapaper.com/api/1.1/bookmarks/list").to_return(
      http_response('bookmarks_list_success')
    )
  end

  def stub_failed_bookmarks_add
    stub_request(:post, "https://www.instapaper.com/api/1.1/bookmarks/add").to_return(
      http_response('bookmarks_add_failure')
    )
  end

  def stub_successful_bookmarks_get_text
    stub_request(:post, "https://www.instapaper.com/api/1.1/bookmarks/get_text").
      with(:body => {"bookmark_id"=>"1"}).
      to_return(http_response('bookmarks_get_text_success'))
  end

  def stub_failed_bookmarks_get_text
    stub_request(:post, "https://www.instapaper.com/api/1.1/bookmarks/get_text").
      with(:body => {"bookmark_id"=>"2"}).
      to_return(http_response('bookmarks_get_text_failure'))
  end

  def authenticated_client
    InstapaperFull::API.new(:consumer_key => "key",
                            :consumer_secret => "secret",
                            :oauth_token => "token",
                            :oauth_token_secret => "tokensecret")
  end

  def test_successful_authentication
    stub_successful_authentication
    stub_successful_verify_credentials

    ip = InstapaperFull::API.new(:consumer_key => "test", :consumer_secret => "")
    assert_equal true, ip.authenticate("tom@testing.com", "test")
    assert_equal "thisisatoken", ip.options[:oauth_token]
    assert_equal "thisisasecret", ip.options[:oauth_token_secret]
    assert_equal 140230, ip.options[:user_id]
    assert_equal "tom@tomtaylor.co.uk", ip.options[:username]
  end

  def test_failed_authentication
    stub_failed_authentication

    ip = InstapaperFull::API.new(:consumer_key => "test", :consumer_secret => "")
    assert_equal false, ip.authenticate("tom@testing.com", "test")
  end

  def test_successful_bookmarks_list
    stub_successful_bookmarks_list
    list = authenticated_client.bookmarks_list
    assert_equal 27, list.length # 25 + 1 user element + 1 meta element
  end

  def test_failed_bookmarks_add
    stub_failed_bookmarks_add
    assert_raise(InstapaperFull::API::Error) { authenticated_client.bookmarks_add }

    begin
      authenticated_client.bookmarks_add
    rescue InstapaperFull::API::Error => e
      assert_equal 1240, e.code
      assert_equal "Invalid URL specified", e.message
    end
  end

  def test_successful_bookmarks_get_text
    stub_successful_bookmarks_get_text

    html = authenticated_client.bookmarks_get_text(:bookmark_id => 1)
    assert html.kind_of?(String)
    assert_equal 22788, html.length
  end

  def test_failed_bookmarks_get_text
    stub_failed_bookmarks_get_text

    assert_raise(InstapaperFull::API::Error) do
      authenticated_client.bookmarks_get_text(:bookmark_id => 2)
    end

    begin
      authenticated_client.bookmarks_get_text(:bookmark_id => 2)
    rescue InstapaperFull::API::Error => e
      assert_equal 1241, e.code
      assert_equal "Invalid or missing bookmark_id", e.message
    end
  end
end
