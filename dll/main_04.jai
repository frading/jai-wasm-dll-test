BaseNode :: struct {
    id : u32;
    value: float64;
    driversCount:DRIVERS_COUNT;
    count:DRIVERS_COUNT = INIT_DRIVERS_COUNT;
}
DRIVERS_COUNT :Type:#type u8;
INIT_DRIVERS_COUNT :DRIVERS_COUNT: 17;

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