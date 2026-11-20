@DiCE
@version1
Feature: DiCE002 - Parcel and surroundings spatial structure
The rule verifies the spatial breakdown agreed for the parcel model (Ficheiro 1) and for the surroundings and natural terrain model (Ficheiro 2).
Both files share the structure IfcProject > IfcSite > (IfcGeographicElement, IfcBuilding).
The parcel model additionally breaks each IfcBuilding down into IfcBuildingStorey and each IfcBuildingStorey into IfcSpace.
IfcSite, IfcBuilding, IfcBuildingStorey and IfcSpace are related through IfcRelAggregates, while the terrain (IfcGeographicElement) is contained in the IfcSite through IfcRelContainedInSpatialStructure.

  Background:
    Given A model with Schema 'IFC4' or 'IFC4.3'


  Scenario: Each file has exactly one parcel or surroundings site

    Then There must be exactly 1 instance(s) of .IfcSite.


  Scenario: Each file has at least one building

    Then There must be at least 1 instance(s) of .IfcBuilding.


  Scenario: Each file has at least one terrain element

    Then There must be at least 1 instance(s) of .IfcGeographicElement.


  Scenario: The site is directly aggregated by the project

    Given An .IfcSite.

    Then It must be aggregated by IfcProject directly


  Scenario: Each building is directly aggregated by the site

    Given An .IfcBuilding.

    Then It must be aggregated by IfcSite directly


  Scenario: Each building storey is directly aggregated by a building

    Given An .IfcBuildingStorey.

    Then It must be aggregated by IfcBuilding directly


  Scenario: Each space is directly aggregated by a building storey

    Given An .IfcSpace.

    Then It must be aggregated by IfcBuildingStorey directly


  Scenario: Each terrain element is directly contained in the site

    Given An .IfcGeographicElement.

    Then It must be contained in IfcSite directly
