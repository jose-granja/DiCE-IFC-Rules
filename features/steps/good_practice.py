"""
Step implementations for the IFC good-practice rule set (DiCE003 to DiCE021).

These rules complement the buildingSMART Validation Service. They only cover
issues that are not already checked by its syntax, schema, header or
normative/industry-practice gherkin rules. All features that use these steps
are tagged @industry-practice, so every finding is reported as a WARNING.

Lengths are always compared in metres: values read from the model are
multiplied by the project length unit scale.
"""

import hashlib
import math
import re
from collections import defaultdict

import ifcopenshell
import ifcopenshell.util.element
import ifcopenshell.util.placement
import ifcopenshell.util.unit

from validation_handling import gherkin_ifc, global_rule
from validation_results import ValidationOutcome, OutcomeSeverity


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

_unit_scale_cache = {}
_placement_cache = {}
_duplicate_cache = {}


def _unit_scale(model):
    key = id(model)
    if key not in _unit_scale_cache:
        try:
            _unit_scale_cache[key] = ifcopenshell.util.unit.calculate_unit_scale(model)
        except Exception:
            _unit_scale_cache[key] = 1.0
    return _unit_scale_cache[key]


def _absolute_matrix(placement):
    """4x4 matrix of an IfcLocalPlacement in project units, or None when it cannot be resolved
    (e.g. IfcLinearPlacement or IfcGridPlacement)."""
    if placement is None:
        return None
    key = (id(placement.file), placement.id())
    if key not in _placement_cache:
        try:
            if not placement.is_a("IfcLocalPlacement"):
                raise ValueError
            _placement_cache[key] = ifcopenshell.util.placement.get_local_placement(placement)
        except Exception:
            _placement_cache[key] = None
    return _placement_cache[key]


def _pass(inst):
    return ValidationOutcome(inst=inst, severity=OutcomeSeverity.PASSED)


def _fail(inst, expected, observed):
    return ValidationOutcome(inst=inst, expected=expected, observed=observed, severity=OutcomeSeverity.ERROR)


def _material_associations(obj):
    for rel in getattr(obj, "HasAssociations", None) or ():
        if rel.is_a("IfcRelAssociatesMaterial"):
            yield rel.RelatingMaterial


def _string_nominal_value(prop):
    """Return the string of a single-value property stored as IfcLabel/IfcText/IfcIdentifier, else None."""
    if not prop.is_a("IfcPropertySingleValue"):
        return None
    nv = prop.NominalValue
    if nv is None or nv.is_a() not in ("IfcLabel", "IfcText", "IfcIdentifier"):
        return None
    value = nv.wrappedValue
    return value if isinstance(value, str) else None


def _parent_building(storey):
    obj = storey
    for _ in range(10):
        rels = getattr(obj, "Decomposes", None) or ()
        if not rels:
            return None
        obj = rels[0].RelatingObject
        if obj.is_a("IfcBuilding"):
            return obj
    return None


# ---------------------------------------------------------------------------
# DiCE005 - coordinates near the origin
# ---------------------------------------------------------------------------

@gherkin_ifc.step("Its coordinates must lie within {distance:g} metres of the origin")
def step_impl(context, inst, distance):
    scale = _unit_scale(context.model)
    if inst.is_a("IfcCartesianPoint"):
        points = [inst.Coordinates]
    elif inst.is_a("IfcCartesianPointList"):
        points = inst.CoordList
    else:
        yield _pass(inst)
        return
    furthest = max((math.sqrt(sum(c * c for c in p)) for p in points), default=0.0) * scale
    if furthest <= distance:
        yield _pass(inst)
    else:
        yield _fail(inst, f"coordinates within {distance:g} m of the origin", f"{furthest:.1f} m from the origin")


@gherkin_ifc.step("Its absolute placement must lie within {distance:g} metres of the project origin")
def step_impl(context, inst, distance):
    m = _absolute_matrix(getattr(inst, "ObjectPlacement", None))
    if m is None:
        yield _pass(inst)
        return
    d = math.sqrt(sum(float(m[i][3]) ** 2 for i in range(3))) * _unit_scale(context.model)
    if d <= distance:
        yield _pass(inst)
    else:
        yield _fail(inst, f"placement within {distance:g} m of the project origin", f"{d:.1f} m from the project origin")


# ---------------------------------------------------------------------------
# DiCE006 - true north versus map conversion rotation
# ---------------------------------------------------------------------------

