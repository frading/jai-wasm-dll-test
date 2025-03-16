This is a test repo to understand how to compile and link a DLL or shared library for wasm.

# Compile for native

First, we check that things work in native. This has been tested on linux only for now.

- Build the DLL: `cd dll && jai build.jai`
- Build the executable: `cd main_program && jai build.jai`

This outputs `main_program/main_native`, which prints out the following

```
compute:15
OK
```

# Compile for wasm

If the dll can be compiled and linked natively, we can now try for wasm:

- Build the DLL: `cd dll && jai build.jai - wasm`
- Build the executable: `cd main_program && jai build.jai - wasm`

This currently gives this error:

`lld-linux: error: duplicate symbol: __procedure_1b00000001`

It is worth noting that if the DLL **for native** is built with `.STATIC_LIBRARY` instead of `.DYNAMIC_LIBRARY`, and linked with `Custom_DLL :: #library,no_dll "native/custom_dll";`, we get the same error. This may mean that something is incorrect in this setup.