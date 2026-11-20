@DiCE
@version1
Feature: DiCE001 - Named storeys and spaces

The rule verifies that each building storey and each space has a name, so that
they can be found by name in the model, in schedules and in the deliverables the
Exchange Information Requirements ask for.

  Scenario: Each building storey has a name

    Given An .IfcBuildingStorey.
    Then .Name. ^is not^ empty

  Scenario: Each space has a name

    Given An .IfcSpace.
    Then .Name. ^is not^ empty
