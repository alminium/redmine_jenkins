# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "uri"
require 'net/http'

module HudsonHelper

  def open_hudson_api( uri, auth_user, auth_password )

    begin
      http = create_http_connection(uri)
      request = create_http_request(uri, auth_user, auth_password)
    rescue => error
      raise HudsonApiException.new(error)
    end

    begin
      response = http.request(request)
    rescue Timeout::Error, StandardError => error
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
    return false if "false" == item
    return true
  end

  def is_today?(value)
    return false unless value
    
    value_time = Time.parse(value.to_s, 0) rescue nil
    return false unless value_time
 
    today = Time.now
    return today.strftime("%Y/%m/%d") == value_time.strftime("%Y/%m/%d")
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
  
  def generate_atom_content(job)
    tag = ""
    tag = job.latest_build.error if "" != job.latest_build.error
    if "" == job.latest_build.error
    
      icon = "#{job.state}.gif"
      icon = "grey.gif" if job.state == "disabled"

      tag << image_tag("#{job.settings.url}images/24x24/#{icon}")
      tag << " "
    
      if "" != job.latest_build.number
        tag << link_to("##{job.latest_build.number}",job.latest_build.url_for(:user))
        tag << " "
        tag << content_tag("span", job.latest_build.result, 
               :class => "result #{job.latest_build.result.downcase}") if true != job.latest_build.building? && "" != job.latest_build.result
        tag " " 
        tag << content_tag("span", l(:notice_building), :class => "result") if job.latest_build.building?
        tag << " "
        tag << content_tag("span", job.latest_build.finished_at.localtime.strftime("%Y/%m/%d %H:%M:%S"))
      end
      tag << l(:notice_no_builds) if "" == job.latest_build.number
    end    
  
    tag << "<ul class=\"job-health-reports\">"
    job.health_reports.each do |report|
      tag << "<li>#{link_to(report.description, report.url)} #{report.score}" if report.url != ""
      tag << "<li>#{report.description} #{report.score}%" if report.url == ""
    end
    tag << "</ul>"
    return tag  
  end

end
