

main :: () {
    print("main started\n");
    setNode(0, .{id=0, value=1.0});
    print("compute:%\n", computeSum());
    print("OK\n");
}

#scope_file

#import "Basic";
#import "Custom_DLL";
