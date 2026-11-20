@industry-practice
@DiCE
@version1
Feature: DiCE018 - Storey elevation consistent with placement
The rule verifies that the Elevation attribute of each IfcBuildingStorey agrees with the height of the storey's
local placement relative to the building it belongs to. Some applications read the attribute and others the placement,
so a mismatch puts elements at different heights depending on the receiving software.
A tolerance of 0.01 m is used.

  Scenario: Storey elevation matches the storey placement

    Given An .IfcBuildingStorey.
    Given .Elevation. ^is not^ empty

    Then Its elevation must match the height of its placement relative to the building within 0.01 metres
