# $Id$
Feature: settings_edit
  show and edit hudson settings

  Background: 
    Given Project "eCookbook" uses "Hudson" Plugin
      And "Developer" has a permission below:
        | permissions         |
        | View Hudson         |
        | Edit Hudson settings|
      And I am logged in as "dlopper" with password "foo"

  # jsmith joins "eCookbook" Project as a "Developer"
  Scenario: Permission - "dlopper" has permisson, can see settings page.
    When I go to HudsonSettings at "eCookbook" Project
    Then I should see "Settings"
     And I should see "Plugin uses below url for access to hudson."

  Scenario: Add new project settings
    When I go to HudsonSettings at "eCookbook" Project
    Then I should see "Settings"
    When I fill in "http://localhost:8080" for "settings[url]"
     And I click "Save"
    Then the field named "settings[url]" should contain "http://localhost:8080/"

  @javascript
  Scenario: Add HealthReport settings
    When  I go to HudsonSettings at "eCookbook" Project
     And  I fill in "http://localhost:8080" for "settings[url]"
     And  I add health report settings below:
          | keyword         | url_format                                   |
          | Build stability | http://hoge.com/hudson/simple-job/lastBuild/ |
     And  I click "Save"
    Then  the field named "settings[url]" should contain "http://localhost:8080/"
     And  I should see health report settings below:
          | keyword         | url_format                                   |
          | Build stability | http://hoge.com/hudson/simple-job/lastBuild/ |

  @javascript @current
  Scenario: Add HealthReport settings
    When I go to HudsonSettings at "eCookbook" Project
     And I fill in "http://localhost:8080" for "settings[url]"
     And  I add health report settings below:
          | keyword         | url_format                                   |
          | Build stability | http://hoge.com/hudson/simple-job/lastBuild/ |
          | Coverage        | http://hoge.com/hudson/simple-job/rcov/      |
     And  I click "Save"
    Then  I should see health report settings below:
          | keyword         | url_format                                   |
          | Build stability | http://hoge.com/hudson/simple-job/lastBuild/ |
          | Coverage        | http://hoge.com/hudson/simple-job/rcov/      |
