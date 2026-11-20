@industry-practice
@DiCE
@version1
Feature: DiCE009 - Described proxy elements
The rule verifies that each IfcBuildingElementProxy carries enough information to tell what it represents:
a Name, and either an ObjectType or a type object with a Name or ElementType.
Anonymous proxies cannot be classified, filtered or mapped to a proper entity by the receiver.

  Scenario: Proxy elements have a name

    Given An .IfcBuildingElementProxy.

    Then The value of attribute .Name. must be ^not empty^


  Scenario: Proxy elements describe what they represent

    Given An .IfcBuildingElementProxy.

    Then It must have an object type or be typed by a type object with a name or element type
