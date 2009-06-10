# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

# Jobがない場合の例外
class HudsonNoJobException < Exception
end

# 設定がない場合の例外
class HudsonNoSettingsException < Exception
end

class HudsonHttpError < Exception
  attr_reader :message, :code

  def initialize( object )
    case object
    when Net::HTTPResponse
      @message = object.message
      @code = object.code
    else
      @message = "#{object.class.name} - #{object.message}"
      @code = ""
    end
  end
  def message
    return @message
  end
  def code
    return @code
  end
end