import hxyarn.program.Value;
import hxyarn.program.types.BuiltInTypes;
import hxyarn.dialogue.Dialogue;
import hxyarn.dialogue.VariableStorage.MemoryVariableStore;
import hxyarn.dialogue.StringInfo;
import hxyarn.dialogue.Line;
import hxyarn.dialogue.Command;
import hxyarn.dialogue.OptionSet;
import hxyarn.compiler.Compiler;
import hxyarn.compiler.CompilationJob;

class DialogueManager {
	public var dialogue:Dialogue;

	var storage = new MemoryVariableStore();
	var stringTable:Map<String, StringInfo>;

	public var lineHandlerCallback:LineHandler;
	public var optionHandlerCallback:OptionsHandler;

	public function new() {
		dialogue = new Dialogue(new MemoryVariableStore());

		dialogue.library.registerFunction("success", 0, function(values:Array<Value>) {
			trace("success");
			dialogue.resume();
			return "Success +";
		}, BuiltInTypes.string);

		dialogue.logDebugMessage = this.logDebugMessage;
		dialogue.logErrorMessage = this.logErrorMessage;
		dialogue.lineHandler = this.lineHandler;
		dialogue.optionsHandler = this.optionsHandler;
		dialogue.commandHandler = this.commandHandler;
		dialogue.nodeCompleteHandler = this.nodeCompleteHandler;
		dialogue.nodeStartHandler = this.nodeStartHandler;
		dialogue.dialogueCompleteHandler = this.dialogueCompleteHandler;

		this.loadFromString([hxd.Res.text.start.entry.getText()], [hxd.Res.text.start.name]);
	}

	public function loadFromString(text:Array<String>, fileNames:Array<String>) {
		var job = CompilationJob.createFromStrings(text, fileNames, dialogue.library);
		var compiler = Compiler.compile(job);
		stringTable = compiler.stringTable;

		dialogue.addProgram(compiler.program);
	}

	public function runNode(nodeName:String) {
		dialogue.setNode(nodeName);
		dialogue.resume();
	}

	public function unload() {
		dialogue.unloadAll();
	}

	public function resume() {
		dialogue.resume();
	}

	public function logDebugMessage(message:String):Void {}

	public function logErrorMessage(message:String):Void {}

	public function lineHandler(line:Line):HandlerExecutionType {
		if (this.lineHandlerCallback != null) {
			this.lineHandlerCallback(line);
		}

		return HandlerExecutionType.ContinueExecution;
	}

	public function optionsHandler(options:OptionSet) {
		if (this.optionHandlerCallback != null) {
			this.optionHandlerCallback(options);
		}
	}

	public function getComposedTextForLine(line:Line):String {
		var substitutedText = Dialogue.expandSubstitutions(stringTable[line.id].text, line.substitutions);

		var markup = dialogue.parseMarkup(substitutedText);

		return markup.text;
	}

	public function commandHandler(command:Command) {
		trace(command.text + " command");
		dialogue.resume();
	}

	public function nodeCompleteHandler(nodeName:String) {
		trace(nodeName + " completed");
	}

	public function nodeStartHandler(nodeName:String) {
		trace(nodeName + " started");
	}

	public function dialogueCompleteHandler() {
		trace("Dialogue Completed");
	}
}
