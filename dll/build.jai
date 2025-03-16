// native:
// rm -f ../main_program/modules/dll/native/* && jai build.jai

#run {
    set_build_options_dc(.{do_output=false});  // No executable for this workspace.

    build_lib();
}

build_lib :: () {
    w := compiler_create_workspace();
    options := get_build_options(w);

    args := options.compile_time_command_line;
	wasm := array_find(args, "wasm");

    copy_commonly_propagated_fields(get_build_options(), *options);

    if wasm {
        print("BUILDING FOR WASM\n");
        options.output_path = "../main_program/modules/Custom_DLL/wasm";
        options.output_type            = .OBJECT_FILE;

        //
        options.backend                             = .LLVM;
        options.os_target                           = .WASM;
        options.cpu_target                          = .CUSTOM;
        options.emit_debug_info                     = .DWARF;
        options.backtrace_on_crash                  = .OFF; // Runtime_Support_Crash_Handler doesn’t support WASM (yet?)
        // // options.output_path                         = "public/";
        // // options.output_executable_name              = "main";
        options.llvm_options.target_system_features = "+bulk-memory"; // "This options is needed so that "memcpy" and "memset" are mapped to "memory.copy" and "memory.fill" instructions in WASM.
        options.llvm_options.enable_split_modules   = false;
        options.llvm_options.function_sections      = true; // To get around "LLVM ERROR: section already has a defining function: .text"

        import_paths: [..]string;
        // Add our own modules folder first so that we can override modules with our own version, if necessary.
        array_add(*import_paths, tprint("%modules", #filepath));
        for options.import_path array_add(*import_paths, it);
        options.import_path = import_paths;

        // This was compiled from https://github.com/wingo/walloc via "clang -Oz --target=wasm64 -nostdlib -c -o walloc.o walloc.c".
        // We should probably port this allocator to Jai instead…
        //  -rluba, 2023-11-15
        walloc_object_file_path := "modules/walloc/walloc.o";

        STACK_SIZE :: 24 * 1024;
        options.additional_linker_arguments = .[
            "--stack-first",
            "-z",
            tprint("stack-size=%", STACK_SIZE),
            walloc_object_file_path
        ];


        // Replace the default allocator with Walloc (https://github.com/wingo/walloc).
        remap_import(w, "*", "Default_Allocator", "Walloc");
    } else {
        print("BUILDING FOR NATIVE\n");
        options.output_type = .DYNAMIC_LIBRARY;
        options.output_path = "../main_program/modules/Custom_DLL/native";
    }

    make_directory_if_it_does_not_exist(options.output_path);
    options.output_executable_name = "custom_dll";
    set_optimization(*options, .OPTIMIZED);
    options.runtime_support_definitions = .OMIT;
    options.dead_code_elimination = .ALL;

    set_build_options(options, w);


    // compiler_begin_intercept(w);

    add_build_file("main_dll.jai", w);

    // while true {
    //     message := compiler_wait_for_message();
    //     if message.kind == .COMPLETE {
    //         mc := cast(*Message_Complete) message;
    //         if mc.error_code != .NONE {
    //             print("DLL compilation failed; exiting without compiling the main program.\n");
    //             return;
    //         }

    //         break;
    //     } else if message.kind == .TYPECHECKED {

    //         tc_message := cast(*Message_Typechecked) message;
    //         print_program_exports(tc_message);

    //     }
    // }

    // compiler_end_intercept(w);
}

// print_program_exports :: (tc_message:*Message_Typechecked) {
//     builder:String_Builder;
    
//     // for procedure_header: tc_message.procedure_headers {
//     //     print_procedure_header(*builder, procedure_header.expression);
//     // }
//     for tc: tc_message.all {
//         for subexpression: tc.subexpressions {
//             if subexpression.kind == .DECLARATION {
//                 sub_decl := cast(*Code_Declaration) subexpression;
//                 if sub_decl.flags & .PROGRAM_EXPORT {
//                     // print(" - %,%,%,%\n", sub_decl.kind, sub_decl.program_export_name);
//                     sub_builder:String_Builder;
//                     print_declaration(*sub_builder, sub_decl);
//                     result := builder_to_string(*sub_builder);
//                     lines := split(result, "\n");
//                     main_line := lines[1];
//                     if main_line[0] != #char "_" {
//                         function_decl := replace(main_line, "{", " #elsewhere Polygon_Runtime;\n");
//                         print_to_builder(*builder, function_decl);
//                         // print("lines:%\n", function_decl);
//                     }
//                     // print_expression(*builder, sub_decl.expression);
//                 }
//             }
//         }
//     }

//     // filename := ""
//     // file, success := file_open(filename, true, false, true);
//     // if !success {
//     //     log_error("In Simple_Package, unable to open '%' for writing!\n", filename);
//     //     return false;
//     // }

//     // defer file_close(*file);

//     // success = file_write(*file, *header);

//     result := builder_to_string(*builder);
//     print("%\n", result);
// }


#import "Basic";
#import "Compiler";
#import "File";
#import "Program_Print";
#import "String";
