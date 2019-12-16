Feature: Pokemon detail screen

  @ios @android
  Scenario Outline: User can see the detail of pokemon
    Given User is on the Pokemon Detail screen
    When User <hasOrNot> network and persistent itens are <availableOrNot>
    Then User <canOrNot> see the pokedex entries

    Examples:
      | hasOrNot | availableOrNot | canOrNot |
      | has      | available      | can      |
      | has      | not available  | can      |
      | has not  | available      | can      |
      | has not  | not available  | cannot   |

  @ios @android
  Scenario: User can see a detail of a shiny pokemon
    Given User is on the Pokemon Detail screen of a shiny pokemon
    Then User can see a shiny image and shiny on the title
