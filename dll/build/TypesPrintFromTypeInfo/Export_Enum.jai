
export_Enum :: (using info: *BindingsExportInfo, builder: *String_Builder, type: *Type_Info_Enum, name := "") {
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