# $Id$

require File.dirname(__FILE__) + '/../test_helper'
require 'hudson_exceptions'

class HudsonHelperTest < Test::Unit::TestCase

  include HudsonHelper

  def test_create_http_connection

    url = "http://hogehoge.test/"
    target = create_http_connection(url)

    assert_equal "hogehoge.test", target.address
    assert_equal 80, target.port

  end

  def test_create_http_connection_port_9090

    url = "http://hogehoge.test:9090/"
    target = create_http_connection(url)

    assert_equal "hogehoge.test", target.address
    assert_equal 9090, target.port

  end

  def test_create_http_connection_use_https

    url = "https://hogehoge.test/"
    target = create_http_connection(url)

    assert_equal "hogehoge.test", target.address
    assert_equal 443, target.port

  end

  def test_create_http_connection_use_https_9090

    url = "https://hogehoge.test:9090/"
    target = create_http_connection(url)

    assert_equal "hogehoge.test", target.address
    assert_equal 9090, target.port

  end

  def test_open_hudson_should_raise_hudson_api_exception

    Net::HTTP.any_instance.stubs(:request).raises(Net::HTTPBadResponse)

    begin
      open_hudson_api("http://hogehoge.test/", "", "")
    rescue Exception => error
      assert error.is_a?(HudsonApiException)
      assert error.inner_exception.is_a?(Net::HTTPBadResponse)
    end

  end

  def test_check_box_to_boolean_should_return_true
    item = "true"
    assert_equal true, check_box_to_boolean(item)

    item = ""
    assert_equal true, check_box_to_boolean(item)
  end

  def test_check_box_to_boolean_should_return_false
    item = nil
    assert_equal false, check_box_to_boolean(item)

    item = "0"
    assert_equal false, check_box_to_boolean(item)
  end

end
