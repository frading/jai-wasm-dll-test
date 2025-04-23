
ANSI_RESET := "\u001B[0m";
ANSI_BLACK := "\u001B[30m";
ANSI_RED := "\u001B[31m";
ANSI_GREEN := "\u001B[32m";
ANSI_YELLOW := "\u001B[33m";
ANSI_BLUE := "\u001B[34m";
ANSI_PURPLE := "\u001B[35m";
ANSI_CYAN := "\u001B[36m";
ANSI_WHITE := "\u001B[37m";
ANSI_BLACK_BACKGROUND := "\u001B[40m";
ANSI_RED_BACKGROUND := "\u001B[41m";
ANSI_GREEN_BACKGROUND := "\u001B[42m";
ANSI_YELLOW_BACKGROUND := "\u001B[43m";
ANSI_BLUE_BACKGROUND := "\u001B[44m";
ANSI_PURPLE_BACKGROUND := "\u001B[45m";
ANSI_CYAN_BACKGROUND := "\u001B[46m";
ANSI_WHITE_BACKGROUND := "\u001B[47m";

printColor :: (content:string, bgColor:string, newLine:bool){
	result := tprintColor(content, bgColor);
    if newLine {
        print("%\n", result);
    } else {
        print("%", result);
    }
}
tprintColor :: (content:string, bgColor:string) -> string {
	return tprint(
		"% % % %",
		bgColor,
		ANSI_BLACK,
		content,
		ANSI_RESET
	);
}

printRed :: (content:string, newLine:bool=true){
	printColor(content, ANSI_RED_BACKGROUND, newLine );
}
printYellow :: (content:string, newLine:bool=true){
	printColor(content, ANSI_YELLOW_BACKGROUND, newLine );
}
printGreen :: (content:string, newLine:bool=true){
	printColor(content, ANSI_GREEN_BACKGROUND, newLine );
}
printBlue :: (content:string, newLine:bool=true){
	printColor(content, ANSI_BLUE_BACKGROUND, newLine );
}
tprintYellow :: (content:string)->string{
	return tprintColor(content, ANSI_YELLOW_BACKGROUND );
}
tprintGreen :: (content:string)->string{
	return tprintColor(content, ANSI_GREEN_BACKGROUND );
}
tprintRed :: (content:string)->string{
	return tprintColor(content, ANSI_RED_BACKGROUND );
}

print_c :: (format: string, args: ..Any, to_standard_error := false) #expand {
	new_context: #Context;
	push_context new_context {
		print(format, ..args, to_standard_error);
	}
} @PrintLike