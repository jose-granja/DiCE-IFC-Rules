@industry-practice
@DiCE
@version1
Feature: DiCE008 - Built elements have a material
The rule verifies that each built element has a material, assigned either to the occurrence or to its type.
Elements that are decomposed into parts (e.g. stairs, curtain walls, element assemblies) are excluded,
because their material is carried by the parts. Proxies are excluded and handled by DiCE009.

  Scenario: Building elements have a material - IFC2X3 and IFC4

    Given A model with Schema 'IFC2X3' or 'IFC4'
    Given An .IfcBuildingElement.
    Given [Its Type] ^is not^ 'IfcBuildingElementProxy'
    Given .IsDecomposedBy. ^is^ empty

    Then It must have a material association, either directly or through its type


  Scenario: Built elements have a material - IFC4.3

    Given A model with Schema 'IFC4.3'
    Given An .IfcBuiltElement.
    Given [Its Type] ^is not^ 'IfcBuildingElementProxy'
    Given .IsDecomposedBy. ^is^ empty

    Then It must have a material association, either directly or through its type
