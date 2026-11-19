# Custom steps

Most rules need no Python: buildingSMART's step phrases (see the main README) cover
selecting entities, following relationships, and checking attributes and values.

When a check cannot be written with them, add a module here, e.g. `dice_steps.py`.
DiCE-IFC loads every `.py` file in this folder after buildingSMART's steps, as the
package `dice_custom_steps`, so:

- import buildingSMART's helpers the way their steps do:

  ```python
  from validation_handling import gherkin_ifc
  from validation_results import ValidationOutcome, OutcomeSeverity, ValidationOutcomeCode
  ```

- import your own modules relatively (`from . import helpers`);
- start every phrase with words of your own (e.g. "DiCE: …"). A phrase that matches
  one of buildingSMART's makes behave stop with an *ambiguous step* error, and then
  no rule runs;
- use only the Python standard library and the packages the validator ships
  (ifcopenshell, numpy, shapely, networkx, pydantic, pyparsing, pyyaml, mpmath,
  python-dateutil, lark, parse). Anything else is not in the browser.

A minimal `Then` step:

```python
from validation_handling import gherkin_ifc
from validation_results import ValidationOutcome, OutcomeSeverity, ValidationOutcomeCode


@gherkin_ifc.step("DiCE: its name must start with '{prefix}'")
def step_impl(context, inst, prefix):
    if not (inst.Name or "").startswith(prefix):
        yield ValidationOutcome(inst=inst, expected=f"a name starting with {prefix}",
                                observed=inst.Name, severity=OutcomeSeverity.ERROR)
```
