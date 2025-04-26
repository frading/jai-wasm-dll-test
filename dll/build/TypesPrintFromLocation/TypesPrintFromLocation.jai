

bindingsExportHandleMessage :: (using info: *BindingsExportInfo, message: *Message_Typechecked){

    builder :String_Builder;

    for st:message.structs {
        codeStruct:*Code_Struct=st.expression;
        structName := codeStruct.defined_type.name;
        if table_contains(*foundStructs, structName){
            assert(false, tprint("% already added to foundStructs", structName));
        }
        if array_find(IGNORED_STRUCT_NAMES, structName) {
            return;
        }
        if array_find(TYPES_TO_EXPORT, structName) {
            printGreen(tprint("+ add struct: %", structName));
            table_add(*foundStructs, structName, *st);

        }
        // printStruct(*builder, *st);
    }

    for declaration: message.declarations {
        codeDeclaration :*Code_Declaration= declaration.expression;
        if codeDeclaration.flags & .PROGRAM_EXPORT {
            codeNode :*Code_Node= codeDeclaration.expression;
            if codeNode.kind == .PROCEDURE_HEADER {

                procedureName := codeDeclaration.program_export_name;
                if array_find(IGNORED_PROCEDURE_NAMES, procedureName) {
                    continue;
                }

                printGreen(tprint("+ add procedure: %", procedureName));
                array_add(*exportedProcedures, *declaration);

                if procedureName == "compute" {
                    codeDeclaration :*Code_Declaration= declaration.expression;
                    procedureName := codeDeclaration.program_export_name;
                    codeNode :*Code_Node= codeDeclaration.expression;
                    assert(codeNode.kind == .PROCEDURE_HEADER, "codeNode should .kind == .PROCEDURE_HEADER");
                    codeProcedureHeader := cast(*Code_Procedure_Header)codeNode;
                    returns:[]*Code_Declaration = codeProcedureHeader.returns;
                    print("returns:%\n", returns);
                    for ret,i:returns {
                        print("%:%,%.\n", i, ret.kind, ret.name);
                        if ret.type_inst {
                            print("- type_inst:%\n", ret.type_inst.kind);
                            print("- type_inst.result:%\n", ret.type_inst.result.type);
                            if ret.type_inst.result.type == {
                                case .VARIANT; {
                                    typeInfoVariant := cast(*Type_Info_Variant)ret.type_inst.result;
                                    print("typeInfoVariant:%\n", typeInfoVariant.name);
                                }
                            }
                            // print("- type_inst.type_valued_expression:%\n", ret.type_inst.type_valued_expression.location.l0);
                        }
                        if ret.expression {
                            print("- expression:%\n", ret.expression.kind);
                        }
                    }
                }
            }
        } else {
            codeNode :*Code_Node= declaration.expression;
            if codeNode.location.enclosing_load != null {
                if contains(codeNode.location.enclosing_load.fully_pathed_filename, "main_03.jai") {
                    print("from declarations: %=%\n", codeNode.kind, codeNode.location.l0);
                }
                // if codeDeclaration.expression.kind == .LITERAL {
                //     builder:String_Builder;
                //     location := declarationLocation_Code_Declaration(codeDeclaration);
                //     locationToBuilder(*builder, location);
                //     result := builder_to_string(*builder);
                //     print("res:%\n", result);
                // }
            }
            // if codeDeclaration.type_inst && codeDeclaration.expression {
            //     codeNode :*Code_Node= codeDeclaration.expression;
            //     print("from declarations: %=%\n", codeDeclaration.type_inst.kind, codeDeclaration.expression.kind);
            //     // if codeDeclaration.expression.kind == .LITERAL {
            //     //     builder:String_Builder;
            //     //     location := declarationLocation_Code_Declaration(codeDeclaration);
            //     //     locationToBuilder(*builder, location);
            //     //     result := builder_to_string(*builder);
            //     //     print("res:%\n", result);
            //     // }
            // }
            // we currently assume that types to be exported in the dll bindings are constant.
            // isConstant := (codeDeclaration.flags & .IS_CONSTANT) != 0;
            // isScopeFile := (codeDeclaration.flags & .SCOPE_FILE) != 0;
            // // if isConstant && !isScopeFile {
            //     codeNode :*Code_Node= codeDeclaration.expression;
            //     // if codeNode.kind != .PROCEDURE_HEADER && codeNode.location.enclosing_load != null {
            //         print("codeNode.kind:%\n", codeNode.kind);
            //         if codeNode.kind == .LITERAL {
            //             codeTypeDefinition := cast(*Code_Type_Definition) codeNode;
            //             print("loc:%,%\n", codeTypeDefinition.location.l0, codeTypeDefinition.location.c0);
            //         }
            //     // }
            // // }
        }
    }
    for other: message.all {
        codeNode :*Code_Node= other.expression;
        if codeNode.location.enclosing_load != null {
            if contains(codeNode.location.enclosing_load.fully_pathed_filename, "main_03.jai") {
                print("from all: %=%\n", codeNode.kind, codeNode.location.l0);
            }
            // if codeDeclaration.expression.kind == .LITERAL {
            //     builder:String_Builder;
            //     location := declarationLocation_Code_Declaration(codeDeclaration);
            //     locationToBuilder(*builder, location);
            //     result := builder_to_string(*builder);
            //     print("res:%\n", result);
            // }
        }
        // subCodeNodes :[] *Code_Node= other.subexpressions;
        // for subCodeNode: subCodeNodes {
        //     if subCodeNode.location.enclosing_load != null {
        //         if contains(subCodeNode.location.enclosing_load.fully_pathed_filename, "main_03.jai") {
        //             print("from all (sub): %=%\n", subCodeNode.kind, subCodeNode.location.l0);
        //         }
        //     }
        // }
    }

    // content := builder_to_string(*builder);
    // if content.count > 0 {
    //     print("--------------\n");
    //     print("%\n", content);
    //     print("--------------\n");
    // }
}

