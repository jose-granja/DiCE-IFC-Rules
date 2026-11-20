@industry-practice
@DiCE
@version1
Feature: DiCE015 - Measures not written as text
The rule verifies that properties in custom property sets do not store a number together with its unit as text
(e.g. IfcLabel('250 mm'), IfcText('12,5 m²'), IfcLabel('30%')). These values lose their unit semantics and cannot be
compared or converted. They should be written with a measure type such as IfcLengthMeasure, IfcAreaMeasure or
IfcRatioMeasure, so that the project units apply.
Standard property sets (Pset_) are not checked here, because PSE001 already validates their data types.

  Scenario: Custom properties do not store measures as text

    Given An .IfcPropertySet.
    Given Its .Name. attribute ^does not start^ with 'Pset_'
    Given Its attribute .HasProperties.

    Then Its nominal value must not be a number with a unit written as text
