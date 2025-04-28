BaseNode :: struct {
    id : u32;
    value: float64;
    driversCount:DRIVERS_COUNT;
    count:DRIVERS_COUNT = INIT_DRIVERS_COUNT;
    wId:WorldObjectUniqueId;
}
DRIVERS_COUNT :Type:#type u8;
INIT_DRIVERS_COUNT :DRIVERS_COUNT: 17;
WorldObjectUniqueId :Type:#type s64;

NodeInputIndex :Type:#type u8;
NodeInputsCount :Type:#type NodeInputIndex;
InputCloneStaticProp :: struct {
	clone: bool=true;
	clones: [2]bool=.[true,true];
	overridable: bool=false;
}
RecyclingMethod :: enum u8 {
	IF_INPUT_CLONED :: 0;
	ALWAYS;
	NEVER;
}
NodeContext :: enum u8 {
	ANY		:: 0;
	ROOT	:: 1;
	GEOMETRY:: 2;
	MATERIAL:: 3;
	TEXTURE	:: 4;
	CPU		:: 5; // maybe rename ENTITY
	WGSL	:: 6;
	ACTOR	:: 7; // could be the same as CPU/ENTITY
	AUDIO	:: 8;
	RENDER	:: 9;
};

GeoNode :: struct (
	geoTypeName:string,
	GeoNodeType: Type,
	GeoParamsType: Type,
	inputs:[2]NodeInputsCount,
	geoInputCloneStatic: InputCloneStaticProp=.{},
	$geoRecyclingMethod: RecyclingMethod=.IF_INPUT_CLONED,
	geoAsync:bool=false
	){
	#as using baseNode: BaseNode(
		geoTypeName,
		NodeContext.GEOMETRY,
		GeoNodeType,
		GeoParamsType,
		minInputsCount=inputs[0],
		maxInputsCount=inputs[1],
		inputCloneStatic=geoInputCloneStatic,
		recyclingMethod=geoRecyclingMethod,
		async=geoAsync,
	);
};

#program_export
setNode :: (index:u8, node:BaseNode) {

}

#program_export
computeSum :: () -> float64 {
    return 17;
}

#program_export
openWindow :: () {
    SDL_Init(SDL_INIT_VIDEO);

    // Create an application window with the following settings:
    window := SDL_CreateWindow("An SDL2 window",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN);

    // Check that the window was successfully created
    if window == null {
        // In the case that the window could not be made...
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return;
    }

    exit := false;
    while !exit {
        event : SDL_Event;
        while SDL_PollEvent(*event) {
            if event.type == {
                case SDL_QUIT;
                    exit = true;
                case SDL_KEYUP;
                    if event.key.keysym.sym == SDLK_ESCAPE exit = true;
            }
        }

        SDL_Delay(1);
    }

    // Close and destroy the window
    SDL_DestroyWindow(window);

    // Clean up
    SDL_Quit();
}

#import "Basic";
#import "SDL";
#import "String";