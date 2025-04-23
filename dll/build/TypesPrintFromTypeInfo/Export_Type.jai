

export_Type :: (using info: *BindingsExportInfo, builder: *String_Builder, type: *Type_Info, name := "", exportingMember:bool, parentTypeInfo:*Type_Info, depth:int) {
    //  assert(false, tprint("bindingsExportWriteFile_Type not implemented:%.", name));
    assert(depth < 5, tprint("depth too high (%)", depth));
    print("export_Type:% (%), depth=%\n", name, type.type, depth);


    append_name := true;
    // append_space_before_name := true;
	if type.type == {
        case .TYPE;
            export_Type(info, builder, type_type_info, name, exportingMember, parentTypeInfo, depth+1);
            // append(builder, " *");
            // append_space_before_name = false;
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

            export_Type(info, builder, pointee, name, exportingMember, parentTypeInfo, depth+1);
            if pointee.type != .POINTER append(builder, " ");
			append(builder, "*");
            // append_space_before_name = false;

		case .VOID;
			append(builder, "void");
        // case .ENUM;
        //     _enum := cast(*Type_Info_Enum) type;

        //     enum_name, found := table_find(*exportedTypes, type);
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

            struct_name, found := table_find(*exportedTypes, type);
            print("_struct:%,%\n", _struct.name, struct_name);
            // if found == false {
            //     stackTraceNode := pack_stack_trace();
            //     print_stack_trace(*stackTraceNode[0]);
            // }
            // assert(found, tprint("struct_name not found:'%'\n", type));
            if struct_name {
                if struct_name == "Type_Info" {
                    print_to_builder(builder, "%: Type", name);
                } else {
                    assert(false, "not sure what to do here yet");
                    // if _struct.textual_flags & .UNION {
                    //     append(builder, "union ");
                    // } else {
                    //     append(builder, "struct ");
                    // }
                    // // append(builder, jai_type_prefix);
                    // append(builder, struct_name);
                }
            } else {
                // assert(false, "not sure what to do here yet either");
                isInternal, internalTypeInfo := isInternalTypeInfo(info, parentTypeInfo=parentTypeInfo, name);
                print("isInternal:%\n", isInternal);
                if isInternal {
                    if _struct.name == "Type_Info" {
                        // t := get_type(type);
                        print("t:%\n", type.type);
                    } else {
                        // assert(false, "WE ARE OK");
                        export_Struct(info, builder, cast(*Type_Info_Struct) internalTypeInfo, name);
                    }
                } else {
                    print("name:%\n", name);
                    export_Type(info, builder, _struct, name, exportingMember, parentTypeInfo, depth+1);
                }
            }


        case .PROCEDURE;
            // @Incomplete
            append(builder, "void *");
            // append_space_before_name = false;
        case .ARRAY;
            array := cast(*Type_Info_Array) type;
            if array.array_type == {
                case .FIXED;
                    export_Type(info, builder, array.element_type, name, exportingMember, parentTypeInfo, depth+1);
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
            // export_Type(info, builder, en.internal_type, depth+1);
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