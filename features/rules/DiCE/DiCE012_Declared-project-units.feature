@industry-practice
@DiCE
@version1
Feature: DiCE012 - Declared project units
The rule verifies that the project declares the basic units needed to interpret geometry and quantities:
length, area, volume and plane angle. Without an explicit declaration, receiving applications have to guess,
which is a common cause of models that are imported 1000 times too large or too small.

  Scenario Outline: The project declares the basic units

    Given An .IfcProject.

    Then Its unit assignment must declare a unit of type '<UnitType>'

    Examples:
      | UnitType       |
      | LENGTHUNIT     |
      | AREAUNIT       |
      | VOLUMEUNIT     |
      | PLANEANGLEUNIT |
