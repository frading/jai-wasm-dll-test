traverseCodeNode :: (codeNode:*Code_Node) {
    print("traverseCodeNode:%\n", codeNode.kind);
    if codeNode.kind == {
        case .DECLARATION; {
            codeDeclaration := cast(*Code_Declaration) codeNode;
            isConstant := (codeDeclaration.flags & .IS_CONSTANT) != 0;
            print("program_export_name:%, isConstant=%.\n", codeDeclaration.program_export_name, isConstant);
            assert(codeDeclaration.type_inst != null);
            assert(codeDeclaration.expression != null);
            traverseCodeNode(codeDeclaration.type_inst);
            traverseCodeNode(codeDeclaration.expression);
        }
        case; {
            print("kind % not implemented\n", codeNode.kind);
        }
    }
}