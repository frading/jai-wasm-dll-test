// Header_Info :: struct {
//     prefix_enum_values:   bool;
//     jai_type_prefix:      string;
//     exported_procedures:  [..] *Code_Declaration;
//     exported_types:       Table(*Type_Info, string);
//     name_types:           Table(string, *Type_Info);
//     ordered_types:        [..] *Type_Info;

//     type_resizable_array: *Type_Info;
//     type_array_view_8:    *Type_Info;
//     type_array_view_16:   *Type_Info;
//     type_array_view_32:   *Type_Info;
//     type_array_view_64:   *Type_Info;
//     type_type_info:       *Type_Info;
//     type_newstring:       *Type_Info;
//     type_any:             *Type_Info;
// }

// handle_message :: (using info: *Header_Info, message: *Message) {
//     if message.kind == .TYPECHECKED {
//         typechecked := cast (*Message_Typechecked) message;
//         for typechecked.declarations {
//             decl := it.expression;
//             if decl.expression && decl.expression.kind == .STRUCT {
//                 _struct := cast(*Code_Struct) decl.expression;
//                 if decl.name == "Resizable_Array" type_resizable_array = _struct.defined_type;
//                 if decl.name == "Array_View_8"    type_array_view_8 = _struct.defined_type;
//                 if decl.name == "Array_View_16"   type_array_view_16 = _struct.defined_type;
//                 if decl.name == "Array_View_32"   type_array_view_32 = _struct.defined_type;
//                 if decl.name == "Array_View_64"   type_array_view_64 = _struct.defined_type;
//                 if decl.name == "Type_Info"       type_type_info = _struct.defined_type;
//                 if decl.name == "Newstring"       type_newstring = _struct.defined_type;
//                 if decl.name == "Any_Struct"      type_any = _struct.defined_type;
//             }

//             if decl.flags & .PROGRAM_EXPORT {
//                 if decl.expression.kind == .PROCEDURE_HEADER {
//                     // Don’t export main
//                     if decl.program_export_name == "main" continue;

//                     array_add(*exported_procedures, decl);
//                 }
//             }
//         }
//     }
// }

// generate_header :: (using info: *Header_Info, path: string) -> bool {
//     builder: String_Builder;
//     append(*builder, HEADER);

//     for exported_procedures {
//         collect_exported_types(info, it.type);
//     }

//     // Forward-declare all structs, to be safe:
//     for type: ordered_types {
//         if type.type == .STRUCT {
//             _struct := cast(*Type_Info_Struct) type;
//             name, found := table_find(*exported_types, type);
//             assert(found);
//             if _struct.textual_flags & .UNION {
//                 append(*builder, "union ");
//             } else {
//                 append(*builder, "struct ");
//             }

//             print_to_builder(*builder, "%0%;\n", jai_type_prefix, name);
//         }
//     }
//     append(*builder, "\n");

//     // … then define all types:
//     for type: ordered_types {
//         name, found := table_find(*exported_types, type);
//         assert(found);
//         if type.type == {
//             case .ENUM;   append_enum_in_c(info, *builder, cast(*Type_Info_Enum) type, name);
//             case .STRUCT; append_struct_in_c(info, *builder, cast(*Type_Info_Struct) type, name, add_typedef = true);
//             case;         append_type_in_c(info, *builder, type, name);
//         }
//         append(*builder, ";\n\n");
//     }
//     append(*builder, "\n");

//     for exported_procedures {
//         append_procedure_in_c(info, *builder, it);
//     }

//     append(*builder, FOOTER);

//     return write_entire_file(path, *builder);
// }

// #scope_file

// collect_exported_types :: (using info: *Header_Info, type: *Type_Info) {
//     // Avoid recursion
//     existing_name := table_find_pointer(*exported_types, type);
//     if existing_name return;

// 	if type.type == {
//         case .TYPE;
//             add_type(info, type_type_info, "Type_Info");

// 		case .STRING;
//             add_type(info, type_newstring, "string");

// 		case .POINTER;
// 			pointer := cast(*Type_Info_Pointer) type;

//             pointee := pointer.pointer_to;
//             collect_exported_types(info, pointee);

//         case .ENUM;
//             _enum := cast(*Type_Info_Enum) type;

//             add_type(info, _enum, _enum.name);

//         case .STRUCT;
//             _struct := cast(*Type_Info_Struct) type;
//             assert(!_struct.polymorph_source_struct);

//             // We add the struct first to avoid recursions,
//             // but we add it to the ordered types last so emit the child types first
//             add_type(info, _struct, _struct.name, add_to_ordered_types = false);
//             for * _struct.members {
//                 if it.flags & .IMPORTED  continue;
//                 if it.flags & .CONSTANT  continue;
//                 collect_exported_types(info, it.type);
//             }
//             array_add(*ordered_types, _struct);

