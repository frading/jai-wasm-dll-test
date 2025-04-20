BindingsExportInfo :: struct {
    // prefix_enum_values:   bool;
    exported_procedures:  [..] *Code_Declaration;
    exported_types:       Table(*Type_Info, string);
    name_types:           Table(string, *Type_Info);
    ordered_types:        [..] *Type_Info;

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
        for typechecked.declarations {
            decl := it.expression;
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
                    if decl.program_export_name == "main" continue;
                    if decl.program_export_name == "__jai_runtime_fini" continue;
                    if decl.program_export_name == "__jai_runtime_init" continue;
                    print("add: %\n", decl.program_export_name);
                    array_add(*exported_procedures, decl);
                }
            }
        }
    }
}

bindingsExportWriteFile :: (using info: *BindingsExportInfo, path: string) -> bool {
    builder: String_Builder;
    append(*builder, HEADER);

    for decl:exported_procedures {
        collect_exported_types(info, decl.type);
    }

    print("----------- collection completed (% ordered_types)\n", ordered_types.count);
    for type, i: ordered_types {
        if type.type == {
            case .STRUCT; { st := cast(*Type_Info_Struct) type; print("%:%,%\n", i, type.type, st.name); }
            case; { print("%:%\n", i, type.type); }
        }
    }
    print("--------------------------------------------------\n");


    for type: ordered_types {
        name, found := table_find(*exported_types, type);
        assert(found);
        
        if type.type == {
            case .ENUM;   bindingsExportWriteFile_Enum(info, *builder, cast(*Type_Info_Enum) type, name);
            case .STRUCT; bindingsExportWriteFile_Struct(info, *builder, cast(*Type_Info_Struct) type, name);
            case;         bindingsExportWriteFile_Type(info, *builder, type, name);
        }
        append(*builder, "\n");
    }
    append(*builder, "\n");

    result := write_entire_file(path, *builder);
    print("file written: %\n", path);
    return result;
}

#scope_file

HEADER :: #string END
// auto generated
END

ALREADY_DEFINED_TYPE_NAMES :: string.[
    "string",
    "Type_Info"
];
alreadyDefinedTypeName :: (name:string)->bool {
    return array_find(ALREADY_DEFINED_TYPE_NAMES, name);
}

collect_exported_types :: (using info: *BindingsExportInfo, type: *Type_Info) {

    // Avoid recursion
    existing_name := table_find_pointer(*exported_types, type);
    if existing_name return;


	if type.type == {
        case .TYPE; {
            add_type(info, type_type_info, "Type_Info");
        }
		case .STRING; {
            // assert(false, "string not implemented yet");
            add_type(info, type_newstring, "string");
        }
		case .POINTER; {
            assert(false, "point not implemented yet");
			// pointer := cast(*Type_Info_Pointer) type;

            // pointee := pointer.pointer_to;
            // collect_exported_types(info, pointee);
        }
        case .ENUM; {
            assert(false, "enum not implemented yet");
            // _enum := cast(*Type_Info_Enum) type;

            // add_type(info, _enum, _enum.name);
        }
        case .STRUCT; {
            _struct := cast(*Type_Info_Struct) type;
            print(" struct:%\n", _struct.name);

            // We add the struct first to avoid recursions,
            // but we add it to the ordered types last so emit the child types first
            add_type(info, _struct, _struct.name, add_to_ordered_types = false);
            for member:_struct.members {
                print(" - member:%,%\n", member.name, member.type.type);
                // if member.flags & .CONSTANT assert(false, "constant flag not implemented yet");
                if member.flags & .IMPORTED assert(false, "imported flag not implemented yet");
                if member.flags & .USING assert(false, "using flag not implemented yet");
                if member.flags & .PROCEDURE_WITH_VOID_POINTER_TYPE_INFO assert(false, "PROCEDURE_WITH_VOID_POINTER_TYPE_INFO flag not implemented yet");
                if member.flags & .AS assert(false, "as flag not implemented yet");
                collect_exported_types(info, member.type);
            }
            array_add(*ordered_types, _struct);
            print("---\n");

            // I assume for now that we should collect the polymorph struct after the members.
            if _struct.polymorph_source_struct {
                collect_exported_types(info, _struct.polymorph_source_struct);
            }
        }

        case .PROCEDURE;{
            procedure := cast(*Type_Info_Procedure) type;
            if procedure.return_types.count {
                assert(procedure.return_types.count == 1);
                collect_exported_types(info, procedure.return_types[0]);
            }
            for procedure.argument_types {
                collect_exported_types(info, it);
            }
        }
        case .ARRAY;{
            assert(false, "array not implemented yet");
            // array := cast(*Type_Info_Array) type;
            // if array.array_type == {
            //     case .FIXED;
            //         collect_exported_types(info, array.element_type);
            //     case .VIEW;
            //         collect_exported_types(info, type_array_view_64);
            //     case .RESIZABLE;
            //         collect_exported_types(info, type_resizable_array);
            // }
        }

        case .ANY; {
            assert(false, "any not implemented yet");
            // add_type(info, type_any, "Any");
        }
	}
}

