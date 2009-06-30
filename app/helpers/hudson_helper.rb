# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "uri"
require 'net/http'

module HudsonHelper

  def open_hudson( uri, auth_user, auth_password )
    param = URI.parse( URI.escape(uri) )

    getpath = param.path
    getpath += "?" + param.query if param.query != nil && param.query.length > 0

    request = Net::HTTP::Get.new(getpath)
    request.basic_auth(auth_user, auth_password) if (auth_user != nil && auth_user.length > 0)

    if "https" == param.scheme then
      param.port = 443 if param.port == nil || param.port = ""
    end

    http = Net::HTTP.new(param.host, param.port)
    if "https" == param.scheme then
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    begin
      response = http.request(request)
    rescue Net::HTTPBadResponse => error
      raise HudsonHttpException.new(error)
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT => error
      raise HudsonHttpException.new(error)
    rescue URI::InvalidURIError => error
      raise HudsonHttpException.new(error)
    end

    case response
    when Net::HTTPSuccess, Net::HTTPFound
      return response.body
    else
      raise HudsonHttpException.new(response)
    end
  end

  def parse_rss_build(entry)
    params = get_element_value(entry, "title").scan(/(.*)#(.*)\s\((.*)\)/)[0]
    retval = {}
    retval[:name] = params[0].strip
    retval[:number] = params[1]
    retval[:result] = params[2]
    retval[:url] = "#{entry.elements['link'].attributes['href']}"
    retval[:published] = Time.xmlschema(get_element_value(entry, "published")).localtime
    retval[:building] = false
    return retval
  end

  def parse_changeset(element)
    retval = {}
    retval[:kind] = get_element_value(element, "kind")
    retval[:revisions] = []
    element.children.each {|child|
      if "revision" == child.name
        revision = {}
        revision[:module] = get_element_value(child, "module")
        revision[:revision] = get_element_value(child, "revision")
        retval[:revisions] << revision
      end
    }
    return retval
  end

  def check_box_to_boolean(item)
    return item if item
    return false unless item
  end

end
