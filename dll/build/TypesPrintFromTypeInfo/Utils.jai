alreadyDefinedTypeName :: (name:string)->bool {
    return array_find(ALREADY_DEFINED_TYPE_NAMES, name);
}