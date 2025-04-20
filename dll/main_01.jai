
BaseNodeRaw :: struct {
    id : u32;
    value: float64;
}

OtherStruct :: struct {
    min: float;
    max: float;
    step:u8 = 2;
}

Super :: struct {
    really: float;
}
NodeWithRange :: struct {
    #as using baseNode: BaseNodeRaw;
}

CoreGraphId :: u8;
CoreGraphNodeId :: u32;

CoreGraphNode :: struct {
	graphNodeId: CoreGraphNodeId;
	graphId: CoreGraphId;
}
CoreGraphNodeAny :: CoreGraphNode;

NodeId :: u32;
NodeIdOrNone :: s32;
NodeInputIndex :: u8;
NodeInputsCount :: NodeInputIndex;
NodeInputsCountBounds :: struct {
	min: NodeInputsCount;
	max: NodeInputsCount;
}

NodeContext :: enum u8 {
	ANY		:: 0;
	ROOT	:: 1;
	GEOMETRY:: 2;
	MATERIAL:: 3;
	TEXTURE	:: 4;
	CPU		:: 5;
	WGSL	:: 6;
	ACTOR	:: 7;
	AUDIO	:: 8;
	RENDER	:: 9;
};
InputCloneStaticProp :: struct {
	clone: bool=true;
	clones: [2]bool=.[true,true];
	overridable: bool=false;
}
InputCloneDynamicProp :: struct {
	noClone:bool=false;
}
RecyclingMethod :: enum u8 {
	IF_INPUT_CLONED :: 0;
	ALWAYS;
	NEVER;
}
BaseNode :: struct (
	$typeName:string,
	$ctx: NodeContext,
	BaseNodeType: Type,
	$ParamsType: Type,
	$minInputsCount:NodeInputsCount,
	$maxInputsCount:NodeInputsCount,
	$inputCloneStatic: InputCloneStaticProp,
	$recyclingMethod: RecyclingMethod,
	$async:bool
	){
	#as using coreGraphNode: CoreGraphNode;
	type :Type=BaseNodeType;
	nodeId:NodeId;
	p:ParamsType;
	inputCloneDynamic: InputCloneDynamicProp;
}

BaseNodeAny :: BaseNode(
	"any",
	.ANY,
	Any,
	Any,
	minInputsCount=0,
	maxInputsCount=0,
	inputCloneStatic=.{},
	recyclingMethod=RecyclingMethod.NEVER,
	async=false,
);

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
GeoNodeAny :: GeoNode;
BoxGeoParams :: struct {
	test: float;
}
BoxGeoNode :: struct {
	#as using contextNode: GeoNode("box", BoxGeoNode, BoxGeoParams, inputs=.[0,1]);
};

#program_export
setNode :: (index:u8, node:BaseNodeRaw) {
    NODES[index] = node;
    updateNextNode(index);
}

#program_export
getNode :: (index:u8)->BaseNodeRaw {
    return NODES[index];
}

#program_export
computeSum :: (node:BoxGeoNode)->float64 {
    sum :float64= 0;
    for i:0..(NODES_COUNT-1) {
        sum += NODES[i].value;
    }
    return sum;
}

#scope_file

NODES_COUNT:u8: 5;
NODES:[NODES_COUNT]BaseNodeRaw;

updateNextNode :: (index:u8) {
    if index < NODES_COUNT-1 {
        NODES[index+1].value += NODES[index].value;
    }
}