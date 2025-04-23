BindingsExportInfo :: struct {
   
}

bindingsExportHandleMessage :: (using info: *BindingsExportInfo, message: *Message_Typechecked){

    builder :String_Builder;

    for st:message.structs {
        printStruct(*builder, *st);
    }

    content := builder_to_string(*builder);
    if content.count > 0 {
        print("--------------\n");
        print("%\n", content);
        print("--------------\n");
    }
}

bindingsExportWriteFile :: (using info: *BindingsExportInfo, path: string) -> bool {
    print("bindingsExportWriteFile not implemented yet\n");
    return true;
}


#scope_file


printStruct :: (builder:*String_Builder, st: *Typechecked(Code_Struct)) {
    structName := st.expression.defined_type.name;
    if array_find(IGNORED_NAMES, structName) {
        return;
    }
    print("name: %\n", structName);
    location := declarationLocation(st);
    print_to_builder(builder, "% ::", structName);
    locationToBuilder(builder, location);
}

locationToBuilder :: (builder:*String_Builder, location:CustomLocation) {
    filePath := location.enclosing_load.fully_pathed_filename;
    file_content, success := read_entire_file(filePath);

    lineIndex := 1;
    startLineIndex := -1;
    print("location.l0: %\n", location.l0);
    print("location.l1: %\n", location.l1);
    print("location.c0: %\n", location.c0);
    print("location.c1: %\n", location.c1);
    while lineIndex < location.l0 {
        startLineIndex = find_index_from_left(file_content, #char "\n", startLineIndex+1);
        lineIndex += 1;
    }
    print("startLineIndex: %\n", startLineIndex);
    endLineIndex := startLineIndex;
    while lineIndex < location.l1 {
        endLineIndex = find_index_from_left(file_content, #char "\n", endLineIndex+1);
        lineIndex += 1;
    }
    print("endLineIndex: %\n", endLineIndex);
    startIndex := startLineIndex+location.c0;
    endIndex := endLineIndex+location.c1;
    locationContent := slice(file_content, startIndex-1, endIndex-startIndex+2);
    append(builder, locationContent);
    append(builder, #char "\n");
}

declarationLocation :: (node:*$T)->CustomLocation {
    location := node.expression.location;
    subexpressions := node.subexpressions;
    maxL1 :s32= location.l1;
    for subexpression: subexpressions {
        if subexpression.location.l1 > maxL1 {
            maxL1 = subexpression.location.l1;
        }
    }
    maxC1 :s32= 0;
    for subexpression: subexpressions {
        if subexpression.location.l1 == maxL1 {
            if subexpression.location.c1 > maxC1 {
                maxC1 = subexpression.location.c1;
            }
        }
    }

    return CustomLocation.{
        enclosing_load = location.enclosing_load,
        l0 = location.l0,
        c0 = location.c0,
        l1 = maxL1,
        c1 = maxC1
    };
}

// same as Location inside Compiler.jai
CustomLocation :: struct {
    enclosing_load:         *Message_File;

    l0, c0, l1, c1: s32;
}

IGNORED_NAMES :: string.[
    "Context0",
    "Context_Base",
    "Span",
    "Heap",
    "Heap_Statistics",
    "Global_Statistics",
    "Size_Class",
    "Heap_Size_Class",
    "Temporary_Storage",
    "Overflow_Page",
    "Resizable_Array",
    "Allocator",
    "Type_Info_Array",
    "Type_Info_Struct_Member",
    "Type_Info_Procedure",
    "Log_Info",
    "Type_Info_Variant",
    "Type_Info_Enum",
    "Type_Info_Struct",
    "Type_Info_Pointer",
    "Type_Info_String",
    "Type_Info_Float",
    "Type_Info_Integer",
    "Type_Info",
    "Stack_Trace_Procedure_Info",
    "Array_View_64",
    "Newstring",
    "Procedure_With_Data",
    "Source_Code_Range",
    "Source_Code_Location",
    "Stack_Trace_Node",
    "Log_Section",
    "Any_Struct"
];
