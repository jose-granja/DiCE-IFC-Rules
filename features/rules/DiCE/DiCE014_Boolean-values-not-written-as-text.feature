@industry-practice
@DiCE
@version1
Feature: DiCE014 - Boolean values not written as text
The rule verifies that properties in custom property sets do not store yes/no information as text
(e.g. IfcLabel('Yes'), IfcText('TRUE'), IfcLabel('Sim')). Such values cannot be checked with IDS boolean requirements
and are interpreted differently by each application. They should be written as IfcBoolean or IfcLogical.
Standard property sets (Pset_) are not checked here, because PSE001 already validates their data types.

  Scenario: Custom properties do not store booleans as text

    Given An .IfcPropertySet.
    Given Its .Name. attribute ^does not start^ with 'Pset_'
    Given Its attribute .HasProperties.

    Then Its nominal value must not be a boolean written as text
