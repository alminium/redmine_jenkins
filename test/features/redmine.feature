# $Id$
Feature: redmine
  test for redmine (roles...etc)

  Scenario: Show role permission
    Given I log on as a Admin
      And I select "English" as language

    When I go to Edit roles for "admin"
    Then I should see "View Hudson"
     And I should see "Build Hudson"
     And I should see "Edit Hudson settings"
     And I should not see "view_hudson"
     And I should not see "build_hudson"
     And I should not see "edit_hudson_settings"

