#if OS == .WASM {
    #load "wasm.jai";
} else {
    #load "native.jai";
}