

export_Struct :: (using info: *BindingsExportInfo, builder: *String_Builder, type: *Type_Info_Struct, name := "") {

    output_name := ifx name then name else type.name;

    if alreadyDefinedTypeName(output_name) {
        return;
    }

    print("export_Struct:% (%)\n", name, type.type);

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
        isMemberImported := (member.flags & .IMPORTED) != 0;
        isMemberConstant := (member.flags & .CONSTANT) != 0;
        printYellow(tprint("write member '%' (%), member=%, current_offset=%, isMemberConstant=%", member.name, member.type.type, member, current_offset, isMemberConstant));
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

        isInternal := false;
        if member.type.type == .STRUCT {
            memberStruct := cast(*Type_Info_Struct) member.type;
            if isInternalTypeInfo(info, type, memberStruct.name) {
                isInternal = true;
            }
        }

        if isInternal {
            memberStruct := cast(*Type_Info_Struct) member.type;
            export_Struct(info, builder, memberStruct, memberStruct.name);
        } else {
            export_Type(info, builder, member.type, member.name, exportingMember=true, parentTypeInfo=type, depth=0);
        }
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