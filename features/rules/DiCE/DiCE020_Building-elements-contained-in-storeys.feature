@industry-practice
@DiCE
@version1
Feature: DiCE020 - Building elements contained in storeys
The rule verifies that, when a building is decomposed into storeys, its built elements are contained in a storey
and not directly in the building. Elements attached to the building instead of a storey disappear from
storey-based views, schedules and model-checking scopes.
Elements contained in the site (external works) are not affected by this rule.

  Scenario: Building elements are contained in a storey - IFC2X3 and IFC4

    Given A model with Schema 'IFC2X3' or 'IFC4'
    Given An .IfcBuildingElement.

    Then Its spatial container must be a storey when its building is decomposed into storeys


  Scenario: Built elements are contained in a storey - IFC4.3

    Given A model with Schema 'IFC4.3'
    Given An .IfcBuiltElement.

    Then Its spatial container must be a storey when its building is decomposed into storeys
