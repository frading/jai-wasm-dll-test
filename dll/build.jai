
#run {
    set_build_options_dc(.{do_output=false});  // No executable for this workspace.

    w := compiler_create_workspace();
    options := get_build_options(w);

    args := options.compile_time_command_line;
	wasm := array_find(args, "wasm");
    if(wasm) {
        build_lib(wasm=true, dynamic=true);
        build_lib(wasm=true, dynamic=false);
    } else {
        build_lib(wasm=false, dynamic=true);
        build_lib(wasm=false, dynamic=false);
    }
}

build_lib :: (wasm:bool, dynamic:bool) {
    w := compiler_create_workspace();
    options := get_build_options(w);

    copy_commonly_propagated_fields(get_build_options(), *options);

    if wasm {
        print("BUILDING FOR WASM (%)\n", ifx dynamic then "dynamic" else "static");
        options.output_path = "../main_program/modules/Custom_DLL/wasm";
        // options.output_type = .DYNAMIC_LIBRARY;
        // options.output_type = .STATIC_LIBRARY;
        // options.output_type = .OBJECT_FILE;

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
        walloc_object_file_path := "modules/Walloc/walloc.o";

        if dynamic {
            // STACK_SIZE :: 24 * 1024;
            options.additional_linker_arguments = .[
                // "--stack-first",
                // "-z",
                // tprint("stack-size=%", STACK_SIZE),
                walloc_object_file_path
            ];
        } else {
            options.additional_linker_arguments = .[
                // "--stack-first",
                // "-z",
                // tprint("stack-size=%", STACK_SIZE),
                walloc_object_file_path
            ];
        }


        // Replace the default allocator with Walloc (https://github.com/wingo/walloc).
        remap_import(w, "*", "Default_Allocator", "Walloc");
    } else {
        print("BUILDING FOR NATIVE\n");
        options.output_path = "../main_program/modules/Custom_DLL/native";
    }
    if dynamic {
        options.output_type = .DYNAMIC_LIBRARY;
    } else {
        options.output_type = .STATIC_LIBRARY;
        options.runtime_support_definitions = .OMIT;
        options.dead_code_elimination = .ALL;
    }

    make_directory_if_it_does_not_exist(options.output_path);
    print("file generated in folder: %.\n", options.output_path);
    options.output_executable_name = "custom_dll";
    set_optimization(*options, .OPTIMIZED);

    set_build_options(*options, w);

    compiler_begin_intercept(w);

    add_build_file("main_dll.jai", w);

    // ensure we compile 1 target at a time
    while true {
        message := compiler_wait_for_message();
        if message.kind == .COMPLETE {
            mc := cast(*Message_Complete) message;
            if mc.error_code != .NONE {
                print("DLL compilation failed; exiting without compiling the main program.\n");
                return;
            }

            break;
        }
    }
    compiler_end_intercept(w);

    if wasm {
        src := tprint("%/%.wasm", options.output_path,  options.output_executable_name);
        ext :string= ifx dynamic then "so" else "a";
        dest := tprint("%/%.%", options.output_path,  options.output_executable_name, ext);
        cmd_mv := tprint("mv % %", src, dest);
	    print("%\n", cmd_mv);
        success := true;
		run_result := run_command(..split(cmd_mv, " "));
        success &&= (run_result.exit_code == 0);
		if success==false {
            print("ERROR running mv cmd\n");
            return;
        }
    }
}



#import "Basic";
#import "Compiler";
#import "File";
#import "Process";
#import "Program_Print";
#import "String";
