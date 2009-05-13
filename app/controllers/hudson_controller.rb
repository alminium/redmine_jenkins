# To change this template, choose Tools | Templates
# and open the template in the editor.

require "rexml/document"
require 'open-uri'

RAILS_DEFAULT_LOGGER.info 'Starting Hudson plugin for RedMine'

class HudsonController < ApplicationController
  unloadable
  layout 'base'

  before_filter :find_project
  before_filter :authorize

  def index
    api_url = "http://192.168.0.51:8080/api/xml?depth=2"
    begin
      content = ''
      # Open the feed and parse it
      open(api_url) do |s| content = s.read end
      doc = REXML::Document.new content
      if doc != nil
        @builds = []
        doc.elements.each("hudson/job") do |element|
          build = {}
          build[:name] = element.get_text("name").value
          build[:description] = element.get_text("description").value if element.get_text("description") != nil
          build[:url] = element.get_text("url").value if element.get_text("url") != nil
          build[:state] = element.get_text("color").value if element.get_text("color") != nil

          build[:healthReport] = {}
          build[:healthReport][:description] = element.get_text("healthReport/description").value if element.get_text("healthReport/description") != nil
          build[:healthReport][:score] = element.get_text("healthReport/score").value if element.get_text("healthReport/score") != nil

          build[:latestBuild] = {}
          if (element.elements["build"] != nil)
            build[:latestBuild][:number] = element.elements["build"].get_text("number").value
            build[:latestBuild][:result] = element.elements["build"].get_text("result").value
            build[:latestBuild][:timestamp] = Time.at( element.elements["build"].get_text("timestamp").value.to_f / 1000 )
          end

          @builds << build
        end
      else
        flash.now[:error] = 'Invalid RSS feed.' unless @builds
      end
    rescue SocketError
      flash.now[:error] = 'Unable to connect to remote host.'
    end
  end

  def build
    raise 'no job' if params[:name] == nil

    build_url = "http://192.168.0.51:8080/job/#{params[:name]}/build"

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
end
