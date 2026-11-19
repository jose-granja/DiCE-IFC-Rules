| File name | Expected result | Description |
| --- | --- | --- |
| pass-dce001-named_storey_and_space.ifc | pass | The storey is named "Level 1", the space "Room 101". |
| fail-dce001-scenario01-storey_without_name.ifc | fail | The storey's Name is unset (`$`). |
| fail-dce001-scenario02-space_with_blank_name.ifc | fail | The space's Name is an empty string (`''`). |
