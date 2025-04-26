// auto generated

DRIVERS_COUNT :Type:#type u8;
BaseNode :: struct {
    id : u32;
    value: float64;
    driversCount:DRIVERS_COUNT;
    count:DRIVERS_COUNT = INIT_DRIVERS_COUNT;
}

openWindow :: ()  #foreign;

computeSum :: () -> float64  #foreign;

setNode :: (index:u8, node:BaseNode)  #foreign;
// end
