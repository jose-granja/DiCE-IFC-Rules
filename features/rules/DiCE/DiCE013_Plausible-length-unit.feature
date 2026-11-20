@industry-practice
@DiCE
@version1
Feature: DiCE013 - Plausible length unit
The rule verifies that storey elevations have plausible values once converted to metres with the declared length unit.
An elevation of more than 1000 m relative to the building's internal reference height is a strong sign that
values were written in millimetres while the length unit declares metres (or the opposite).

  Scenario: Storey elevations are plausible for the declared length unit

    Given An .IfcBuildingStorey.

    Then The magnitude of its .Elevation. must not exceed 1000 metres