@gherkin_ifc.step("The map conversion rotation must agree with the true north of its context within {tolerance:g} degrees")
def step_impl(context, inst, tolerance):
    ctx = inst.SourceCRS
    if ctx is None or not ctx.is_a("IfcGeometricRepresentationContext"):
        yield _pass(inst)
        return
    a = inst.XAxisAbscissa if inst.XAxisAbscissa is not None else 1.0
    b = inst.XAxisOrdinate if inst.XAxisOrdinate is not None else 0.0
    theta = math.atan2(b, a)
    # grid north expressed in the local engineering coordinate system
    gx, gy = math.sin(theta), math.cos(theta)
    tn = ctx.TrueNorth.DirectionRatios[:2] if ctx.TrueNorth is not None else (0.0, 1.0)
    norm = math.hypot(*tn)
    if norm == 0:
        yield _pass(inst)
        return
    tx, ty = tn[0] / norm, tn[1] / norm
    diff = math.degrees(math.acos(max(-1.0, min(1.0, gx * tx + gy * ty))))
    if diff <= tolerance:
        yield _pass(inst)
    else:
        grid_angle = math.degrees(math.atan2(gx, gy))
        tn_angle = math.degrees(math.atan2(tx, ty))
        yield _fail(
            inst,
            f"TrueNorth within {tolerance:g} degrees of the grid north implied by IfcMapConversion",
            f"grid north at {grid_angle:.2f} deg, TrueNorth at {tn_angle:.2f} deg, clockwise from local +Y (difference {diff:.2f} deg)",
        )


# ---------------------------------------------------------------------------
# DiCE012 / DiCE013 - units
# ---------------------------------------------------------------------------

@gherkin_ifc.step("Its unit assignment must declare a unit of type '{unit_type}'")
def step_impl(context, inst, unit_type):
    ua = getattr(inst, "UnitsInContext", None)
    declared = [getattr(u, "UnitType", None) for u in (ua.Units if ua else ())]
    if unit_type in declared:
        yield _pass(inst)
    else:
        yield _fail(inst, unit_type, sorted(x for x in declared if x) or "no unit assignment")


@gherkin_ifc.step("The magnitude of its .{attribute}. must not exceed {limit:g} metres")
def step_impl(context, inst, attribute, limit):
    value = getattr(inst, attribute, None)
    if value is None:
        yield _pass(inst)
        return
    metres = abs(value) * _unit_scale(context.model)
    if metres <= limit:
        yield _pass(inst)
    else:
        yield _fail(inst, f"|{attribute}| <= {limit:g} m", f"{metres:.1f} m")


# ---------------------------------------------------------------------------
# DiCE018 - DiCE021 - spatial structure
# ---------------------------------------------------------------------------

@gherkin_ifc.step("Its elevation must match the height of its placement relative to the building within {tolerance:g} metres")
def step_impl(context, inst, tolerance):
    building = _parent_building(inst)
    ms = _absolute_matrix(inst.ObjectPlacement)
    mb = _absolute_matrix(building.ObjectPlacement) if building else None
    if inst.Elevation is None or ms is None or mb is None:
        yield _pass(inst)
        return
    scale = _unit_scale(context.model)
    placement_height = (float(ms[2][3]) - float(mb[2][3])) * scale
    elevation = inst.Elevation * scale
    if abs(placement_height - elevation) <= tolerance:
        yield _pass(inst)
    else:
        yield _fail(inst, f"Elevation = placement height ({placement_height:.3f} m)", f"Elevation = {elevation:.3f} m")


@gherkin_ifc.step("The names of its aggregated .{entity}. instances must be unique")
def step_impl(context, inst, entity):
    names = defaultdict(list)
    for rel in getattr(inst, "IsDecomposedBy", None) or ():
        for child in rel.RelatedObjects:
            if child.is_a(entity):
                names[(child.Name or "").strip().lower()].append(child)
    duplicates = {k: v for k, v in names.items() if len(v) > 1}
    if not duplicates:
        yield _pass(inst)
    else:
        yield _fail(inst, f"unique {entity} names", [c for v in duplicates.values() for c in v])


