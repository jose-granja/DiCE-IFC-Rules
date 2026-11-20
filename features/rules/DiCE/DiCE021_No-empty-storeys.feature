@industry-practice
@DiCE
@version1
Feature: DiCE021 - No empty storeys
The rule verifies that every IfcBuildingStorey contains or references at least one element, or is decomposed into
at least one IfcSpace. Empty storeys usually point to elements assigned to the wrong level on export, or to
reference levels that should not have been exported as storeys.

  Scenario: Storeys are not empty

    Given An .IfcBuildingStorey.

    Then It must contain at least one element or be decomposed into at least one space