add_type :: (using info: *BindingsExportInfo, type: *Type_Info, name: string, add_to_ordered_types := true) {
    // print(" + add_type:% (%)\n", name, type.type);
    assert(type != null, "type is null");
    existing_name := table_find_pointer(*exported_types, type);
    if existing_name {
        print("-------------- type % not found in exported_types\n", name);
        return;
    }

    base_name := name; // avoid_reserved_names(name);
    output_name := base_name;
    counter := 1;
    while true {
        existing_type := table_find_pointer(*name_types, output_name);
        if !existing_type break;
        output_name = tprint("%_%", base_name, counter);
        counter += 1;
    }

    table_add(*exported_types, type, output_name);
    table_add(*name_types, output_name, type);
    if add_to_ordered_types array_add(*ordered_types, type);
}

bindingsExportWriteFile_Enum :: (using info: *BindingsExportInfo, builder: *String_Builder, type: *Type_Info_Enum, name := "") {
    output_name := ifx name then name else type.name;
    assert(false, tprint("bindingsExportWriteFile_Enum not implemented:%", output_name));
    // output_name = avoid_reserved_names(output_name);

    // append(builder, "enum ");

    // if output_name print_to_builder(builder, "%0% ", jai_type_prefix, output_name);
    // append(builder, "{\n");
    // indent := "    ";

    // prefix: string;
    // if info.prefix_enum_values {
    //     builder: String_Builder;
    //     for i: 0..output_name.count-1 {
    //         c := output_name[i];
    //         if c >= #char "A" && c <= #char "Z" {
    //             append(*builder, c);
    //         }
    //     }
    //     append(*builder, #char "_");
    //     prefix = builder_to_string(*builder,, allocator = temp);
    // }

    // current_offset := 0;
    // for type.names {
    //     name := avoid_reserved_names(it);

    //     append(builder, indent);
    //     print_to_builder(builder, "%0% = %,\n", prefix, name, type.values[it_index]);
    // }

    // append(builder, "}");
}

bindingsExportWriteFile_Struct :: (using info: *BindingsExportInfo, builder: *String_Builder, type: *Type_Info_Struct, name := "") {

    output_name := ifx name then name else type.name;

    if alreadyDefinedTypeName(output_name) {
        return;
    }

    // assert(false, tprint("bindingsExportWriteFile_Struct not implemented:%", output_name));

    // if type.nontextual_flags & .POLYMORPHIC { assert(false, tprint("polymorphic not handled yet %", output_name)); };
    // output_name = avoid_reserved_names(output_name);

    is_union := (type.textual_flags & .UNION) != 0;
    assert(is_union==false, "not sure how to handle unions yet");
    // if type.textual_flags & .UNION {
    //     append(builder, "union ");
    // } else {
        print_to_builder(builder, "% :: struct {\n", output_name);
    // }

    // if output_name print_to_builder(builder, "%0% ", jai_type_prefix, output_name);
    // append(builder, "{\n");
    // indent := "    ";

    current_offset := 0;
    for member:type.members {
        print("write member '%', member=%, current_offset=%\n", member.name, member, current_offset);
        isMemberImported := (member.flags & .IMPORTED) != 0;
        isMemberConstant := (member.flags & .CONSTANT) != 0;
        print("isMemberConstant:%,%\n", isMemberConstant, member.flags & .CONSTANT);
        if isMemberImported { assert(false, tprint("member IMPORTED:%", member.name)); }
        // if isMemberConstant { assert(false, tprint("member CONSTANT:%", member.name)); }
        if member.type.type == .VOID { assert(false, tprint("member VOID:%", member.name)); }
        if isMemberConstant == false {
            if member.offset_in_bytes < current_offset && !is_union {
                compiler_report(tprint("Member % of struct % overlaps previous fields (member.offset_in_bytes=%, current_offset=%, member.offset_into_constant_storage=%)", member.name, type.name, member.offset_in_bytes, current_offset, member.offset_into_constant_storage));
                break;
            }
        }

        // name := avoid_reserved_names(member.name);

        append(builder, INDENT);
        bindingsExportWriteFile_Type(info, builder, member.type, member.name);
        if member.offset_into_constant_storage < 0 {
            append(builder, ";\n");
            current_offset += member.type.runtime_size;
        }
    }

    append(builder, "}\n");
    // if add_typedef && output_name {
    //     print_to_builder(builder, " %0%", jai_type_prefix, output_name);
    // }
}

