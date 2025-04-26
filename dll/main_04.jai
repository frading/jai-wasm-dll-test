BaseNode :: struct {
    id : u32;
    value: float64;
}

#program_export
setNode :: (index:u8, node:BaseNode) {

}

#program_export
computeSum :: () -> float64 {
    return 17;
}