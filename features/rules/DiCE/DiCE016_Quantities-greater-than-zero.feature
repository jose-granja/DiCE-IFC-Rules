@industry-practice
@DiCE
@version1
Feature: DiCE016 - Quantities greater than zero
The rule verifies that physical quantities have a value greater than zero.
The schema already forbids negative values for most quantity types, but zero values are allowed and are a common
export error: they appear when the authoring tool could not compute the quantity, and they silently corrupt
cost estimates and take-offs.

  Scenario: Physical quantities are greater than zero

    Given An .IfcPhysicalSimpleQuantity.

    Then Its quantity value must be greater than zero
