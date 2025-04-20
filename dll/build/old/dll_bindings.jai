// generate_bindings_from_jai_dll :: ( ) {
//     output_filename: string;
//     opts: Generate_Bindings_Options;
//     {
//         using opts;

//         // #if OS == .WINDOWS {
//         //     output_filename          = "windows.jai";
//         //     strip_flags = 0;
//         // } else #if OS == .LINUX {
//             output_filename          = "linux_generated.jai";
//             // strip_flags = .INLINED_FUNCTIONS; // Inlined constructor doesn't exist in the library
//         // } else #if OS == .MACOS {
//         //     output_filename          = "macos.jai";
//         //     strip_flags = .INLINED_FUNCTIONS; // Inlined constructor doesn't exist in the library
//         // } else {
//         //     assert(false);
//         // }

//         array_add(*libpaths,       "../main_program/modules/Custom_DLL/native");
//         array_add(*libnames,      "custom_dll");
//         array_add(*source_files,  "../main_program/modules/Custom_DLL/native/custom_dll.h");
//         array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");
//         visitor = visit_declaration;
//         // strip_flags &= ~(Strip_Flags.CONSTRUCTORS | .DESTRUCTORS);
//     }

//     generate_bindings(opts, output_filename);
// }

// visit_declaration :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
//     print("decl: %\n", decl);

//     return .RECURSE;
// }