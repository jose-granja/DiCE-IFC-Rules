@industry-practice
@DiCE
@version1
Feature: DiCE003 - Doors and windows fill an opening
The rule verifies that doors and windows that are not part of an assembly (e.g. a curtain wall) fill an opening
through IfcRelFillsElement. Without the opening relationship the host wall is exported without a hole, net quantities
are wrong and the door or window cannot be traced to its host.

  Scenario Outline: Doors and windows fill an opening

    Given An .<Entity>.
    Given .Decomposes. ^is^ empty

    Then .FillsVoids. ^is^ not empty

    Examples:
      | Entity    |
      | IfcDoor   |
      | IfcWindow |
