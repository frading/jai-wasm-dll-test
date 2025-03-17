// -1. with DLL built with .DYNAMIC_LIBRARY:
// Custom_DLL :: #library "wasm/custom_dll";
// compute_num :: () -> u32 #elsewhere Custom_DLL;

// -2. with DLL built with .STATIC_LIBRARY:
compute_num :: () -> u32 #elsewhere Custom_DLL;
#scope_file
Custom_DLL :: #library "wasm/custom_dll";


// -3. with DLL built with .OBJECT_FILE:
// we don't declare which library this comes from here, but we add it in additional_linker_arguments, the same was as walloc
// compute_num :: () -> u32  #foreign "compute_num";


