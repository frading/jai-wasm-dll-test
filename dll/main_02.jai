ExternalStruct :: struct {
    a:u8;
}

MyNode :: struct {
    // type
    // myType: Type;
    // // bool
    // active:bool;
    // // integer
    // id: u8;
    // // float
    // f: float;
    // f32: float32;
    // f64: float64;
    // // string
    // name:string;

    // external: ExternalStruct;
    InternalStruct :: struct {
        a:u8;
    }
    internal: InternalStruct;
}

#program_export
compute :: (node: MyNode)->u8 {
    return 0;//node.id;
}