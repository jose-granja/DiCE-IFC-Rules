@industry-practice
@DiCE
@version1
Feature: DiCE004 - No duplicated elements
The rule verifies that the model does not contain duplicated elements: two or more elements of the same class
with the same absolute placement (within 1 mm) and identical body geometry.
Duplicates, typically caused by copy-paste or by overlapping linked models, double the quantities and create false clashes.
Feature elements and virtual elements are excluded.

  Scenario: Elements are not duplicated

    Given An .IfcElement.
    Given [Its Type] ^is not^ 'IfcFeatureElement' ^including subtypes^
    Given [Its Type] ^is not^ 'IfcVirtualElement'

    Then It must not duplicate another element with the same class, absolute placement and body geometry
