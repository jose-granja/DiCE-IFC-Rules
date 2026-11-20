# DiCE-IFC-Rules

Validation rules for IFC models, written for the DiCE-IFC viewer.
They run in the browser next to buildingSMART's validation service rules, as a
stage of their own, **DiCE rules**, after buildingSMART's industry practices.

The rules use the same format as buildingSMART's
[ifc-gherkin-rules](https://github.com/buildingSMART/ifc-gherkin-rules): Gherkin
`.feature` files run by [behave](https://behave.readthedocs.io/), with
buildingSMART's step phrases. A rule written here could be proposed to
buildingSMART as it is.

## The rules

| Code | Rule | A finding is | Formerly |
| --- | --- | --- | --- |
| [DiCE001](features/rules/DiCE/DiCE001_Named-storeys-and-spaces.feature) | Named storeys and spaces | error | |
| [DiCE002](features/rules/DiCE/DiCE002_Parcel-and-surroundings-spatial-structure.feature) | Parcel and surroundings spatial structure | error | |
| [DiCE003](features/rules/DiCE/DiCE003_Doors-and-windows-fill-an-opening.feature) | Doors and windows fill an opening | warning | BLT901 |
| [DiCE004](features/rules/DiCE/DiCE004_No-duplicated-elements.feature) | No duplicated elements | warning | BLT902 |
| [DiCE005](features/rules/DiCE/DiCE005_Model-geometry-close-to-the-origin.feature) | Model geometry close to the origin | warning | GRF901 |
| [DiCE006](features/rules/DiCE/DiCE006_True-north-consistent-with-map-conversion.feature) | True north consistent with map conversion | warning | GRF902 |
| [DiCE007](features/rules/DiCE/DiCE007_Material-set-usage-on-occurrences.feature) | Material set usage on occurrences | warning | MAT901 |
| [DiCE008](features/rules/DiCE/DiCE008_Built-elements-have-a-material.feature) | Built elements have a material | warning | MAT902 |
| [DiCE009](features/rules/DiCE/DiCE009_Described-proxy-elements.feature) | Described proxy elements | warning | OJT901 |
| [DiCE010](features/rules/DiCE/DiCE010_Limited-use-of-proxy-elements.feature) | Limited use of proxy elements | warning | OJT902 |
| [DiCE011](features/rules/DiCE/DiCE011_Predefined-type-on-untyped-occurrences.feature) | Predefined type on untyped occurrences | warning | OJT903 |
| [DiCE012](features/rules/DiCE/DiCE012_Declared-project-units.feature) | Declared project units | warning | PJS901 |
| [DiCE013](features/rules/DiCE/DiCE013_Plausible-length-unit.feature) | Plausible length unit | warning | PJS902 |
| [DiCE014](features/rules/DiCE/DiCE014_Boolean-values-not-written-as-text.feature) | Boolean values not written as text | warning | PSE901 |
| [DiCE015](features/rules/DiCE/DiCE015_Measures-not-written-as-text.feature) | Measures not written as text | warning | PSE902 |
| [DiCE016](features/rules/DiCE/DiCE016_Quantities-greater-than-zero.feature) | Quantities greater than zero | warning | QTY901 |
| [DiCE017](features/rules/DiCE/DiCE017_Quantities-not-stored-as-properties.feature) | Quantities not stored as properties | warning | QTY902 |
| [DiCE018](features/rules/DiCE/DiCE018_Storey-elevation-consistent-with-placement.feature) | Storey elevation consistent with placement | warning | SPS901 |
| [DiCE019](features/rules/DiCE/DiCE019_Unique-storey-names.feature) | Unique storey names | warning | SPS902 |
| [DiCE020](features/rules/DiCE/DiCE020_Building-elements-contained-in-storeys.feature) | Building elements contained in storeys | warning | SPS903 |
| [DiCE021](features/rules/DiCE/DiCE021_No-empty-storeys.feature) | No empty storeys | warning | SPS904 |

DiCE003 to DiCE021 come from an earlier rule set that used buildingSMART's
prefixes with 9xx numbers. They were renumbered because the app's build refuses
buildingSMART's prefixes. Their Python steps are in
[features/steps/good_practice.py](features/steps/good_practice.py).

## Layout

```
features/rules/<PREFIX>/<CODE>_<Title>.feature   one file per rule
features/steps/*.py                              Python steps, only if needed (see features/steps/README.md)
test/files/<PREFIX>/<code>/                       pass-… and fail-… IFC files for each rule
```

Only `features/` is shipped to the app. `test/` stays here.

## Writing a rule

```gherkin
@DiCE
@version1
Feature: DiCE001 - Named storeys and spaces

The rule verifies that each building storey and each space has a name, …

  Scenario: Each building storey has a name

    Given An .IfcBuildingStorey.
    Then .Name. ^is not^ empty
```

- **Code.** The feature name is `CODE - Title`, e.g. `DiCE001 - Named storeys
  and spaces`. The app takes the rule's code from it: a prefix of letters, then
  three digits. Our prefix is `DiCE`. Never use one of buildingSMART's (ALB, GEM,
  IFC, PSE, SPS …), in any case: the app's build leaves out every rule of this
  repository, with a warning, if one uses a buildingSMART prefix, repeats a code,
  or is not named `CODE - Title`.
- **File name.** `features/rules/DiCE/DiCE001_Named-storeys-and-spaces.feature`:
  the code, then the title with hyphens. The rule's documentation link in the
  app points to this file on GitHub, at the pinned commit.
- **Description.** The lines under `Feature:` start with "The rule verifies
  that…". The app shows them with each finding, in the panel, the PDF report and
  the BCF topics.
- **Severity.** A failed check is an **error**. Tag the feature
  `@industry-practice` to make it a **warning** instead (this is how behave's
  steps decide). The tag does not move the rule into buildingSMART's stage: every
  rule in this repository runs in the DiCE rules stage.
- **Turning a rule off.** Tag it `@disabled`.
- **Schema.** Limit a rule to a schema with a background step, e.g.
  `Given A model with Schema 'IFC4' or 'IFC4.3'`.

### Step phrases

buildingSMART's phrases are documented in their repository,
[`features/steps/RULE_AUTHORING.md`](https://github.com/buildingSMART/ifc-gherkin-rules/blob/main/features/steps/RULE_AUTHORING.md).
Their rules in `features/rules/` are the best examples. Some common ones:

| Phrase | Does |
| --- | --- |
| `Given An .IfcWall.` / `Given An .IfcWall. ^with subtypes^` | selects the instances |
| `Given .PredefinedType. ^is^ 'USERDEFINED'` | keeps those with that value |
| `Given .IsTypedBy. ^is^ empty` | keeps those where it is empty |
| `Then .Name. ^is not^ empty` | checks a value is given: unset (`$`) and `''` are both empty |
| `Then The value of attribute .Name. must be ^not empty^` | the same, but `''` counts as a value |
| `Then .PredefinedType. ^is^ 'USERDEFINED'` | checks a value |
| `Then There must be at least 1 instance(s) of .IfcBuilding.` | counts instances |
| `Then It must be aggregated by IfcSite directly` | checks aggregation (`IfcRelAggregates`) |
| `Then It must be contained in IfcSite directly` | checks containment (`IfcRelContainedInSpatialStructure`) |
| `Then Its .Name. attribute ^starts^ with 'L'` | checks a prefix |
| `Given Its attribute .Name.` then `Then Its value conforms to the expression /^L\d{2}$/` | checks a pattern |

Copy phrases exactly, carets (`^is not^`) and dots (`.Name.`) included. A phrase
that matches no step is reported in the app as "no step matches …", and the rule
checks nothing.

A check that the phrases cannot express needs a Python step: see
[features/steps/README.md](features/steps/README.md).

### IDS or a rule?

A requirement such as "walls have the property `Pset_WallCommon.FireRating`"
is better written in IDS: DiCE-IFC checks IDS files directly, with no rebuild.
Write a rule here for what IDS cannot express: counts, relationships, geometry,
the file header, or anything across several entities.

## Testing a rule

For each rule, add a `pass-…` file and a `fail-…` file per scenario to
`test/files/<PREFIX>/<code>/`, and describe them in that folder's README. A file
that should not be checked by the rule at all (an IFC2X3 file for an IFC4 rule,
say) is named `na-…`.

All rules run on every file, so a test file for one rule must satisfy the others.
In particular, DiCE002 checks the spatial structure of every IFC4 model: give each
test file one `IfcSite` aggregated by the `IfcProject`, an `IfcBuilding` in the
site, and a terrain `IfcGeographicElement` contained in the site. Otherwise a
`pass-` file of another rule comes out `invalid` because of DiCE002.

With a DiCE-IFC checkout next to this one, build its validator from this
working copy, then run the files through the DiCE rules stage:

```bash
cd ../2026-DiCE-IFC/frontend
DICE_RULES_DIR=../../DiCE-IFC-Rules npm run validator:assets
for f in ../../DiCE-IFC-Rules/test/files/DiCE/dice001/*.ifc; do npm run --silent validator:check -- "$f" dice_rules; done
```

A `pass-` or `na-` file should be `valid`, and a `fail-` file `invalid` (or
`warning` for an `@industry-practice` rule), with the rule's code in the findings.

## Publishing rules to the app

The app runs exactly the commit it pins in `frontend/validator/manifest.json`
(`customRules`), checked against its SHA-256 when the app is built:

1. Push to `main` on GitHub.
2. In DiCE-IFC, pin the commit, with its full 40-character SHA:

   ```bash
   npm run validator:pin-rules -- jose-granja/DiCE-IFC-Rules <commit>
   ```

   This downloads the commit, computes its SHA-256 and writes both to the manifest.
3. `npm run validator:assets`, check a model, commit the manifest, and deploy.

Every user gets the new rules with the next deployment. The browser never
fetches rules from GitHub. Pushing a commit here changes nothing in the app
until it is pinned.

**This repository must stay public.** The app's build downloads the pinned
commit without credentials; a private repository makes it leave the DiCE rules
out. The rules are public anyway once deployed: the app sends them to the
browser.

## Licence

MIT, see [LICENSE](LICENSE). The step phrases and the engine that runs these
rules are buildingSMART's (MIT).