//         case .PROCEDURE;
//             procedure := cast(*Type_Info_Procedure) type;
//             if procedure.return_types.count {
//                 assert(procedure.return_types.count == 1);
//                 collect_exported_types(info, procedure.return_types[0]);
//             }
//             for procedure.argument_types {
//                 collect_exported_types(info, it);
//             }

//         case .ARRAY;
//             array := cast(*Type_Info_Array) type;
//             if array.array_type == {
//                 case .FIXED;
//                     collect_exported_types(info, array.element_type);
//                 case .VIEW;
//                     collect_exported_types(info, type_array_view_64);
//                 case .RESIZABLE;
//                     collect_exported_types(info, type_resizable_array);
//             }

//         case .ANY;
//             add_type(info, type_any, "Any");
// 	}
// }

// add_type :: (using info: *Header_Info, type: *Type_Info, name: string, add_to_ordered_types := true) {
//     existing_name := table_find_pointer(*exported_types, type);
//     if existing_name return;

//     base_name := avoid_reserved_names(name);
//     output_name := base_name;
//     counter := 1;
//     while true {
//         existing_type := table_find_pointer(*name_types, output_name);
//         if !existing_type break;
//         output_name = tprint("%_%", base_name, counter);
//         counter += 1;
//     }

//     table_add(*exported_types, type, output_name);
//     table_add(*name_types, output_name, type);
//     if add_to_ordered_types array_add(*ordered_types, type);
// }

// append_type_in_c :: (using info: *Header_Info, builder: *String_Builder, type: *Type_Info, name := "") {
//     append_name := true;
//     append_space_before_name := true;
// 	if type.type == {
//         case .TYPE;
//             append_type_in_c(info, builder, type_type_info);
//             append(builder, " *");
//             append_space_before_name = false;
// 		case .INTEGER;
// 			integer := cast(*Type_Info_Integer) type;
// 			sign := integer.signed;
// 			size := integer.runtime_size;

// 			str: string;
// 			if size == {
// 				case 1; if sign str = "s8";  else str = "u8";
// 				case 2; if sign str = "s16"; else str = "u16";
// 				case 4; if sign str = "s32"; else str = "u32";
// 				case 8; if sign str = "s64"; else str = "u64";
// 				case;
// 					assert(false, "Unexpected Runtime size: %", size);
// 			}

// 			append(builder, str);
// 		case .FLOAT;
// 			fl := cast(*Type_Info_Float) type;
// 			if fl.runtime_size == 8 append(builder, "double");
// 			else append(builder, "float");
// 		case .BOOL;
// 			append(builder, "bool");
// 		case .STRING;
//             append(builder, jai_type_prefix);
// 			append(builder, "string");
// 		case .POINTER;
// 			pointer := cast(*Type_Info_Pointer) type;
//             pointee := pointer.pointer_to;

//             append_type_in_c(info, builder, pointee);
//             if pointee.type != .POINTER append(builder, " ");
// 			append(builder, "*");
//             append_space_before_name = false;

// 		case .VOID;
// 			append(builder, "void");
//         // case .ENUM;
//         //     _enum := cast(*Type_Info_Enum) type;

//         //     enum_name, found := table_find(*exported_types, type);
//         //     assert(found);

//         //     if enum_name {
//         //         append(builder, jai_type_prefix);
//         //         append(builder, enum_name);
//         //     } else {
//         //         append_enum_in_c(info, builder, _enum);
//         //     }

//         case .STRUCT;
//             _struct := cast(*Type_Info_Struct) type;
//             assert(!_struct.polymorph_source_struct);

//             struct_name, found := table_find(*exported_types, type);
//             assert(found);

//             if struct_name {
//                 if _struct.textual_flags & .UNION {
//                     append(builder, "union ");
//                 } else {
//                     append(builder, "struct ");
//                 }
//                 append(builder, jai_type_prefix);
//                 append(builder, struct_name);
//             } else {
//                 append_struct_in_c(info, builder, _struct);
//             }
//         case .PROCEDURE;
//             // @Incomplete
//             append(builder, "void *");
//             append_space_before_name = false;
//         case .ARRAY;
//             array := cast(*Type_Info_Array) type;
//             if array.array_type == {
//                 case .FIXED;
//                     append_type_in_c(info, builder, array.element_type);
//                     if name print_to_builder(builder, " %", name);
//                     print_to_builder(builder, "[%]", array.array_count);
//                     append_name = false;
//                 case .VIEW;
//                     append(builder, jai_type_prefix);
//                     append(builder, "Array_View_64"); //@Hack we should probably generate the struct with the appropriate type for data
//                 case .RESIZABLE;
//                     append(builder, jai_type_prefix);
//                     append(builder, "Resizable_Array"); // @Hack maybe generate an anonymous struct with the types we want ?
//             }
//         case .ENUM;
//             en := cast(*Type_Info_Enum) type;
//             append_type_in_c(info, builder, en.internal_type);
//         case .ANY;
//             append(builder, jai_type_prefix);
//             append(builder, "Any");
// 		case;
//             assert(false, "Unhandled type: %", type.type);
// 	}

