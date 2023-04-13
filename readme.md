# Library for Foundry/forge tests
See examples in tests

## Helpers
### Gas helper
to mesuring gas

### Random helper
to get a random number
requirements : ffi=true

### Storage helper
to retrieve values in storage

### String helper
Some useful functions

### Test helper
other useful function for tests

## Recorders
### Var recorder
to record some data (like counter) a file during tests.
Useful to initialize a fuzz test.

`if (!_isVarExist(counterName)) {` ... initialize fuzz test `}`

### Fuzz recorder
to record data (like logs) in a file during same test.

## Libraries

### Arrays library
### Bits library