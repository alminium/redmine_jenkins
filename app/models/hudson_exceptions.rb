# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

# Jobがない場合の例外
class HudsonNoJobException < Exception
end

# 設定がない場合の例外
class HudsonNoSettingsException < Exception
end

class HudsonHttpException < Exception
  attr_reader :message, :code

  include GLoc
  
  def initialize( object )
    @code = ""
    @message = ""

    case object
    when Net::HTTPResponse
      @code = object.code
      @message = l(:notice_err_http_error, object.code)
    when Errno::ECONNREFUSED
      @message = l(:notice_err_cant_connect)
    when Errno::ETIMEDOUT
      @message = l(:notice_err_cant_connect)
    when URI::InvalidURIError
      @message = l(:notice_err_invalid_url)
    end
  end
end