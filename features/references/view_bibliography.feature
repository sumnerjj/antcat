@dormant
Feature: View bibliography
  As a researcher
  I want to see what the literature is for ant taxonomy
  So that I can obtain it and read it

  Scenario: View one entry
    Given these references exist
      | authors    | year | citation_year | title     | citation | cite_code | possess | date     | public_notes | editor_notes   |
      | Ward, P.S. | 2010 | 2010d         | Ant Facts | Ants 1:1 | 232       | PSW     | 20100712 | Public notes | Editor's notes |
    When I go to the references page
    Then I should see "Ward, P.S. 2010d. Ant Facts. Ants 1:1"
    And I should see "Public notes"
    And I should not see "Editor's notes"

  Scenario: View one entry with italics
    Given these references exist
      | title                                             | authors | citation | year |
      | Territory \|defense\| by the ant *Azteca trigona* | authors | Ants 2:2 | year |
    When I go to the references page
    Then I should see "Azteca trigona" italicized
    And I should see "defense" italicized

  Scenario: Dangerous text
    Given these references exist
      | title               | authors | citation | year | public_notes |
      | <script><i>Ants</i> | authors | Ants 3:3 | year | {<html>}     |
    When I go to the references page
    Then I should see "<script>"
    And I should see "<html>"

  Scenario: Viewing more than one entry, sorted by author + date (including slug)
    Given these references exist
      | authors        | year | citation_year | title                      | citation   |
      | Wheeler, W. M. | 1910 | 1910b         | Ants                       | Psyche 2:2 |
      | Forel, A.      | 1874 | 1874          | Les fourmis de la Suisse   | Neue 26:10 |
      | Wheeler, W. M. | 1910 | 1910a         | Small artificial ant-nests | Psyche 1:1 |
    When I go to the references page
    Then I should see these entries in this order:
      | entry                                                         |
      | Forel, A. 1874. Les fourmis de la Suisse. Neue 26:10          |
      | Wheeler, W. M. 1910a. Small artificial ant-nests. Psyche 1:1  |
      | Wheeler, W. M. 1910b. Ants. Psyche 2:2                        |

  Scenario: Viewing an entry with a URL to a document on our site, but the user isn't logged in
    Given these references exist
      | authors    | year | citation_year | title     | citation | cite_code | possess | date     |
      | Ward, P.S. | 2010 | 2010d         | Ant Facts | Ants 1:1 | 232       | PSW     | 20100712 |
    And that the entry has a URL that's on our site
    When I go to the references page
    Then I should see a "PDF" link

  @preview
  Scenario: Even in preview environment, give access to our private PDFs
    Given these references exist
      | authors    | year | citation_year | title     | citation | cite_code | possess | date     |
      | Ward, P.S. | 2010 | 2010d         | Ant Facts | Ants 1:1 | 232       | PSW     | 20100712 |
    And that the entry has a URL that's on our site
    When I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a URL to a document on our site, the user isn't logged in, but it's public
    Given these references exist
      | authors    | year | citation_year | title     | citation | date     |
      | Ward, P.S. | 2010 | 2010d         | Ant Facts | Ants 1:1 | 20100712 |
    And that the entry has a URL that's on our site that is public
    When I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a URL to a document that's not on our site, and the user isn't logged in
    Given these references exist
      | authors    | year | citation_year | title     | citation | cite_code | possess |
      | Ward, P.S. | 2010 | 2010d         | Ant Facts | Ants 1:1 | 232       | PSW     |
    And that the entry has a URL that's not on our site
    When I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a URL to a document on our site, but the user is logged in
    Given these references exist
      | authors    | year | citation_year | title     | citation | cite_code |
      | Ward, P.S. | 2010 | 2010d         | Ant Facts | Ants 1:1 | 232       |
    And that the entry has a URL that's on our site
    And I am logged in
    When I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a URL to a document that's not on our site, and the user is logged in
    Given these references exist
      | authors    | year | citation_year | title     | citation |
      | Ward, P.S. | 2010 | 2010d         | Ant Facts | Ants 1:1 |
    And that the entry has a URL that's not on our site
    And I log in
    And I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing a nested reference
    Given these book references exist
      | authors    | year | title | citation                |
      | Bolton, B. | 2010 | Ants  | New York: Wiley, 23 pp. |
    And the following entry nests it
      | authors    | title          | year | pages_in |
      | Ward, P.S. | Dolichoderinae | 2010 | In:      |
    When I go to the references page
    Then I should see "Ward, P.S. 2010. Dolichoderinae. In: Bolton, B. 2010. Ants. New York: Wiley, 23 pp."

  Scenario: Viewing a missing reference
    Given these references exist
      | authors    | year | citation_year | title     | citation |
      | Ward, P.S. | 2010 | 2010d         | Ant Facts | Ants 1:1 |
    And there is a missing reference
    When I go to the references page
    Then I should not see the missing reference
    And I should see "Ward, P.S. 2010d. Ant Facts. Ants 1:1 "

  Scenario: Not logged in
    Given these references exist
      | authors | citation   | title | year | public_notes | editor_notes | taxonomic_notes |
      | authors | Psyche 3:3 | title | 2010 | Public       | Editor       | Taxonomy        |
    Given I am not logged in
    When I go to the references page
    Then I should see "Public"
    And I should not see "Editor"
    And I should not see "Taxonomy"

  Scenario: Logged in
    Given these references exist
      | authors | citation   | title | year | public_notes | editor_notes | taxonomic_notes |
      | authors | Psyche 3:3 | title | 2010 | Public       | Editor       | Taxonomy        |
    When I log in
    And I go to the references page
    Then I should see "Public"
    And I should see "Editor"
    And I should see "Taxonomy"