@gherkin_ifc.step("Its spatial container must be a storey when its building is decomposed into storeys")
def step_impl(context, inst):
    for rel in getattr(inst, "ContainedInStructure", None) or ():
        container = rel.RelatingStructure
        if container.is_a("IfcBuilding"):
            has_storeys = any(
                c.is_a("IfcBuildingStorey")
                for r in container.IsDecomposedBy or ()
                for c in r.RelatedObjects
            )
            if has_storeys:
                yield _fail(inst, "contained in an IfcBuildingStorey", container)
                return
    yield _pass(inst)


@gherkin_ifc.step("It must contain at least one element or be decomposed into at least one space")
def step_impl(context, inst):
    contains = any(r.RelatedElements for r in getattr(inst, "ContainsElements", None) or ())
    references = any(r.RelatedElements for r in getattr(inst, "ReferencesElements", None) or ())
    spaces = any(c.is_a("IfcSpace") for r in getattr(inst, "IsDecomposedBy", None) or () for c in r.RelatedObjects)
    if contains or references or spaces:
        yield _pass(inst)
    else:
        yield _fail(inst, "contained elements or aggregated spaces", "empty storey")


# ---------------------------------------------------------------------------
# DiCE009 - DiCE011 - object classification
# ---------------------------------------------------------------------------

@gherkin_ifc.step("It must have an object type or be typed by a type object with a name or element type")
def step_impl(context, inst):
    if (inst.ObjectType or "").strip():
        yield _pass(inst)
        return
    typ = ifcopenshell.util.element.get_type(inst)
    if typ is not None and ((typ.Name or "").strip() or (getattr(typ, "ElementType", None) or "").strip()):
        yield _pass(inst)
        return
    yield _fail(inst, "ObjectType, or a type object with Name/ElementType", "no description of what the proxy represents")


@gherkin_ifc.step("At most {percent:g} percent of the physical elements may be instances of .{entity}.")
@global_rule
def step_impl(context, inst, percent, entity):
    elements = [
        e for e in context.model.by_type("IfcElement")
        if not e.is_a("IfcFeatureElement") and not e.is_a("IfcVirtualElement")
    ]
    if not elements:
        yield _pass(inst)
        return
    count = sum(1 for e in elements if e.is_a(entity))
    share = 100.0 * count / len(elements)
    if share <= percent:
        yield _pass(inst)
    else:
        yield _fail(inst, f"at most {percent:g}% {entity}", f"{share:.1f}% ({count} of {len(elements)} elements)")


@gherkin_ifc.step("Its .PredefinedType. must be set to a value other than NOTDEFINED")
def step_impl(context, inst):
    try:
        value = inst.PredefinedType
    except AttributeError:
        yield _pass(inst)
        return
    if value is not None and value != "NOTDEFINED":
        yield _pass(inst)
    else:
        yield _fail(inst, "a specific PredefinedType (or USERDEFINED with ObjectType)", value or "empty")


# ---------------------------------------------------------------------------
# DiCE014 / DiCE015 - property values with the wrong data type
# ---------------------------------------------------------------------------

_BOOLEAN_TEXT = re.compile(
    r"^\s*(yes|no|y|n|true|false|\.t\.|\.f\.|sim|n[aã]o|s[iì]|vero|falso|verdadeiro|ja|nein|wahr|falsch|oui|non|vrai|faux)\s*$",
    re.IGNORECASE,
)

_MEASURE_TEXT = re.compile(
    r"^\s*[+-]?\d+(?:[.,]\d+)?\s*"
    r"(mm|cm|dm|m|km|mm2|cm2|m2|mm²|cm²|m²|mm3|cm3|m3|mm³|cm³|m³|l|kg|t|n|kn|pa|kpa|mpa|gpa|n/mm2|n/mm²|kn/m|kn/m2|kn/m²|"
    r"w|kw|w/m2k|w/m²k|w/\(m2k\)|w/\(m²k\)|w/\(m2·k\)|w/\(m²·k\)|w/mk|w/\(m·k\)|°|deg|%)\s*$",
    re.IGNORECASE,
)


@gherkin_ifc.step("Its nominal value must not be a boolean written as text")
def step_impl(context, inst):
    value = _string_nominal_value(inst)
    if value is not None and _BOOLEAN_TEXT.match(value):
        yield _fail(inst, "IfcBoolean or IfcLogical", f"{inst.NominalValue.is_a()}('{value}')")
    else:
        yield _pass(inst)


@gherkin_ifc.step("Its nominal value must not be a number with a unit written as text")
def step_impl(context, inst):
    value = _string_nominal_value(inst)
    if value is not None and _MEASURE_TEXT.match(value):
        yield _fail(inst, "a typed measure (e.g. IfcLengthMeasure, IfcAreaMeasure, IfcRatioMeasure)", f"{inst.NominalValue.is_a()}('{value}')")
    else:
        yield _pass(inst)


