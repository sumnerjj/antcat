@javascript
Feature: Delete reference
  As Phil Ward
  I want to delete a reference
  So that I can add one to test, then delete it right away
  Or so I can delete one that turns out to have been a duplicate

  Scenario: Delete a reference
    Given these references exist
      | authors    | citation   | year | title |
      | Fisher, B. | Psyche 2:1 | year | title |
    And I am logged in
    When I go to the references page
    * I will confirm on the next step
    * I follow "edit"
    * I press the "Delete" button
    Then I should not see "Fisher, B."

    # TODO Rails 4 breaks this test. Verified manually.
#  Scenario: Try to delete a reference when there are references to it
#    Given these references exist
#      | authors    | citation   | year | title |
#      | Fisher, B. | Psyche 2:1 | year | title |
#    * I am logged in
#    * there is a taxon with that reference as its protonym's reference
#    When I go to the references page
#    Then I should see "Psyche 2:1"
#    When I will confirm on the next step
#    * I follow the first edit
#    * I press the "Delete" button
#    # can't test contents of alert box
#    Then I should see "Psyche 2:1"

  @preview
  Scenario: Delete a reference when not logged in, but in preview mode
    Given these references exist
      | authors    | citation   | year | title |
      | Fisher, B. | Psyche 2:1 | year | title |
    And I am not logged in
    When I go to the references page
    * I will confirm on the next step
    * I follow "edit"
    * I press the "Delete" button
    Then I should not see "Fisher, B."
