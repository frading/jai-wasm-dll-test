
#program_export "compute2"
compute :: (node: MyNode, other: OtherStruct)->u8 {
    return 0;//node.id;
}

// MyNode :: u8;
MyNode :: struct {
    id: u8;
}

OtherStruct :: struct {
    id: u8;
}