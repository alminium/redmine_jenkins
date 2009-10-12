# $Id$

# Jobがない場合の例外
class HudsonNoJobException < Exception
end

# 設定がない場合の例外
class HudsonNoSettingsException < Exception
end

class HudsonApiException < Exception
  attr_reader :message, :code, :inner_exception

  include ApplicationHelper
  include ActionView::Helpers::TextHelper
  
  def initialize( object )
    @code = ""
    @message = ""
    @inner_exception = object

    case object
    when Net::HTTPResponse
      @code = object.code
      @message = l(:notice_err_http_error, object.code)
    when Net::HTTPBadResponse
      @message = l(:notice_err_response_invalid, "Net::HTTPBadResponse")
    when SocketError
      @message = l(:notice_err_cant_connect, object.message)
    when Errno::ECONNREFUSED, Errno::ETIMEDOUT
      @message = l(:notice_err_cant_connect, object.message)
    when URI::InvalidURIError
      @message = l(:notice_err_invalid_url)
    when REXML::ParseException
      @message = l(:notice_err_response_invalid, truncate(object.to_s, 50))
    else
      @message = l(:notice_err_unknown, object.message)
    end
  end
end