//     if name && append_name {
//         if append_space_before_name append(builder, " ");
//         append(builder, name);
//     }
// }

// // @Incomplete: This only handles a very narrow set of procedures and probably needs to be expanded if we want to export fancy stuff:
// append_procedure_in_c :: (using info: *Header_Info, builder: *String_Builder, decl: *Code_Declaration) {
//     header := cast(*Code_Procedure_Header) decl.expression;
//     assert(header.kind == .PROCEDURE_HEADER);

//     type := cast(*Type_Info_Procedure) decl.type;
//     assert(type.type == .PROCEDURE);

//     // @Incomplete: Non-c_call procedures cannot be called from C, but might still need to export them so we can pass pointers to them around?
//     if !(type.procedure_flags & .IS_C_CALL) return;

//     if type.return_types.count {
//         assert(type.return_types.count == 1);
//         append_type_in_c(info, builder, type.return_types[0]);
//     } else {
//         append(builder, "void");
//     }

// 	append(builder, " ");
//     append(builder, decl.program_export_name);
//     append(builder, "(");

// 	for arg_decl: header.arguments {
//         if it_index append(builder, ", ");
//         append_type_in_c(info, builder, arg_decl.type, arg_decl.name);
// 	}

// 	append(builder, ");\n\n");
// }

// append_enum_in_c :: (using info: *Header_Info, builder: *String_Builder, type: *Type_Info_Enum, name := "") {
//     output_name := ifx name then name else type.name;
//     output_name = avoid_reserved_names(output_name);

//     append(builder, "enum ");

//     if output_name print_to_builder(builder, "%0% ", jai_type_prefix, output_name);
//     append(builder, "{\n");
//     indent := "    ";

//     prefix: string;
//     if info.prefix_enum_values {
//         builder: String_Builder;
//         for i: 0..output_name.count-1 {
//             c := output_name[i];
//             if c >= #char "A" && c <= #char "Z" {
//                 append(*builder, c);
//             }
//         }
//         append(*builder, #char "_");
//         prefix = builder_to_string(*builder,, allocator = temp);
//     }

//     current_offset := 0;
//     for type.names {
//         name := avoid_reserved_names(it);

//         append(builder, indent);
//         print_to_builder(builder, "%0% = %,\n", prefix, name, type.values[it_index]);
//     }

//     append(builder, "}");
// }

// append_struct_in_c :: (using info: *Header_Info, builder: *String_Builder, type: *Type_Info_Struct, name := "", add_typedef := false) {
//     if type.nontextual_flags & .POLYMORPHIC  return;

//     output_name := ifx name then name else type.name;
//     output_name = avoid_reserved_names(output_name);

//     if add_typedef && output_name append(builder, "typedef ");

//     is_union := (type.textual_flags & .UNION) != 0;
//     if type.textual_flags & .UNION {
//         append(builder, "union ");
//     } else {
//         append(builder, "struct ");
//     }

//     if output_name print_to_builder(builder, "%0% ", jai_type_prefix, output_name);
//     append(builder, "{\n");
//     indent := "    ";

//     current_offset := 0;
//     for * type.members {
//         if it.flags & .IMPORTED  continue;
//         if it.flags & .CONSTANT  continue;
//         if it.type.type == .VOID continue;
//         if it.offset_in_bytes < current_offset && !is_union {
//             compiler_report(tprint("Member % of struct % overlaps previous fields", it.name, type.name));
//             break;
//         }

//         name := avoid_reserved_names(it.name);

//         append(builder, indent);
//         append_type_in_c(info, builder, it.type, name);
//         append(builder, ";\n");
//         current_offset += it.type.runtime_size;
//     }

//     append(builder, "}");
//     if add_typedef && output_name {
//         print_to_builder(builder, " %0%", jai_type_prefix, output_name);
//     }
// }

// avoid_reserved_names :: (name: string) -> string {
//     if name == "signed" return "_signed";
//     return name;
// }

// HEADER :: #string END
// #include <stdint.h>

// typedef uint64_t     u64;
// typedef uint32_t     u32;
// typedef uint16_t     u16;
// typedef uint8_t      u8;
// typedef int64_t      s64;
// typedef int32_t      s32;
// typedef int16_t      s16;
// typedef int8_t       s8;
// typedef double       float64;
// typedef float        float32;

// struct Type_Info_Struct;

// #ifdef __cplusplus
// extern "C" {
//     #define null (0)
// #else
//     typedef s8          bool;
//     const bool false = 0;
//     const bool true = 1;
// #endif

// END

// FOOTER :: #string END

// #ifdef __cplusplus
// } // extern "C"
// #endif
// END

// #import "Basic";
// #import "File";
// #import "Hash_Table";
// #import "Compiler";
