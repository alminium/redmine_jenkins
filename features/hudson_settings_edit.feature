# $Id$
Feature: settings_edit
  show and edit hudson settings

  # jsmith joins "eCookbook" Project as a "Developer"
  Scenario: Permission - "jsmith" has permisson, can see settings page.
    Given Project "eCookbook" uses "Hudson" Plugin
      And "Developer" has a permission below:
        | permissions         |
        | View Hudson         |
        | Edit Hudson settings|
      And "jsmith" log on as a User
    When  I go to HudsonSettings at "eCookbook" Project
    Then I should see "Settings"
     And I should see "Plugin uses below url for access to hudson."
    

  @wip
  Scenario: Add new project settings
    Given Project "eCookbook" uses "Hudson" Plugin
      And "Developer" has a permission "view_hudson,edit_hudson_settings"
      And I log on as a User
      And I select "English" as language
      And I join "eCookbook" Project as a "Developer"
    When I go to HudsonSettings at "eCookbook" Project
    Then I should see "Settings"
    When I fill in "http://localhost:8080" for "settings[url]"
     And I press "Save"
    Then the field named "settings[url]" should contain "http://localhost:8080/"

  @wip
  Scenario: Add HealthReport settings
    Given Project "eCookbook" uses "hudson" Plugin
      And "Developer" has a permission "view_hudson,edit_hudson_settings"
      And I log on as a User
      And I select "English" as language
      And I join "eCookbook" Project as a "Developer"
      And Hudson API returns "simple-ruby-application" as depth0
    When I go to HudsonSettings at "eCookbook" Project
     And I fill in "http://localhost:8080" for "settings[url]"
     And I add health report settings - Keyword "Build stability" and URLFormat "http://hoge.com/hudson/simple-job/lastBuild/"
     And I press "Save"
    Then the field named "settings[url]" should contain "http://localhost:8080/"
     And health_report_settings "1" should have Keyword "Build stability" and URLFormat "http://hoge.com/hudson/simple-job/lastBuild/"

  @wip
  Scenario: Add HealthReport settings
    Given Project "eCookbook" uses "hudson" Plugin
      And "Developer" has a permission "view_hudson,edit_hudson_settings"
      And I log on as a User
      And I select "English" as language
      And I join "eCookbook" Project as a "Developer"
      And Hudson API returns "simple-ruby-application" as depth0
    When I go to HudsonSettings at "eCookbook" Project
     And I fill in "http://localhost:8080" for "settings[url]"
     And I add health report settings - Keyword "Build stability" and URLFormat "http://hoge.com/hudson/simple-job/lastBuild/"
     And I press "Save"
    Then I add health report settings - Keyword "Coverage" and URLFormat "http://hoge.com/hudson/simple-job/rcov/"
     And I press "Save"
    Then health_report_settings "1" should have Keyword "Build stability" and URLFormat "http://hoge.com/hudson/simple-job/lastBuild/"
     And health_report_settings "2" should have Keyword "Coverage" and URLFormat "http://hoge.com/hudson/simple-job/rcov/"
