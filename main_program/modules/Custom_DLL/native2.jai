// auto generated
MyNode :: struct {
    id: u8;
}
Truck :: struct {
    speed: float;
    driversCount:DRIVERS_COUNT;
}
OtherStruct :: struct {
    id: u8;
    t: Truck;
}

compute :: (node: MyNode, other: OtherStruct) -> DRIVERS_COUNT  #foreign;
// end
