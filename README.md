# DiCE-IFC-Rules

Validation rules for IFC models, written for the [DiCE-IFC](../2026-DiCE-IFC) viewer.
They run in the browser next to buildingSMART's validation service rules, as a
stage of their own, **DiCE rules**, after buildingSMART's industry practices.

The rules use the same format as buildingSMART's
[ifc-gherkin-rules](https://github.com/buildingSMART/ifc-gherkin-rules): Gherkin
`.feature` files run by [behave](https://behave.readthedocs.io/), with
buildingSMART's step phrases. A rule written here could be proposed to
buildingSMART as it is.

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

- **Code.** The feature name is `CODE - Title`. The app takes the rule's code
  from it. Codes are three capitals and three digits. Use a prefix of our own,
  `DCE`, never one of buildingSMART's (ALB, GEM, IFC, PSE, SPS …): the app's build
  refuses a rule whose prefix buildingSMART uses.
- **File name.** `features/rules/DCE/DCE001_Named-storeys-and-spaces.feature`.
  The rule's documentation link in the app points to this file on GitHub.
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
| `Then It must be assigned to the .IfcSite.` | checks aggregation |
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
`test/files/<PREFIX>/<code>/`, and describe them in that folder's README.

With a DiCE-IFC checkout next to this one, build its validator from this
working copy, then run the files through the DiCE rules stage:

```bash
cd ../2026-DiCE-IFC/frontend
DICE_RULES_DIR=../../DiCE-IFC-Rules npm run validator:assets
for f in ../../DiCE-IFC-Rules/test/files/DiCE/dice001/*.ifc; do npm run --silent validator:check -- "$f" dice_rules; done
```

A `pass-` file should be `valid` and a `fail-` file `invalid` (or `warning` for
an `@industry-practice` rule).

## Publishing rules to the app

The app runs exactly the commit it pins in `frontend/validator/manifest.json`
(`customRules`), checked against its SHA-256 when the app is built:

1. Push this repository to GitHub.
2. In DiCE-IFC: `npm run validator:pin-rules -- <owner>/DiCE-IFC-Rules <commit>`.
   This downloads the commit, computes its SHA-256 and writes both to the manifest.
3. `npm run validator:assets`, check a model, commit the manifest, and deploy.

Every user gets the new rules with the next deployment. The browser never
fetches rules from GitHub.

**The rules are public once deployed.** The app sends them to the browser, so
anyone using it can read them, even if this repository is private.

## Licence

MIT, see [LICENSE](LICENSE). The step phrases and the engine that runs these
rules are buildingSMART's (MIT).
