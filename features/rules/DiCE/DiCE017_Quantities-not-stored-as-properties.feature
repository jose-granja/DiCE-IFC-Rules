@industry-practice
@DiCE
@version1
Feature: DiCE017 - Quantities not stored as properties
The rule verifies that areas, volumes, weights, lengths and perimeters are not stored as properties in custom property sets.
Quantities belong in IfcElementQuantity (preferably the standard Qto_ sets), where they carry a quantity type and unit.
Standard property sets (Pset_) are not checked here, because PSE001 already validates their contents.

  Scenario: Custom property sets do not contain quantities

    Given An .IfcPropertySet.
    Given Its .Name. attribute ^does not start^ with 'Pset_'
    Given Its attribute .HasProperties.
    Given Its attribute .Name.

    Then Its value must not conform to the expression /(?i)^(gross|net)?[ _]?(side|footprint|floor|surface|ceiling|wall|cross[ _]?section|outer[ _]?surface)?[ _]?(area|volume|weight)$|^(length|perimeter)$/
