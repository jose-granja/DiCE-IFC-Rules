@industry-practice
@DiCE
@version1
Feature: DiCE007 - Material set usage on occurrences
The rule verifies that layered and profiled elements use the material set usage concepts:
an IfcMaterialLayerSet or IfcMaterialProfileSet is defined at the type, and the occurrence is associated
with the corresponding IfcMaterialLayerSetUsage or IfcMaterialProfileSetUsage.
Assigning the bare set to the occurrence, or omitting the usage, loses the layer direction, offset and
cardinal point, so layer thicknesses and profile positions cannot be reconstructed.
https://ifc43-docs.standards.buildingsmart.org/IFC/RELEASE/IFC4x3/HTML/concepts/Object_Association/Material_Association/Material_Layer_Set_Usage/content.html

  Background:
    Given A model with Schema 'IFC4' or 'IFC4.3'


  Scenario Outline: Occurrences are not associated with a bare material set

    Given An .<Entity>.

    Then It must not be directly associated with an .<MaterialSet>.

    Examples:
      | Entity      | MaterialSet           |
      | IfcWall     | IfcMaterialLayerSet   |
      | IfcSlab     | IfcMaterialLayerSet   |
      | IfcRoof     | IfcMaterialLayerSet   |
      | IfcCovering | IfcMaterialLayerSet   |
      | IfcPlate    | IfcMaterialLayerSet   |
      | IfcBeam     | IfcMaterialProfileSet |
      | IfcColumn   | IfcMaterialProfileSet |
      | IfcMember   | IfcMaterialProfileSet |
      | IfcPile     | IfcMaterialProfileSet |


  Scenario Outline: Occurrences of a type with a material set carry the usage

    Given An .<Entity>.

    Then It must be associated with an .<Usage>. when its type is associated with an .<MaterialSet>.

    Examples:
      | Entity      | MaterialSet           | Usage                      |
      | IfcWall     | IfcMaterialLayerSet   | IfcMaterialLayerSetUsage   |
      | IfcSlab     | IfcMaterialLayerSet   | IfcMaterialLayerSetUsage   |
      | IfcCovering | IfcMaterialLayerSet   | IfcMaterialLayerSetUsage   |
      | IfcPlate    | IfcMaterialLayerSet   | IfcMaterialLayerSetUsage   |
      | IfcBeam     | IfcMaterialProfileSet | IfcMaterialProfileSetUsage |
      | IfcColumn   | IfcMaterialProfileSet | IfcMaterialProfileSetUsage |
      | IfcMember   | IfcMaterialProfileSet | IfcMaterialProfileSetUsage |
      | IfcPile     | IfcMaterialProfileSet | IfcMaterialProfileSetUsage |
