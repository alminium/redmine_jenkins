# $Id$

require 'net/http'
require File.dirname(__FILE__) + '/../test_helper'
require 'hudson_exceptions'

class HudsonApiExceptionTest < ActiveSupport::TestCase
  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  def test_net_http_response_error
    error = Net::HTTPInternalServerError.new(Net::HTTP.version_1_2, '500', 'NG')
    target = HudsonApiException.new(error)

    assert_equal l(:notice_err_http_error, error.code), target.message
    assert_equal error, target.inner_exception
  end

  def test_net_http_bad_response_error
    error = Net::HTTPBadResponse.new
    target = HudsonApiException.new(error)

    assert_equal l(:notice_err_response_invalid, "Net::HTTPBadResponse"), target.message
    assert_equal error, target.inner_exception
  end

  def test_socket_error
    error = SocketError.new
    target = HudsonApiException.new(error)

    assert_equal l(:notice_err_cant_connect, error.message), target.message
    assert_equal error, target.inner_exception
  end

  def test_econnrefused_error
    error = Errno::ECONNREFUSED.new
    target = HudsonApiException.new(error)

    assert_equal l(:notice_err_cant_connect, error.message), target.message
    assert_equal error, target.inner_exception
  end

  def test_etimedout_error
    error = Errno::ETIMEDOUT.new
    target = HudsonApiException.new(error)

    assert_equal l(:notice_err_cant_connect, error.message), target.message
    assert_equal error, target.inner_exception
  end

  def test_uri_invalid_uri_error
    error = URI::InvalidURIError.new
    target = HudsonApiException.new(error)

    assert_equal l(:notice_err_invalid_url), target.message
    assert_equal error, target.inner_exception
  end

  def test_rexml_parse_error

    target = nil
    error = nil
    begin
      doc = REXML::Document.new "<sample>error sample</error_sample>"
    rescue REXML::ParseException => e
      error = e
      target = HudsonApiException.new(error)
    end

    assert_equal l(:notice_err_response_invalid, truncate(error.to_s, 50)), target.message
    assert_equal error, target.inner_exception
  end

  def test_unknown_error
    error = Exception.new("test")
    target = HudsonApiException.new(error)

    assert_equal l(:notice_err_unknown, error.message), target.message
    assert_equal error, target.inner_exception
    
  end

end
