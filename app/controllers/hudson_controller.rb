# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "rexml/document"
require 'cgi'
require 'hudson_exceptions'
require 'date'

RAILS_DEFAULT_LOGGER.info 'Starting Hudson plugin for RedMine'

class HudsonController < ApplicationController
  unloadable
  layout 'base'

  before_filter :find_project
  before_filter :find_settings
  before_filter :authorize
  before_filter :clear_flash

  include HudsonHelper
  include RexmlHelper

  def index
    @jobs = []
    raise HudsonNoSettingsException if @settings.is_new?
    # job/build, view, primaryView は省く
    api_url = "#{@settings.url}api/xml?depth=1" + 
              "&xpath=/hudson" +
              "&exclude=/hudson/view" +
              "&exclude=/hudson/primaryView" +
              "&exclude=/hudson/job/build" +
              "&exclude=/hudson/job/lastBuild" +
              "&exclude=/hudson/job/lastCompletedBuild" +
              "&exclude=/hudson/job/lastStableBuild" +
              "&exclude=/hudson/job/lastSuccessfulBuild"
    content = open_hudson(api_url, @settings.auth_user, @settings.auth_password)

    doc = REXML::Document.new content
    doc.elements.each("hudson/job") do |element|
      @jobs << make_job(element) if is_target?(get_element_value(element, "name"))
    end

  rescue HudsonNoSettingsException
    flash.now[:error] = l(:notice_err_no_settings, url_for(:controller => 'hudson_settings', :action => 'edit', :id => @project))
  rescue HudsonHttpError => error
    flash.now[:error] = l(:notice_err_http_error, error.message)
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT 
    flash.now[:error] = l(:notice_err_cant_connect)
  rescue URI::InvalidURIError
    flash.now[:error] = l(:notice_err_invalid_url)
  end

  def build
    raise HudsonNoSettingsException if @settings.is_new?
    raise HudsonNoJobException if params[:name] == nil

    build_url = "#{@settings.url}job/#{params[:name]}/build"

    content = open_hudson(build_url, @settings.auth_user, @settings.auth_password)

  rescue HudsonHttpError => error
    render :text => "#{l(:notice_err_http_error, error.message)}"
  rescue HudsonNoSettingsException
    render :text => "#{l(:notice_err_build_failed, :notice_err_no_settings)}"
  rescue HudsonNoJobException
    render :text => "#{l(:notice_err_build_failed_no_job, params[:name])}"
  rescue URI::InvalidURIError
    render :text => l(:notice_err_invalid_url)
  else
    render :text => "#{params[:name]} #{l(:build_accepted)}"
  end

  def history
    raise HudsonNoSettingsException if @settings.is_new?
    raise HudsonNoJobException if params[:name] == nil
    raise HudsonNoJobException unless is_target?(params[:name]) # ちょっと強引だけど、見えない設定のジョブはないものとみなす

    @name = params[:name]
    api_uri = "#{@settings.url}job/#{params[:name]}/rssAll"
    content = open_hudson(api_uri, @settings.auth_user, @settings.auth_password)
    doc = REXML::Document.new content
    @builds = []
    doc.elements.each("//entry") do |entry|
      params = get_element_value(entry, "title").scan(/(.*)#(.*)\s\((.*)\)/)[0]
      link = "#{entry.elements['link'].attributes['href']}"
      published = Time.xmlschema(get_element_value(entry, "published"))
      @builds << {:name => params[0], :number=>params[1], :result=>params[2], :url=>link, :published => published}
    end

  rescue HudsonHttpError => error
    render :text => "#{l(:notice_err_http_error, error.message)}"
  rescue HudsonNoSettingsException
    render :text => "#{l(:notice_err_no_settings, url_for(:controller => 'hudson_settings', :action => 'edit', :id => @project))}"
  rescue HudsonNoJobException
    render :text => "#{l(:notice_err_no_job, params[:name])}"
  rescue URI::InvalidURIError
    render :text => l(:notice_err_invalid_url)
  else
    render :partial => 'history'
  end

private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_settings
    @settings = HudsonSettings.load(@project)
  end

  def clear_flash
    flash.clear
  end

  def is_target?(job)
    return @settings.job_include?(job)
  end

  def make_job( element )
    retval = {}
    retval[:name] = get_element_value(element, "name")
    retval[:description] = get_element_value(element, "description")
    retval[:url] = get_element_value(element, "url")
    retval[:state] = get_element_value(element, "color")

    retval[:healthReport] = []
    element.elements.each("healthReport") do |hReport|
      report = {}
      report[:description] = get_element_value(hReport, "description")
      report[:score] = get_element_value(hReport, "score")
      report[:url] = get_health_report_url(retval[:name], report[:description])
      retval[:healthReport] << report
    end

    retval[:latestBuild] = make_latest_build( retval[:name] )

    return retval
  end

  def get_health_report_url(name, description)
    if description.index(l(:keyword_build_health_report)) != nil
      return URI.escape("#{@settings.url}job/#{name}/lastBuild/")
    end
    if description.index(l(:keyword_test_health_report)) != nil
      return URI.escape("#{@settings.url}job/#{name}/lastBuild/testReport/")
    end
    return ""
  end

  def make_latest_build( name )

    retval = {}
    retval[:number] = ""
    retval[:result] = ""
    retval[:url] = ""
    retval[:timestamp] = ""
    retval[:error] = "" # ビルド情報を取得する際に発生したエラー

    api_url = "#{@settings.url}job/#{name}/lastBuild/api/xml"

    begin
      # Open the feed and parse it
      content = open_hudson(api_url, @settings.auth_user, @settings.auth_password)
      doc = REXML::Document.new content
    rescue HudsonHttpError => error
      # 404 って、URLを間違えた場合にも発生しちゃうんだけど…
      retval[:error] = l(:notice_err_http_error, error.message) if error.code != "404"
      return retval
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT 
      retval[:error] = l(:notice_err_cant_connect)
      return retval
    rescue URI::InvalidURIError
      retval[:error] = l(:notice_err_invalid_url)
      return retval
    end

    if doc.root != nil
      retval[:number] = get_element_value(doc.root, "number")
      retval[:result] = get_element_value(doc.root, "result")
      retval[:url] = get_element_value(doc.root, "url")
      retval[:building] = get_element_value(doc.root, "building")
      retval[:timestamp] = Time.at( get_element_value(doc.root, "timestamp").to_f / 1000 )
    end

    return retval

  end

end
