import h2d.Bitmap;
import h2d.Graphics;
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

	var onTitle = true;
	var textBox:Bitmap;

	override function init() {
		// Heaps resources
		#if (hl && debug)
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end

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

		textBox = new h2d.Bitmap(Tile.fromColor(0x4A0E99, width - 32, Std.int(height / 2) - 32, .7), s2d);
		textBox.width = width - 32;
		textBox.height = Std.int(height / 2) - 32;
		textBox.x = 16;
		textBox.y = (height / 2) + 16;

		var flow = new h2d.Flow(textBox);
		flow.borderWidth = 8;
		flow.borderHeight = 8;
		flow.padding = 16;
		flow.horizontalAlign = FlowAlign.Left;
		flow.verticalAlign = FlowAlign.Top;
		flow.maxWidth = Std.int(textBox.width) - 8;
		flow.maxHeight = Std.int(textBox.height) - 8;

		var tf = new HtmlText(hxd.res.DefaultFont.get(), flow);

		tf.textAlign = Align.Left;
		tf.setScale(2);
		tf.text = "";
		tf.maxWidth = flow.maxWidth - 32;

		textBox.visible = false;

		dialogue = new DialogueManager();
		dialogue.lineHandlerCallback = function(line:Line):HandlerExecutionType {
			var text = dialogue.getComposedTextForLine(line);

			// Show text
			tf.text = text;
			trace(tf.textWidth);

			return HandlerExecutionType.ContinueExecution;
		}
		dialogue.optionHandlerCallback = function(options:OptionSet) {
			this.options = options;
			tf.text = "";
			var optionText = new Array<String>();

			for (option in options.options) {
				var text = dialogue.getComposedTextForLine(option.line);
				optionText.push(text);
				if (tf.text == "") {
					tf.text = '(${option.id + 1}) $text';
				} else {
					tf.text = tf.text + '<br/>(${option.id + 1}) $text';
				}
			}
		}

		dialogue.dialogue.nodeCompleteHandler = function(nodeName:String) {
			trace(nodeName + " completed");
			bgIndex++;
			if (bgIndex < backgrounds.length) {
				bg.tile = backgrounds[bgIndex];
			} else {
				bg.visible = false;
			}
		}
	}

	override function update(dt:Float) {
		super.update(dt);

		if (onTitle && Key.isPressed(Key.SPACE)) {
			onTitle = false;
			dialogue.runNode("WakeUp");
			textBox.visible = true;
			bg.tile = backgrounds[0];
			bgIndex = 0;
			onTitle = false;
		}

		if (onTitle) {
			return;
		}

		if (options == null && Key.isPressed(Key.SPACE)) {
			dialogue.resume();
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
