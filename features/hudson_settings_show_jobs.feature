Feature: Show and Edit Hudson Job Settings

  Background: 
    Given Project "eCookbook" uses "Hudson" Plugin
      And "Developer" has a permission below:
        | permissions         |
        | View Hudson         |
        | Edit Hudson settings|
      And I am logged in as "dlopper" with password "foo"

  @current
  Scenario: Plugin can show hudson jobs. 
    Given Hudson API returns "simple-ruby-application_fetch-job_depth0"
    When  I go to HudsonSettings at "eCookbook" Project
    Then  I should see "Settings"
    When  I fill in "http://localhost:8080" for "settings[url]"
     And  I click "Save"
    Then  I should see job list for settings:
        | Name                    | Num of Builds | Delete Old Build | Days To Keep | Num To Keep |
        | simple-ruby-application | 0             |                  |              |             |
