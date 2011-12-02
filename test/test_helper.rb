require 'test/unit'

unless $LOAD_PATH.include? 'lib'
  $LOAD_PATH.unshift(File.dirname(__FILE__))
  $LOAD_PATH.unshift(File.join($LOAD_PATH.first, '..', 'lib'))
end

require 'instapaper_full'
require 'asset_helpers'
require 'webmock/test_unit'

WebMock.disable_net_connect!
