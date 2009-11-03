# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "uri"
require 'net/http'

module HudsonHelper

  def open_hudson_api( uri, auth_user, auth_password )

    http = create_http_connection(uri)
    request = create_http_request(uri, auth_user, auth_password)

    begin
      response = http.request(request)
    rescue => error
      raise HudsonApiException.new(error)
    end

    case response
    when Net::HTTPSuccess, Net::HTTPFound
      return response.body
    else
      raise HudsonApiException.new(response)
    end
  end

  def check_box_to_boolean(item)
    return false unless item
    return false if "0" == item
    return true
  end

  def create_http_connection(uri)

    param = URI.parse( URI.escape(uri) )

    if "https" == param.scheme then
      param.port = 443 if param.port == nil || param.port == ""
    end

    retval = Net::HTTP.new(param.host, param.port)

    if "https" == param.scheme then
      retval.use_ssl = true
      retval.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    return retval

  end

  def create_http_request(uri, auth_user, auth_password)
    
    param = URI.parse( URI.escape(uri) )

    getpath = param.path
    getpath += "?" + param.query if param.query != nil && param.query.length > 0

    retval = Net::HTTP::Get.new(getpath)
    retval.basic_auth(auth_user, auth_password) if auth_user != nil && auth_user.length > 0

    return retval

  end

end
