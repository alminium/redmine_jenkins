# $Id$

require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/hudson_application_hooks'

class HudsonApplicationHooksTest < ActiveSupport::TestCase
  fixtures :projects

  def test_view_layouts_base_html_head_should_return_zero_length_string

    target = HudsonApplicationHooks.instance

    project = mock()
    project.stubs(:id).returns(999)

    Project.stubs(:find).returns(nil)

    context = {}
    context[:project] = nil
    assert_equal "", target.view_layouts_base_html_head(context)

    context = {}
    context[:project] = project
    assert_equal "", target.view_layouts_base_html_head(context)

    context = {}
    context[:project] = project
    context[:controller] = ProjectsController.new
    assert_equal "", target.view_layouts_base_html_head(context)

    # has no hudson settings
    context = {}
    context[:project] = project
    context[:controller] = ProjectsController.new
    context[:controller].action_name = "activity"
    assert_equal "", target.view_layouts_base_html_head(context)

  end

end
