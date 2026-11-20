@industry-practice
@DiCE
@version1
Feature: DiCE010 - Limited use of proxy elements
The rule verifies that IfcBuildingElementProxy is a last resort and not the default export class.
At most 10 percent of the physical elements (IfcElement excluding IfcFeatureElement and IfcVirtualElement)
may be proxies. A higher share usually means that the export mapping of the authoring tool was not configured.

  Scenario: The share of proxy elements is limited

    Given An .IfcBuildingElementProxy.

    Then At most 10 percent of the physical elements may be instances of .IfcBuildingElementProxy.
