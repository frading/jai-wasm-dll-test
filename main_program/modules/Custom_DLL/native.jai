BaseNode :: struct {
    id : u32;
    value: float64;
}
setNode :: (index:u8, node:BaseNode) #elsewhere Custom_DLL;
computeSum :: () -> float64 #elsewhere Custom_DLL;
#scope_file

Custom_DLL :: #library "native/custom_dll";