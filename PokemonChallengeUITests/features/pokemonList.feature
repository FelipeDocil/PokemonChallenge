Feature: Pokemon list screen

  @ios @android
  Scenario Outline: User can see the list of pokemon
    Given User is on the Pokemon List screen
    When User <hasOrNot> network and persistent itens are <availableOrNot>
    Then User <canOrNot> see the list

    Examples:
      | hasOrNot | availableOrNot | canOrNot |
      | has      | available      | can      |
      | has      | not available  | can      |
      | has not  | available      | can      |
      | has not  | not available  | cannot   |

  @ios @android
  Scenario: User can see a shiny pokemon
    Given User is on the Pokemon List screen
    When User clicks on the switch
    Then User can see a shiny version of that pokemon

  @ios @android
  Scenario: User can scroll to the end to fetch next page
    Given User is on the Pokemon List screen
    When User scroll to the end of the page
    Then User can see the next page

  @android
  Scenario: User can see a pokemon detail
    Given User is on the Pokemon List screen
    When User clicks on a pokemon on the list
    Then User is on the Pokemon Detail screen
