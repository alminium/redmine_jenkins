# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "rexml/document"
require 'open-uri'

RAILS_DEFAULT_LOGGER.info 'Starting Hudson plugin for RedMine'

class HudsonController < ApplicationController
  unloadable
  layout 'base'

  before_filter :find_project
  before_filter :find_settings
  before_filter :authorize

  def index
    if @settings == nil
      flash.now[:error] = l(:notice_no_settings)
      return
    end

    api_url = "#{@settings[:url]}/api/xml?depth=1"

    begin
      # Open the feed and parse it
      content = open(api_url)
      doc = REXML::Document.new content
      @jobs = []
      doc.elements.each("hudson/job") do |element|
        @jobs << make_job(element) if is_target?(get_element_value(element, "name"))
      end
    rescue OpenURI::HTTPError => error
      flash.now[:error] = l(:notice_http_error, error.message)
      return
    rescue Errno::ECONNREFUSED
      flash.now[:error] = l(:notice_connect_refused)
      return
    end

  end

  def build
    raise 'no job' if params[:name] == nil

    build_url = "#{@settings[:url]}/job/#{params[:name]}/build"

    content = ""
    open(build_url) do |s| content = s.read end
    p "info --> #{content}"

  rescue
      render :text => "#{params[:name]} #{l(:build_failed)}"
    else
      render :text => "#{params[:name]} #{l(:build_accepted)}"
  end

private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_settings
    return if @project == nil
    return if Setting.plugin_redmine_hudson[@project.identifier] == nil

    @settings = {}
    @settings[:url] = Setting.plugin_redmine_hudson[@project.identifier][:url]
    @settings[:job_filter] = Setting.plugin_redmine_hudson[@project.identifier][:job_filter]
  end

  def is_target?(job)
    return true if @settings[:job_filter] == nil || @settings[:job_filter] == ""
    return true if @settings[:job_filter].split(";").include?(job)
    return false
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
      retval[:healthReport] << report
    end

    retval[:latestBuild] = make_latest_build( retval[:name] )

    return retval
  end

  def make_latest_build( name )

    retval = {}
    retval[:number] = ""
    retval[:result] = ""
    retval[:url] = ""
    retval[:timestamp] = ""

    api_url = "#{@settings[:url]}/job/#{name}/lastBuild/api/xml?"

    begin
      # Open the feed and parse it
      content = open(api_url)
      doc = REXML::Document.new content
    rescue OpenURI::HTTPError => error
      # TODO:ここどうしよう？
      return retval
    rescue Errno::ECONNREFUSED
      # TODO:ここどうしよう？
      return retval
    end

    if doc.root != nil
      retval[:number] = get_element_value(doc.root, "number")
      retval[:result] = get_element_value(doc.root, "result")
      retval[:url] = get_element_value(doc.root, "url")
      retval[:timestamp] = Time.at( get_element_value(doc.root, "timestamp").to_f / 1000 )
    end

    return retval

  end

  def get_element_value(element, name)
    return "" if element == nil
    return "" if element.get_text(name) == nil
    return "" if element.get_text(name).value == nil
    return element.get_text(name).value
  end

end