bindingsExportWriteFile :: (using info: *BindingsExportInfo, path: string) -> bool {
    builder: String_Builder;
    append(*builder, HEADER);

    printBlue(tprint("----------- % exportedProcedures", exportedProcedures.count));

    for foundStruct: foundStructs {
        printStruct(*builder, foundStruct);
    }

    for declaration:exportedProcedures {
        codeDeclaration :*Code_Declaration= declaration.expression;
        procedureName := codeDeclaration.program_export_name;
        codeNode :*Code_Node= codeDeclaration.expression;
        assert(codeNode.kind == .PROCEDURE_HEADER, "codeNode should .kind == .PROCEDURE_HEADER");
        codeProcedureHeader := cast(*Code_Procedure_Header)codeNode;

        print("procedureName:%.\n", procedureName);
        location := declarationLocation_Code_Procedure_Header(declaration, codeProcedureHeader);
        // location := declarationLocation_Any(declaration);
        // print_to_builder(*builder, "% ::", procedureName);
        locationToBuilder(*builder, location);
        append(*builder, " #foreign;\n");
    }

    // print("----------- collection completed (% ordered_types)\n", exportedTypes.count);
    // for typeName, type: exportedTypes {
    //     if type.type == {
    //         case .STRUCT; { st := cast(*Type_Info_Struct) type; print("- %:%,%\n", typeName, type.type, st.name); }
    //         case; { print("- %:%\n", typeName, type.type); }
    //     }
    // }
    // print("--------------------------------------------------\n");
    // // return true;


    // for typeName, type: exportedTypes {
    //     // name, found := table_find(*exportedTypes, type);
    //     // assert(found);
    //     printGreen(tprint("exporting %", typeName));
    //     if type.type == {
    //         case .ENUM;   export_Enum(info, *builder, cast(*Type_Info_Enum) type, typeName);
    //         case .STRUCT; export_Struct(info, *builder, cast(*Type_Info_Struct) type, typeName);
    //         case;         export_Type(info, *builder, type, typeName, exportingMember=false, parentTypeInfo=type, depth=0);
    //     }
    //     append(*builder, "\n");
    // }
    // append(*builder, "\n");

    append(*builder, FOOTER);
    result := write_entire_file(path, *builder);
    print("\nfile written: %\n\n", path);
    return result;
}


#scope_file


printStruct :: (builder:*String_Builder, st: *Typechecked(Code_Struct)) {
    structName := st.expression.defined_type.name;
    // if array_find(IGNORED_STRUCT_NAMES, structName) {
    //     return;
    // }
    print("name: %\n", structName);
    location := declarationLocation_Code_Struct(st);
    print_to_builder(builder, "% ::", structName);
    locationToBuilder(builder, location);
    append(builder, #char "\n");
}

