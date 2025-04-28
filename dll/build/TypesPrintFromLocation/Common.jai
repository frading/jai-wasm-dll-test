BindingsExportInfo :: struct {
    exportedProcedures:  [..] *Typechecked(Code_Declaration);
    foundConstants: Table(string, *Typechecked(Code_Declaration));
    foundEnums: Table(string, *Typechecked(Code_Declaration));
    foundProcedures: Table(string, *Typechecked(Code_Declaration));
    foundTypes: Table(string, *Typechecked(Code_Declaration));
    foundStructs: Table(string, *Typechecked(Code_Struct));
}

// same as Location inside Compiler.jai
CustomLocation :: struct {
    enclosing_load:         *Message_File;

    l0, c0, l1, c1: s32;
}

HEADER :: #string END
// auto generated
END

FOOTER :: #string END
// end
END

ALREADY_DEFINED_TYPE_NAMES :: string.[
    "string",
    "Type_Info"
];

IGNORED_PROCEDURE_NAMES :: string.[
    "main",
    "__jai_runtime_fini",
    "__jai_runtime_init"
];

IGNORED_STRUCT_NAMES :: string.[
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


