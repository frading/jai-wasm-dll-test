

BindingsExportInfo :: struct {
    // prefix_enum_values:   bool;
    exportedProcedures:  [..] *Typechecked(Code_Declaration);
    exportedTypes:       Table(*Type_Info, string);
    internalTypes:       Table(*Type_Info, TypeInfoList);
    // name_types:           Table(string, *Type_Info);
    // ordered_types:        [..] *Type_Info;

    type_resizable_array: *Type_Info;
    type_array_view_8:    *Type_Info;
    type_array_view_16:   *Type_Info;
    type_array_view_32:   *Type_Info;
    type_array_view_64:   *Type_Info;
    type_type_info:       *Type_Info;
    type_newstring:       *Type_Info;
    type_any:             *Type_Info;
}

INDENT :: #char "\t";

bindingsExportHandleMessage :: (using info: *BindingsExportInfo, message: *Message) {
    if message.kind == .TYPECHECKED {
        typechecked := cast (*Message_Typechecked) message;
        for declaration: typechecked.declarations {
            decl := declaration.expression;
            // print("decl:%\n", decl.name);
            if decl.expression && decl.expression.kind == .STRUCT {
                _struct := cast(*Code_Struct) decl.expression;
                if decl.name == "Resizable_Array" type_resizable_array = _struct.defined_type;
                if decl.name == "Array_View_8"    type_array_view_8 = _struct.defined_type;
                if decl.name == "Array_View_16"   type_array_view_16 = _struct.defined_type;
                if decl.name == "Array_View_32"   type_array_view_32 = _struct.defined_type;
                if decl.name == "Array_View_64"   type_array_view_64 = _struct.defined_type;
                if decl.name == "Type_Info"       type_type_info = _struct.defined_type;
                if decl.name == "Newstring"       type_newstring = _struct.defined_type;
                if decl.name == "Any_Struct"      type_any = _struct.defined_type;
            }

            if decl.flags & .PROGRAM_EXPORT {
                if decl.expression.kind == .PROCEDURE_HEADER {
                    // Don’t export main
                    if     decl.program_export_name == "main"
                        || decl.program_export_name == "__jai_runtime_fini"
                        || decl.program_export_name == "__jai_runtime_init" {
                        continue;
                    }
                    printGreen(tprint("+ add procedure: %", decl.program_export_name));
                    array_add(*exportedProcedures, *declaration);
                }
            }
        }
    }
}

bindingsExportWriteFile :: (using info: *BindingsExportInfo, path: string) -> bool {
    builder: String_Builder;
    append(*builder, HEADER);

    printBlue(tprint("----------- % exportedProcedures", exportedProcedures.count));
    for declaration:exportedProcedures {
        for subexp,i: declaration.subexpressions {
            traverseCodeNode(subexp);
        }
        collectExportedTypes(info, declaration.expression.type, declaration);
    }

    print("----------- collection completed (% ordered_types)\n", exportedTypes.count);
    for typeName, type: exportedTypes {
        if type.type == {
            case .STRUCT; { st := cast(*Type_Info_Struct) type; print("- %:%,%\n", typeName, type.type, st.name); }
            case; { print("- %:%\n", typeName, type.type); }
        }
    }
    print("--------------------------------------------------\n");
    // return true;


    for typeName, type: exportedTypes {
        // name, found := table_find(*exportedTypes, type);
        // assert(found);
        printGreen(tprint("exporting %", typeName));
        if type.type == {
            case .ENUM;   export_Enum(info, *builder, cast(*Type_Info_Enum) type, typeName);
            case .STRUCT; export_Struct(info, *builder, cast(*Type_Info_Struct) type, typeName);
            case;         export_Type(info, *builder, type, typeName, exportingMember=false, parentTypeInfo=type, depth=0);
        }
        append(*builder, "\n");
    }
    append(*builder, "\n");

    result := write_entire_file(path, *builder);
    print("file written: %\n", path);
    return result;
}

#scope_file