# ---------------------------------------------------------------------------
# DiCE016 - quantity values
# ---------------------------------------------------------------------------

@gherkin_ifc.step("Its quantity value must be greater than zero")
def step_impl(context, inst):
    try:
        value = inst[3]
    except Exception:
        yield _pass(inst)
        return
    if isinstance(value, (int, float)) and value <= 0:
        yield _fail(inst, "> 0", f"{inst.Name} = {value}")
    else:
        yield _pass(inst)


# ---------------------------------------------------------------------------
# DiCE007 / DiCE008 - material association
# ---------------------------------------------------------------------------

@gherkin_ifc.step("It must not be directly associated with an .{entity}.")
def step_impl(context, inst, entity):
    bare = [m for m in _material_associations(inst) if m.is_a() == entity]
    if bare:
        yield _fail(inst, f"{entity}Usage at the occurrence", bare[0])
    else:
        yield _pass(inst)


@gherkin_ifc.step("It must be associated with an .{usage}. when its type is associated with an .{material_set}.")
def step_impl(context, inst, usage, material_set):
    typ = ifcopenshell.util.element.get_type(inst)
    type_has_set = typ is not None and any(m.is_a() == material_set for m in _material_associations(typ))
    if not type_has_set:
        yield _pass(inst)
        return
    if any(m.is_a() == usage for m in _material_associations(inst)):
        yield _pass(inst)
    else:
        yield _fail(inst, f"{usage} at the occurrence", f"{material_set} on {typ.is_a()}(#{typ.id()}) without usage")


@gherkin_ifc.step("It must have a material association, either directly or through its type")
def step_impl(context, inst):
    if ifcopenshell.util.element.get_material(inst, should_inherit=True) is not None:
        yield _pass(inst)
    else:
        yield _fail(inst, "IfcRelAssociatesMaterial on the element or its type", "no material")


# ---------------------------------------------------------------------------
# DiCE004 - duplicated elements
# ---------------------------------------------------------------------------

def _structural_fingerprint(model, item):
    h = hashlib.sha1()
    for sub in model.traverse(item):
        h.update(sub.is_a().encode())
        for v in sub:
            if isinstance(v, ifcopenshell.entity_instance):
                continue
            if isinstance(v, float):
                v = round(v, 6)
            elif isinstance(v, (tuple, list)):
                v = repr(v) if len(repr(v)) < 100000 else hashlib.sha1(repr(v).encode()).hexdigest()
            h.update(repr(v).encode())
    return h.hexdigest()


def _body_fingerprint(model, element):
    rep = getattr(element, "Representation", None)
    if rep is None:
        return None
    reps = [r for r in rep.Representations if r.RepresentationIdentifier == "Body"] or list(rep.Representations)
    parts = []
    for r in reps:
        for it in r.Items:
            if it.is_a("IfcMappedItem"):
                parts.append(f"map:{it.MappingSource.id()}:{_structural_fingerprint(model, it.MappingTarget)}")
            else:
                parts.append(_structural_fingerprint(model, it))
    return "|".join(sorted(parts)) if parts else None


def _duplicate_index(model):
    key = id(model)
    if key not in _duplicate_cache:
        scale = _unit_scale(model)
        index = defaultdict(list)
        for e in model.by_type("IfcElement"):
            if e.is_a("IfcFeatureElement") or e.is_a("IfcVirtualElement"):
                continue
            m = _absolute_matrix(getattr(e, "ObjectPlacement", None))
            fp = _body_fingerprint(model, e)
            if m is None or fp is None:
                continue
            mkey = tuple(round(float(m[i][j]) * (scale if j == 3 else 1.0), 3) for i in range(3) for j in range(4))
            index[(e.is_a(), mkey, fp)].append(e)
        _duplicate_cache[key] = {e.id(): group for group in index.values() if len(group) > 1 for e in group}
    return _duplicate_cache[key]


@gherkin_ifc.step("It must not duplicate another element with the same class, absolute placement and body geometry")
def step_impl(context, inst):
    group = _duplicate_index(context.model).get(inst.id())
    if group:
        yield _fail(inst, "a unique element", [e for e in group if e.id() != inst.id()])
    else:
        yield _pass(inst)