bindingsExportWriteFile_Type :: (using info: *BindingsExportInfo, builder: *String_Builder, type: *Type_Info, name := "") {
    //  assert(false, tprint("bindingsExportWriteFile_Type not implemented:%.", name));
    print("bindingsExportWriteFile_Type:% (%)\n", name, type.type);

    append_name := true;
    append_space_before_name := true;
	if type.type == {
        case .TYPE;
            bindingsExportWriteFile_Type(info, builder, type_type_info, name);
            // append(builder, " *");
            append_space_before_name = false;
		case .INTEGER;
			integer := cast(*Type_Info_Integer) type;
			sign := integer.signed;
			size := integer.runtime_size;

			str: string;
			if size == {
				case 1; if sign str = "s8";  else str = "u8";
				case 2; if sign str = "s16"; else str = "u16";
				case 4; if sign str = "s32"; else str = "u32";
				case 8; if sign str = "s64"; else str = "u64";
				case;
					assert(false, "Unexpected Runtime size: %", size);
			}

            print_to_builder(builder, "%: %", name, str);
			// append(builder, str);
		case .FLOAT;
			fl := cast(*Type_Info_Float) type;
            size := fl.runtime_size;
            str: string;
            if size == {
                case 4; str = "float32";
                case 8; str = "float64";
            }
            print_to_builder(builder, "%: %", name, str);
			// if fl.runtime_size == 8 append(builder, "double");
			// else append(builder, "float");
		case .BOOL;
            print_to_builder(builder, "%: bool", name);
			// append(builder, "bool");
		case .STRING;
            print_to_builder(builder, "%: string", name);
            // append(builder, jai_type_prefix);
			// append(builder, "string");
		case .POINTER;
			pointer := cast(*Type_Info_Pointer) type;
            pointee := pointer.pointer_to;

            bindingsExportWriteFile_Type(info, builder, pointee);
            if pointee.type != .POINTER append(builder, " ");
			append(builder, "*");
            append_space_before_name = false;

		case .VOID;
			append(builder, "void");
        // case .ENUM;
        //     _enum := cast(*Type_Info_Enum) type;

        //     enum_name, found := table_find(*exported_types, type);
        //     assert(found);

        //     if enum_name {
        //         append(builder, jai_type_prefix);
        //         append(builder, enum_name);
        //     } else {
        //         append_enum_in_c(info, builder, _enum);
        //     }

        case .STRUCT;
            _struct := cast(*Type_Info_Struct) type;
            // assert(!_struct.polymorph_source_struct);

            struct_name, found := table_find(*exported_types, type);
            assert(found, tprint("struct_name not found:'%'\n", type));

            if struct_name == "Type_Info" {
                print_to_builder(builder, "%: Type", name);
            } else {
            // if struct_name {
            //     if _struct.textual_flags & .UNION {
            //         append(builder, "union ");
            //     } else {
            //         append(builder, "struct ");
            //     }
            //     // append(builder, jai_type_prefix);
            //     append(builder, struct_name);
            // } else {
            //     bindingsExportWriteFile_Type(info, builder, _struct);
            // }
            }


        case .PROCEDURE;
            // @Incomplete
            append(builder, "void *");
            append_space_before_name = false;
        case .ARRAY;
            array := cast(*Type_Info_Array) type;
            if array.array_type == {
                case .FIXED;
                    bindingsExportWriteFile_Type(info, builder, array.element_type);
                    if name print_to_builder(builder, " %", name);
                    print_to_builder(builder, "[%]", array.array_count);
                    append_name = false;
                case .VIEW;
                    // append(builder, jai_type_prefix);
                    append(builder, "Array_View_64"); //@Hack we should probably generate the struct with the appropriate type for data
                case .RESIZABLE;
                    // append(builder, jai_type_prefix);
                    append(builder, "Resizable_Array"); // @Hack maybe generate an anonymous struct with the types we want ?
            }
        case .ENUM;
            en := cast(*Type_Info_Enum) type;
            print("enum: name=%, internal_type=%\n", en.name, en.internal_type);
            if en.name == "Type_Info_Tag" {
                print_to_builder(builder, "%:Type", name);
            } else {
                assert(false);
            }
            // bindingsExportWriteFile_Type(info, builder, en.internal_type);
        case .ANY;
            // append(builder, jai_type_prefix);
            append(builder, "Any");
		case;
            assert(false, "Unhandled type: %", type.type);
	}

    // if name && append_name {
    //     if append_space_before_name append(builder, " ");
    //     append(builder, name);
    // }
}