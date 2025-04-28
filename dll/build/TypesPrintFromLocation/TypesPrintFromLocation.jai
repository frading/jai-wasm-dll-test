FILE_NAME::"main_04.jai";

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
        if array_find(STRUCTS_TO_EXPORT, structName) {
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

                // if procedureName == "compute" {
                //     codeDeclaration :*Code_Declaration= declaration.expression;
                //     procedureName := codeDeclaration.program_export_name;
                //     codeNode :*Code_Node= codeDeclaration.expression;
                //     assert(codeNode.kind == .PROCEDURE_HEADER, "codeNode should .kind == .PROCEDURE_HEADER");
                //     codeProcedureHeader := cast(*Code_Procedure_Header)codeNode;
                //     returns:[]*Code_Declaration = codeProcedureHeader.returns;
                //     print("returns:%\n", returns);
                //     for ret,i:returns {
                //         print("%:%,%.\n", i, ret.kind, ret.name);
                //         if ret.type_inst {
                //             print("- type_inst:%\n", ret.type_inst.kind);
                //             print("- type_inst.result:%\n", ret.type_inst.result.type);
                //             if ret.type_inst.result.type == {
                //                 case .VARIANT; {
                //                     typeInfoVariant := cast(*Type_Info_Variant)ret.type_inst.result;
                //                     print("typeInfoVariant:%\n", typeInfoVariant.name);
                //                 }
                //             }
                //             // print("- type_inst.type_valued_expression:%\n", ret.type_inst.type_valued_expression.location.l0);
                //         }
                //         if ret.expression {
                //             print("- expression:%\n", ret.expression.kind);
                //         }
                //     }
                // }
            }
        } else {
            // codeDeclaration :*Code_Node= declaration.expression;
            if codeDeclaration.location.enclosing_load != null {
                if contains(codeDeclaration.location.enclosing_load.fully_pathed_filename, FILE_NAME) {
                    if codeDeclaration.expression {
                        print("from declarations: %,%=%\n", codeDeclaration.kind, codeDeclaration.expression.kind, codeDeclaration.location.l0);
                        if codeDeclaration.expression.kind == {
                            case .ENUM; {
                                required, typeName := enumDeclarationRequired(*declaration);
                                print("ENUM:%,%\n", required, typeName);
                                if required {
                                    table_add(*foundEnums, typeName, *declaration);
                                }
                            }
                            case .LITERAL; {
                                required, typeName := typeDeclarationRequired(*declaration);
                                if required {
                                    table_add(*foundConstants, typeName, *declaration);
                                }
                            }
                            case .PROCEDURE_HEADER; {
                                required, typeName := procedureDeclarationRequired(*declaration);
                                if required {
                                    table_add(*foundProcedures, typeName, *declaration);
                                }
                            }
                            case .TYPE_INSTANTIATION; {
                                // codeTypeInst := cast(*Code_Type_Instantiation) codeDeclaration.expression;
                                // if array_find(TYPES_TO_EXPORT, codeIdent.name) {
                                    // print("codeTypeInst.pointer_to:%\n", codeTypeInst.pointer_to);
                                    required, typeName := typeDeclarationRequired(*declaration);
                                    if required {
                                        table_add(*foundTypes, typeName, *declaration);
                                    }
                                // }
                            }
                        }
                    }
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
    // for other: message.all {
    //     codeNode :*Code_Node= other.expression;
    //     if codeNode.location.enclosing_load != null {
    //         if contains(codeNode.location.enclosing_load.fully_pathed_filename, FILE_NAME) {
    //             print("from all: type=% line=%\n", codeNode.kind, codeNode.location.l0);
    //         }
    //         // if codeDeclaration.expression.kind == .LITERAL {
    //         //     builder:String_Builder;
    //         //     location := declarationLocation_Code_Declaration(codeDeclaration);
    //         //     locationToBuilder(*builder, location);
    //         //     result := builder_to_string(*builder);
    //         //     print("res:%\n", result);
    //         // }
    //     }
    //     // subCodeNodes :[] *Code_Node= other.subexpressions;
    //     // for subCodeNode: subCodeNodes {
    //     //     if subCodeNode.location.enclosing_load != null {
    //     //         if contains(subCodeNode.location.enclosing_load.fully_pathed_filename, FILE_NAME) {
    //     //             print("from all (sub): %=%\n", subCodeNode.kind, subCodeNode.location.l0);
    //     //         }
    //     //     }
    //     // }
    // }

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

    for foundConstant: foundConstants {
        printConstant(*builder, foundConstant);
    }
    for foundEnum: foundEnums {
        printEnum(*builder, foundEnum);
    }
    for foundType: foundTypes {
        printType(*builder, foundType);
    }
    for foundProcedure: foundProcedures {
        printProcedure(*builder, foundProcedure);
    }
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


printConstant :: (builder:*String_Builder, td: *Typechecked(Code_Declaration)) {
   location := declarationLocation_Any(td);
   locationToBuilder(builder, location);
   append(builder, #char "\n");
}

printEnum :: (builder:*String_Builder, td: *Typechecked(Code_Declaration)) {
    print("---- printEnum:%,%\n", td.expression, td.subexpressions.count );
    for subexpression:td.subexpressions {
        print("subexpression:%\n", subexpression.kind);
    }
    location := declarationLocation_Enum(td);
    print("enum:%,%\n", location.l0, location.l1);
    locationToBuilder(builder, location);
    append(builder, #char "\n");
}

printProcedure :: (builder:*String_Builder, td: *Typechecked(Code_Declaration)) {
    location := declarationLocation_Any(td);
    locationToBuilder(builder, location);
    append(builder, "{}");
    // print_declaration(builder, td.expression);
    append(builder, #char "\n");
}

printStruct :: (builder:*String_Builder, st: *Typechecked(Code_Struct)) {
    structName := st.expression.defined_type.name;
    // if array_find(IGNORED_STRUCT_NAMES, structName) {
    //     return;
    // }
    location := declarationLocation_Code_Struct(st);
    print_to_builder(builder, "% ::", structName);
    locationToBuilder(builder, location);
    append(builder, #char "\n");
}

printType :: (builder:*String_Builder, td: *Typechecked(Code_Declaration)) {
   location := declarationLocation_Any(td);
   locationToBuilder(builder, location);
   append(builder, #char "\n");
}


constantDeclarationRequired :: (td: *Typechecked(Code_Declaration))->(required:bool, typeName:string) {
	required, typeName := _declarationRequired(td, CONSTANTS_TO_EXPORT);
	return required, typeName;
}
enumDeclarationRequired :: (td: *Typechecked(Code_Declaration))->(required:bool, typeName:string) {
	required, typeName := _declarationRequired(td, ENUMS_TO_EXPORT);
	return required, typeName;
}
procedureDeclarationRequired :: (td: *Typechecked(Code_Declaration))->(required:bool, typeName:string) {
	// codeDeclaration :*Code_Declaration= td.expression;
    // codeNode :*Code_Node= codeDeclaration.expression;
    required, typeName := _declarationRequired(td, CONSTANTS_TO_EXPORT);
	return required, typeName;
}

typeDeclarationRequired :: (td: *Typechecked(Code_Declaration))->(required:bool, typeName:string) {
	required, typeName := _declarationRequired(td, TYPES_TO_EXPORT);
	return required, typeName;
}

MODULES::"modules";
_declarationRequired :: (td: *Typechecked(Code_Declaration), requiredNames:[]string)->(required:bool, typeName:string) {
	if (td.expression.flags & .SCOPE_FILE) != 0 {
		return false, "";
	}
	
	locationCore := td.expression.location;
	if locationCore.enclosing_load == null {
		return false, "";
	}
	filePathCore := parse_path(locationCore.enclosing_load.fully_pathed_filename);
	for word : filePathCore.words {
		if word == MODULES {
			return false, "";
		}
	}

	location := declarationLocation_Any(td);
	builder :String_Builder;
	locationToBuilder(*builder, location);
	content := builder_to_string(*builder);
	// print("file:%,l0=%\n", locationCore.enclosing_load.fully_pathed_filename, locationCore.l0);
	// print("content:%.\n", content);
	firstColon := find_index_from_left(content, #char ":");
	typeName := trim(slice(content, 0, firstColon));
	required := array_find(requiredNames, typeName);
	return required, typeName;
}

