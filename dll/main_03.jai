
#program_export
compute :: (node: MyNode, other: OtherStruct) -> DRIVERS_COUNT {
    return 0;//node.id;
}

// MyNode :: u8;
MyNode :: struct {
    id: u8;
}

OtherStruct :: struct {
    id: u8;
    t: Truck;
}

ThisNotNeeded :: struct {
    id: u8;
    a: string;
}

Truck :: struct {
    speed: float;
    driversCount:DRIVERS_COUNT;
}

DRIVERS_COUNT :: #type u8;