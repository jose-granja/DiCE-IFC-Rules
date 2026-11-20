@industry-practice
@DiCE
@version1
Feature: DiCE011 - Predefined type on untyped occurrences
The rule verifies that elements without a type object have a PredefinedType other than NOTDEFINED (or empty).
For untyped occurrences the PredefinedType is the only standard way to tell, for example, a floor slab from a roof slab
or a shear wall from a partition. Elements typed by an IfcTypeObject are not affected, because their predefined type
is given by the type (see OJT001 for that case).
Feature elements (openings, projections, voids) are excluded.

  Background:
    Given A model with Schema 'IFC4' or 'IFC4.3'


  Scenario: Untyped elements have a specific predefined type

    Given An .IfcElement.
    Given [Its Type] ^is not^ 'IfcFeatureElement' ^including subtypes^
    Given .IsTypedBy. ^is^ empty

    Then Its .PredefinedType. must be set to a value other than NOTDEFINED
