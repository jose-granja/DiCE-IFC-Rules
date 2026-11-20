@industry-practice
@DiCE
@version1
Feature: DiCE005 - Model geometry close to the origin
The rule verifies that geometry is modelled close to the origin of the project coordinate system,
and that the link to real-world coordinates is made with IfcMapConversion (or ePset_MapConversion in IFC2X3) instead.
Coordinates far from the origin (e.g. full projected eastings and northings) cause floating-point precision loss
in viewers and coordination tools, and lead to shifted or jittering geometry in federated models.
The default limit is 10 km. IFC4.3 models with alignments are excluded because infrastructure can legitimately extend further.

  Scenario: Object placements must be close to the project origin - IFC2X3 and IFC4

    Given A model with Schema 'IFC2X3' or 'IFC4'
    Given An .IfcProduct.

    Then Its absolute placement must lie within 10000 metres of the project origin


  Scenario: Object placements must be close to the project origin - IFC4.3 without alignments

    Given A model with Schema 'IFC4.3'
    Given No .IfcAlignment.
    Given An .IfcProduct.

    Then Its absolute placement must lie within 10000 metres of the project origin


  Scenario: Cartesian points must be close to the origin - IFC2X3 and IFC4

    Given A model with Schema 'IFC2X3' or 'IFC4'
    Given An .IfcCartesianPoint.

    Then Its coordinates must lie within 10000 metres of the origin


  Scenario: Cartesian points must be close to the origin - IFC4.3 without alignments

    Given A model with Schema 'IFC4.3'
    Given No .IfcAlignment.
    Given An .IfcCartesianPoint.

    Then Its coordinates must lie within 10000 metres of the origin


  Scenario: Cartesian point lists must be close to the origin - IFC4

    Given A model with Schema 'IFC4'
    Given An .IfcCartesianPointList.

    Then Its coordinates must lie within 10000 metres of the origin


  Scenario: Cartesian point lists must be close to the origin - IFC4.3 without alignments

    Given A model with Schema 'IFC4.3'
    Given No .IfcAlignment.
    Given An .IfcCartesianPointList.

    Then Its coordinates must lie within 10000 metres of the origin
