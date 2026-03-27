# File B

This file includes File A (circular reference).

@file-a.md

## Content in File B

More content here to test circular inclusion detection.

If the inspector is smart, it should detect the circular reference and not enter infinite loop.

Estimate: similar character count to File A.