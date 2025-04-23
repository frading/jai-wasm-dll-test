TypeInfoWithName :: struct {
    name:string;
    typeInfo: *Type_Info;
}
TypeInfoList :: struct {
    // we can increase that count if a struct happens to have more internal structs
    // but that will most likely not happen
    list: [MAX_COUNT]TypeInfoWithName;
    count: u8;
}

addInternalType :: (using info: *BindingsExportInfo, parentTypeInfo: *Type_Info, name:string, internalTypeInfo:*Type_Info) {
    print("addInternalType: %,%\n", name, internalTypeInfo.type);
    internalTypeInfos := table_find_pointer(*internalTypes, parentTypeInfo);

    typeInfoWithName: TypeInfoWithName = .{
        name = name,
        typeInfo = internalTypeInfo
    };

    if internalTypeInfos {
        addTypeInfo(internalTypeInfos, typeInfoWithName);
    } else {
        list :TypeInfoList;
        addTypeInfo(*list, typeInfoWithName);
        table_add(*internalTypes, parentTypeInfo, list);
    }

}

isInternalTypeInfo :: (using info: *BindingsExportInfo, parentTypeInfo: *Type_Info, name:string)->bool, *Type_Info {
    // print("IS?\n");
    internalTypeInfos := table_find_pointer(*internalTypes, parentTypeInfo);
    if internalTypeInfos == null {
        return false, null;
    }
    assert(internalTypeInfos.count > 0);

    for i:0..(internalTypeInfos.count-1) {
        currentInternalTypeInfo := internalTypeInfos.list[i];
        // print("**** internalTypeInfo:%\n", internalTypeInfo);
        if currentInternalTypeInfo.name == name {
            // TODO: we should also test the typeInfo!
            return true, currentInternalTypeInfo.typeInfo;
        }
    }
    return false, null;
}

#scope_file

MAX_COUNT :: 4;

addTypeInfo :: (list: *TypeInfoList, typeInfoWithName: TypeInfoWithName) {
    assert(list.count < MAX_COUNT);
    list.list[list.count] = typeInfoWithName;
    list.count+=1;
}