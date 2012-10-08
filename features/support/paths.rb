module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^"login"$/
      "/login"

    when /^Roles$/
      "/roles"

    when /^"(.*)" Project$/
      "/projects/show/#{$1.downcase}"

    when /Hudson at "(.*)" Project/
      "/hudson/index/#{$1.downcase}"

    when /HudsonSettings at "(.*)" Project/
      "/projects/#{$1.downcase}/hudson_settings/edit"

    when /ProjectSettings at "(.*)" Project/
      "/projects/#{$1.downcase}/settings"


    when /issue #(.*)/
      "/issues/#{$1}"

    when /Edit roles for "(.*)"$/
      "/roles/edit/1"

      # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
