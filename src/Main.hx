import hxd.res.Font;
import h2d.Text;
import hxd.Math;
import hxd.Timer;
import h3d.Engine;
import h2d.Bitmap;
import h2d.Tile;
import h2d.Flow.FlowAlign;
import hxyarn.dialogue.OptionSet;
import hxd.Key;
import h2d.Text.Align;
import h2d.HtmlText;
import hxyarn.dialogue.Line;
import hxyarn.dialogue.Dialogue.HandlerExecutionType;

class Main extends hxd.App {
	var dialogue:DialogueManager;
	var options:OptionSet = null;
	var backgrounds:Array<Tile>;
	var bgIndex = 8;
	var bg:Bitmap;
	var currentLine = null;
	var charactersPerSecond = 30;
	var progressLength:Int;
	var progress:Int = 0;
	var textElapsed:Float = 0;
	var text:HtmlText;
	var continueText:Text;
	var firstFrame = true;

	var onTitle = true;
	var textBox:Bitmap;

	override function init() {
		// Heaps resources
		#if (hl && debug)
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end

		var ctx = Engine.getCurrent();
		ctx.backgroundColor = 0x181425;

		var width = 800;
		var height = 600;

		s2d.scaleMode = ScaleMode.LetterBox(width, height);

		var bgWidth = 256;
		var bgHeight = 224;

		var backgroundTile = hxd.Res.images.scenes.toTile();
		backgrounds = new Array<Tile>();

		for (y in 0...3) {
			for (x in 0...3) {
				var t = backgroundTile.sub(x * bgWidth, y * bgHeight, bgWidth, bgHeight);
				if (t != null) {
					backgrounds.push(t);
				}
			}
		}

		bg = new Bitmap(backgrounds[bgIndex], s2d);
		bg.setScale(height / bgHeight);
		bg.x = (width / 2) - (bg.getSize().width / 2);

		textBox = new h2d.Bitmap(Tile.fromColor(0x000000, width - 32, Std.int(height / 2.5) - 32, .6), s2d);
		textBox.width = width - 32;
		textBox.height = Std.int(height / 2.5) - 32;
		textBox.x = 16;
		textBox.y = height - (height / 2.5) + 16;

		var flow = new h2d.Flow(textBox);
		flow.borderWidth = 8;
		flow.borderHeight = 8;
		flow.padding = 16;
		flow.horizontalAlign = FlowAlign.Left;
		flow.verticalAlign = FlowAlign.Top;
		flow.maxWidth = Std.int(textBox.width) - 8;
		flow.maxHeight = Std.int(textBox.height) - 8;

		text = new HtmlText(hxd.Res.fonts.lekton.toFont(), flow);

		text.textAlign = Align.Left;
		text.setScale(1);
		text.text = "";
		text.maxWidth = flow.maxWidth - 32;

		continueText = new Text(hxd.Res.fonts.lekton.toFont(), textBox);
		continueText.setScale(.8);
		continueText.text = "Press space to continue";
		continueText.x = textBox.width - 8 - (continueText.textWidth * .8);
		continueText.y = textBox.height - (continueText.textHeight * .8);
		continueText.visible = false;

		textBox.visible = false;

		dialogue = new DialogueManager();
		dialogue.lineHandlerCallback = function(line:Line):HandlerExecutionType {
			var textString = dialogue.getComposedTextForLine(line);
			currentLine = textString;
			progress = 0;
			progressLength = textString.length;

			text.text = "";
			firstFrame = true;
			textElapsed = 0;

			return HandlerExecutionType.ContinueExecution;
		}
		dialogue.optionHandlerCallback = function(options:OptionSet) {
			continueText.visible = false;
			this.options = options;
			text.text = "";
			var optionText = new Array<String>();

			for (option in options.options) {
				var textString = dialogue.getComposedTextForLine(option.line);
				optionText.push(textString);
				if (text.text == "") {
					text.text = '(${option.id + 1}) $textString';
				} else {
					text.text = text.text + '<br/>(${option.id + 1}) $textString';
				}
			}
		}

		dialogue.dialogue.nodeCompleteHandler = function(nodeName:String) {
			if (nodeName == "Promotion") {
				bg.visible = false;
				return;
			}

			bgIndex++;
			if (bgIndex < backgrounds.length) {
				bg.tile = backgrounds[bgIndex];
			} else {
				bg.visible = false;
			}
		}
	}

	function startGame() {
		onTitle = false;
		dialogue.runNode("WakeUp");
		textBox.visible = true;
		bg.tile = backgrounds[0];
		bgIndex = 0;
		onTitle = false;
	}

	override function update(dt:Float) {
		super.update(dt);

		if (onTitle && Key.isPressed(Key.SPACE)) {
			startGame();
		}

		if (onTitle) {
			return;
		}

		if (currentLine != null && progress < progressLength) {
			textElapsed += Timer.elapsedTime;
			progress = Math.floor(textElapsed * charactersPerSecond);
			text.text = text.getTextProgress(currentLine, progress);

			if (progress >= progressLength) {
				currentLine = null;
				continueText.visible = true;
			}
		}

		if (!firstFrame && options == null && Key.isPressed(Key.SPACE)) {
			if (progress < progressLength) {
				progress = progressLength;
				text.text = currentLine;
				continueText.visible = true;
			} else {
				dialogue.resume();
				continueText.visible = false;
			}
		}

		if (firstFrame) {
			firstFrame = false;
		}

		if (options != null) {
			if (Key.isPressed(Key.NUMBER_1)) {
				dialogue.dialogue.setSelectedOption(0);
				options = null;
				dialogue.resume();
			} else if (options.options.length > 1 && Key.isPressed(Key.NUMBER_2)) {
				dialogue.dialogue.setSelectedOption(1);
				options = null;
				dialogue.resume();
			} else if (options.options.length > 2 && Key.isPressed(Key.NUMBER_3)) {
				dialogue.dialogue.setSelectedOption(2);
				options = null;
				dialogue.resume();
			}
		}
	}

	static function main() {
		new Main();
	}
}
