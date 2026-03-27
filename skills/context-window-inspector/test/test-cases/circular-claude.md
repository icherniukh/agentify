# Test Circular Includes

This CLAUDE.md file includes File A, which includes File B, which includes File A again.

@file-a.md

## Regular content

Some normal instructions here.

The inspector should:
1. Detect circular reference
2. Not enter infinite loop
3. Report the circular dependency

End of file.