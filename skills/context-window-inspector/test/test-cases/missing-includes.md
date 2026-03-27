# Test Missing Includes

This file references several non-existent files to test staleness detection.

@non-existent-1.md
@missing-file.md  
@deprecated-guide.md
@old-conventions.md

## Pattern variations

Also test different patterns:
- @file-with-dashes.md
- @file_with_underscores.md
- @file.with.dots.md
- @FileWithCaps.md (should this work? test it)

The inspector should:
1. Detect all missing files
2. Report each missing file separately
3. Estimate wasted tokens (chars that would be added if files existed)
4. Suggest removing the @-include lines

End of test.