@industry-practice
@DiCE
@version1
Feature: DiCE019 - Unique storey names
The rule verifies that the storeys of a building have unique names (compared case-insensitively).
Duplicated storey names, often left over from copied levels, make storey-based filtering, quantity take-off
and issue (BCF) assignment ambiguous.

  Scenario: Storeys of a building have unique names

    Given An .IfcBuilding.

    Then The names of its aggregated .IfcBuildingStorey. instances must be unique
