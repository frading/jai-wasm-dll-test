
locationToBuilder :: (builder:*String_Builder, location:CustomLocation) {
    filePath := location.enclosing_load.fully_pathed_filename;
    file_content, success := read_entire_file(filePath);

    lineIndex := 1;
    startLineIndex := -1;
    // print("location.l0: %\n", location.l0);
    // print("location.l1: %\n", location.l1);
    // print("location.c0: %\n", location.c0);
    // print("location.c1: %\n", location.c1);
    while lineIndex < location.l0 {
        startLineIndex = find_index_from_left(file_content, #char "\n", startLineIndex+1);
        lineIndex += 1;
    }
    // print("startLineIndex: %\n", startLineIndex);
    endLineIndex := startLineIndex;
    while lineIndex < location.l1 {
        endLineIndex = find_index_from_left(file_content, #char "\n", endLineIndex+1);
        lineIndex += 1;
    }
    // print("endLineIndex: %\n", endLineIndex);
    startIndex := startLineIndex+location.c0;
    endIndex := endLineIndex+location.c1;
    locationContent := slice(file_content, startIndex-1, endIndex-startIndex+2);
    append(builder, locationContent);
    // append(builder, #char "\n");
}

declarationLocation_Code_Procedure_Header :: (node:*Typechecked($T), procHeader:*Code_Procedure_Header)->CustomLocation {
    location := locationToCustomLocation(node.expression.location);

    print("declarationLocation:%,%.\n", procHeader.name, procHeader.foreign_function_name);
    
    arguments:[]*Code_Declaration = procHeader.arguments;
    returns:[]*Code_Declaration = procHeader.returns;
    print("arguments:%\n", arguments);
    print("returns:%\n", returns);

    for arg:arguments {
        locArg := locationToCustomLocation(arg.location);
        location = locationsExpand(location, locArg);
    }
    for ret:returns {
        locRet := locationToCustomLocation(ret.location);
        location = locationsExpand(location, locRet);
    }

    // print("node.expression:%\n", node.expression.kind);
    // type_inst :*Code_Type_Instantiation= node.expression.type_inst;
    // assert(type_inst!=null, "type_inst is null");
    // location = locationsSubtract(location, locationToCustomLocation(type_inst.location));

    return location;

}

declarationLocation_Code_Declaration :: (codeDeclaration:*Code_Declaration)->CustomLocation {
    type_inst :*Code_Type_Instantiation= codeDeclaration.type_inst;
    expression :*Code_Node = codeDeclaration.expression;

    assert(type_inst!=null, "type_inst is null");

    loc0 := locationToCustomLocation(type_inst.location);
    loc1 := locationToCustomLocation(expression.location);
    return locationsExpand(loc0, loc1);
}

locationsExpand :: (a: CustomLocation, b: CustomLocation)-> CustomLocation {
    l0 := min(a.l0, b.l0);
    l1 := max(a.l1, b.l1);
    c0 := a.c0;
    c1 := b.c1;
    if a.l0 == b.l0 {
        c0 = min(a.c0, b.c0);
    } else if a.l0 < b.l0 {
        c0 = a.c0;
    } else {
        c0 = b.c0;
    }
    if a.l1 == b.l1 {
        c1 = max(a.c1, b.c1);
    } else if a.l1 > b.l1 {
        c1 = a.c1;
    } else {
        c1 = b.c1;
    }
    return CustomLocation.{
        enclosing_load = a.enclosing_load,
        l0 = l0,
        c0 = c0,
        l1 = l1,
        c1 = c1
    };
}

locationsSubtract :: (a: CustomLocation, b: CustomLocation)-> CustomLocation {
    if a.l0 > b.l1 {
        return a;
    } else if a.l0 < b.l1 {
        return .{
            enclosing_load = a.enclosing_load,
            l0 = b.l1,
            c0 = b.c1,
            l1 = a.l1,
            c1 = a.c1
        };
    } else {
        c0 := max(a.c0, b.c1);
        return .{
            enclosing_load = a.enclosing_load,
            l0 = b.l1,
            c0 = c0,
            l1 = a.l1,
            c1 = a.c1
        };
    }
}

locationToCustomLocation :: (location:$T)->CustomLocation {
     return CustomLocation.{
        enclosing_load = location.enclosing_load,
        l0 = location.l0,
        c0 = location.c0,
        l1 = location.l1,
        c1 = location.c1
    };
}

declarationLocation_Code_Struct :: (node:*Typechecked(Code_Struct))->CustomLocation {
    location := node.expression.location;
    subexpressions := node.subexpressions;
    maxL1 :s32= location.l1;
    for subexpression: subexpressions {
        if subexpression.location.l1 > maxL1 {
            maxL1 = subexpression.location.l1;
        }
    }
    maxC1 :s32= 0;
    for subexpression: subexpressions {
        if subexpression.location.l1 == maxL1 {
            if subexpression.location.c1 > maxC1 {
                maxC1 = subexpression.location.c1;
            }
        }
    }

    return CustomLocation.{
        enclosing_load = location.enclosing_load,
        l0 = location.l0,
        c0 = location.c0,
        l1 = maxL1,
        c1 = maxC1
    };
}

declarationLocation_Any :: (node:*Typechecked($T))->CustomLocation {
    location := node.expression.location;
    subexpressions := node.subexpressions;
    print("subexpressions:% from %\n", subexpressions.count, node.expression.kind);
    maxL1 :s32= location.l1;
    for subexpression, i: subexpressions {
        print("%:%\n", i, subexpression.kind);
        if subexpression.location.l1 > maxL1 {
            maxL1 = subexpression.location.l1;
        }
    }
    maxC1 :s32= 0;
    for subexpression: subexpressions {
        if subexpression.location.l1 == maxL1 {
            if subexpression.location.c1 > maxC1 {
                maxC1 = subexpression.location.c1;
            }
        }
    }

    return CustomLocation.{
        enclosing_load = location.enclosing_load,
        l0 = location.l0,
        c0 = location.c0,
        l1 = maxL1,
        c1 = maxC1
    };
}
