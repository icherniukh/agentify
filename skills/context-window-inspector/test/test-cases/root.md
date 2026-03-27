# Root Test File

Testing transitive @-include chain detection.

@level1.md

## Root Content

This is the root file that starts the transitive inclusion.

The inspector should trace through:
- root.md → level1.md → level2.md → level3.md

And report cumulative character count across all four files.

Character count: about 250 chars here at root level.