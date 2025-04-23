
collectExportedTypes :: (using info: *BindingsExportInfo, type: *Type_Info, declaration: *Typechecked(Code_Declaration)) {

    // Avoid recursion
    existing_name := table_find_pointer(*exportedTypes, type);
    if existing_name return;


	if type.type == {
        case .TYPE; {
            // stackTraceNode := pack_stack_trace();
            // print_stack_trace(*stackTraceNode[0]);
            // print("type:%\n", type);
            _addExportedType(info, type_type_info, "Type_Info");
        }
		case .STRING; {
            // assert(false, "string not implemented yet");
            _addExportedType(info, type_newstring, "string");
        }
		case .POINTER; {
            assert(false, "point not implemented yet");
			// pointer := cast(*Type_Info_Pointer) type;

            // pointee := pointer.pointer_to;
            // collectExportedTypes(info, pointee);
        }
        case .ENUM; {
            assert(false, "enum not implemented yet");
            // _enum := cast(*Type_Info_Enum) type;

            // _addExportedType(info, _enum, _enum.name);
        }
        case .STRUCT; {
            _struct := cast(*Type_Info_Struct) type;
            printYellow(tprint(" struct:%", _struct.name));

            // We add the struct first to avoid recursions,
            // but we add it to the ordered types last so emit the child types first
            _addExportedType(info, _struct, _struct.name);
            for member:_struct.members {
                if member.flags & .CONSTANT {
                    // constant member are probably an internally declared struct
                    // so we skip them here. But we might need to store them if writing them ends up being tricky
                    // assert(false, "constant flag not implemented yet");
                    // continue;
                    typeDebug := get_type(member.type);
                    print("constant:%,%,%,%\n", member.name, member.type, member.type.type, typeDebug);
                    builderDebug:String_Builder;
                    print_type_to_builder(*builderDebug, cast(*Type_Info)type_of(member.type));
                    resultDebug := builder_to_string(*builderDebug);
                    print("DEBUG:%\n", resultDebug);
                    if member.type.type == .TYPE {
                        addInternalType(info, type, member.name, member.type);
                        continue;
                    }
                }
                // print(" - %.% (type=%)\n", _struct.name, member.name, member.type.type);
                if member.flags & .IMPORTED assert(false, "imported flag not implemented yet");
                if member.flags & .USING assert(false, "using flag not implemented yet");
                if member.flags & .PROCEDURE_WITH_VOID_POINTER_TYPE_INFO assert(false, "PROCEDURE_WITH_VOID_POINTER_TYPE_INFO flag not implemented yet");
                if member.flags & .AS assert(false, "as flag not implemented yet");

                if member.type.type == .STRUCT {
                    memberStruct := cast(*Type_Info_Struct) member.type;
                    if isInternalTypeInfo(info, type, memberStruct.name) {
                        // print("is internal!\n");
                        continue;
                    }
                }

                collectExportedTypes(info, member.type, null);
            }
            // array_add(*ordered_types, _struct);

            // I assume for now that we should collect the polymorph struct after the members.
            if _struct.polymorph_source_struct {
                collectExportedTypes(info, _struct.polymorph_source_struct, null);
            }
        }

        case .PROCEDURE;{
            procedure := cast(*Type_Info_Procedure) type;
            if procedure.return_types.count {
                assert(procedure.return_types.count == 1, "multiple return types not yet implemented");
                collectExportedTypes(info, procedure.return_types[0], null);
            }
            for arg:procedure.argument_types {
                print("arg:%\n", arg.type);
                collectExportedTypes(info, arg, null);
            }
        }
        case .ARRAY;{
            assert(false, "array not implemented yet");
            // array := cast(*Type_Info_Array) type;
            // if array.array_type == {
            //     case .FIXED;
            //         collectExportedTypes(info, array.element_type);
            //     case .VIEW;
            //         collectExportedTypes(info, type_array_view_64);
            //     case .RESIZABLE;
            //         collectExportedTypes(info, type_resizable_array);
            // }
        }

        case .ANY; {
            assert(false, "any not implemented yet");
            // add_type(info, type_any, "Any");
        }
	}
}

#scope_file



_addExportedType :: (using info: *BindingsExportInfo, type: *Type_Info, name: string) {
    // print(" + add_type:% (%)\n", name, type.type);
    assert(type != null, "type is null");
    existing_name := table_find_pointer(*exportedTypes, type);
    if existing_name {
        print("-------------- type already exportedTypes:%.\n", name);
        return;
    }

    // base_name := name; // avoid_reserved_names(name);
    // output_name := base_name;
    // counter := 1;
    // while true {
    //     existing_type := table_find_pointer(*name_types, output_name);
    //     if !existing_type break;
    //     output_name = tprint("%_%", base_name, counter);
    //     counter += 1;
    // }

    print("+ type.type=%, name=%\n", type.type, name);
    table_add(*exportedTypes, type, name);
    // table_add(*name_types, output_name, type);
    // if add_to_ordered_types array_add(*ordered_types, type);
}