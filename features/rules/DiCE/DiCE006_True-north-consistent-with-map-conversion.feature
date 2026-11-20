@industry-practice
@DiCE
@version1
Feature: DiCE006 - True north consistent with map conversion
The rule verifies that the TrueNorth direction of the geometric representation context agrees with the rotation
defined by IfcMapConversion (XAxisAbscissa and XAxisOrdinate). When TrueNorth is not given it defaults to the positive Y axis.
The two directions are not identical by definition (grid north and true north differ by the meridian convergence),
so a tolerance of 5 degrees is used. Larger differences usually mean that the rotation was exported with the wrong sign
or was only set in one of the two places.

  Background:
    Given A model with Schema 'IFC4' or 'IFC4.3'


  Scenario: Map conversion rotation agrees with true north

    Given An .IfcMapConversion.

    Then The map conversion rotation must agree with the true north of its context within 5 degrees
