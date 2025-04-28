// auto generated

INIT_DRIVERS_COUNT :DRIVERS_COUNT: 17;

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
}

RecyclingMethod :: enum u8 {
	IF_INPUT_CLONED :: 0;
	ALWAYS;
	NEVER;
}

EditorOnAfterDeleteCallback :Type: #type (nodesScene: *NodesScene);

WorldObjectUniqueId :Type:#type s64;

DRIVERS_COUNT :Type:#type u8;

DEFAULT_EDITOR_ON_AFTER_DELETE :EditorOnAfterDeleteCallback: (nodesScene: *NodesScene) {}
BaseNode :: struct {
    id : u32;
    value: float64;
    driversCount:DRIVERS_COUNT;
    count:DRIVERS_COUNT = INIT_DRIVERS_COUNT;
    wId:WorldObjectUniqueId;
}
NodesScene :: struct {
}
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
}

openWindow :: ()  #foreign;

computeSum :: () -> float64  #foreign;

setNode :: (index:u8, node:BaseNode)  #foreign;
// end
