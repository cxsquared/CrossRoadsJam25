import h2d.Particles;
import hxyarn.dialogue.Command;
import h2d.Interactive;
import h2d.Flow;
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
	var optionInteractions = new Array<Interactive>();
	var optionFlow:Flow;

	var lineFlow:Flow;
	var currentLine = null;
	var charactersPerSecond = 30;
	var progressLength:Int;
	var progress:Int = 0;
	var textElapsed:Float = 0;
	var text:HtmlText;

	var backgrounds:Array<Tile>;
	var bgIndex = 8;
	var bg:Bitmap;
	var continueText:Text;
	var firstFrame = true;

	var successText:Text;
	var successTextOnLength:Float = 1;
	var successTextOffLength:Float = .75;
	var successTextTimer:Float = 0;

	var successBar:Bar;
	var success:Float = 0;
	var successIncrement:Float = 1 / 9;
	var targetSuccess:Float = 0;
	var successShowLength = 2.5;
	var successShowTime:Float = 0;
	var showingSuccess = false;

	var successParticles:Particles;

	var nextSceneTimerLength:Float = 1;
	var nextSceneTimer:Float = 0;
	var nextSceneTrigger = false;

	var end = false;
	var endText:Text;
	var onTitle = true;
	var textBox:Bitmap;

	var width = 800;
	var height = 600;
	var currentTracksToBeOn = new Array<Array<Int>>();
	var currentTrackIndex = 0;

	override function init() {
		// Heaps resources
		#if (hl && debug)
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end

		currentTracksToBeOn.push([0]);
		currentTracksToBeOn.push([0, 1]);
		currentTracksToBeOn.push([0, 1, 2]);
		currentTracksToBeOn.push([0, 1, 2, 3]);
		currentTracksToBeOn.push([0, 1, 2, 4]);
		currentTracksToBeOn.push([0, 1, 2, 4, 5]);
		currentTracksToBeOn.push([1, 2]);
		currentTracksToBeOn.push([1, 2, 4, 5]);
		currentTracksToBeOn.push([1]);

		var ctx = Engine.getCurrent();
		ctx.backgroundColor = 0x181425;

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

		lineFlow = new h2d.Flow(textBox);
		lineFlow.borderWidth = 8;
		lineFlow.borderHeight = 8;
		lineFlow.padding = 16;
		lineFlow.horizontalAlign = FlowAlign.Left;
		lineFlow.verticalAlign = FlowAlign.Top;
		lineFlow.maxWidth = Std.int(textBox.width) - 8;
		lineFlow.maxHeight = Std.int(textBox.height) - 8;

		var textFont = hxd.Res.fonts.lekton.toFont();

		text = new HtmlText(textFont, lineFlow);

		text.textAlign = Align.Left;
		text.setScale(1);
		text.text = "";
		text.maxWidth = lineFlow.maxWidth - 32;

		optionFlow = new Flow(textBox);
		optionFlow.borderWidth = 8;
		optionFlow.borderHeight = 8;
		optionFlow.padding = 16;
		optionFlow.verticalSpacing = 8;
		optionFlow.horizontalAlign = FlowAlign.Left;
		optionFlow.verticalAlign = FlowAlign.Top;
		optionFlow.maxWidth = Std.int(textBox.width) - 8;
		optionFlow.maxHeight = Std.int(textBox.height) - 8;
		optionFlow.layout = FlowLayout.Vertical;
		optionFlow.visible = false;

		for (i in 0...3) {
			var t = new Text(textFont, optionFlow);
			t.textAlign = Align.Left;
			t.setScale(1);
			t.text = "";
			t.maxWidth = lineFlow.maxWidth - 32;

			var i = new Interactive(1, 1, t);
			i.visible = false;
			optionInteractions.push(i);
		}

		continueText = new Text(textFont, textBox);
		continueText.setScale(.8);
		continueText.text = "Press space to continue";
		continueText.x = textBox.width - 8 - (continueText.textWidth * .8);
		continueText.y = textBox.height - (continueText.textHeight * .8);
		continueText.visible = false;

		textBox.visible = false;

		successBar = new Bar(Math.floor(width * .75), Math.floor(100), s2d);
		successBar.x = width / 2 - successBar.outerWidth / 2;
		successBar.y = height / 2 - successBar.outerHeight / 2;
		successBar.set(0, 1);
		successBar.visible = false;

		successText = new Text(textFont, s2d);
		successText.text = "SUCCESS";
		successText.setScale(1.5);
		moveSuccessText();
		successText.visible = false;
		successText.dropShadow = {
			dx: .8,
			dy: .8,
			alpha: .75,
			color: 0x000000
		};

		successParticles = new Particles(s2d);
		successParticles.load(haxe.Json.parse(hxd.Res.particles.success.entry.getText()), hxd.Res.particles.success.entry.path);
		successParticles.y = height;
		successParticles.visible = false;
		successParticles.getGroup('Left').speed = -400;
		successParticles.getGroup('Right').speed = -400;

		dialogue = new DialogueManager();

		dialogue.lineHandlerCallback = function(line:Line):HandlerExecutionType {
			textBox.visible = true;
			lineFlow.visible = true;
			optionFlow.visible = false;
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
			textBox.visible = true;
			lineFlow.visible = false;
			continueText.visible = false;
			optionFlow.visible = true;

			clearOptions();

			this.options = options;
			var optionText = new Array<String>();

			for (option in options.options) {
				var t = cast(optionFlow.getChildAt(option.id), Text);
				var textString = dialogue.getComposedTextForLine(option.line);
				optionText.push(textString);
				t.text = '(${option.id + 1}) $textString';

				var i = optionInteractions[option.id];
				i.width = t.textWidth;
				i.height = t.textHeight;
				i.visible = true;
				i.onClick = function(e:hxd.Event) {
					if (options != null && (e.keyCode == Key.MOUSE_LEFT || e.button == 0)) {
						selectOption(option.id);
						i.onClick = null;
					}
				}
			}
		}

		dialogue.dialogue.nodeStartHandler = function(nodeName:String) {
			SoundManager.getInstance().stopMusic();
			currentTrackIndex++;
			turnOnTracks();

			if (nodeName == "Future") {
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

		dialogue.dialogue.commandHandler = function(command:Command) {
			if (command.text == "success") {
				SoundManager.getInstance().stopMusic();
				SoundManager.getInstance().success();
				showingSuccess = true;
				targetSuccess = success + successIncrement;
				successShowTime = 0;
				successBar.visible = true;
				successText.visible = true;
				moveSuccessText();
				successTextTimer = 0;
				successParticles.visible = true;
				successParticles.getGroup('Left').speed = 400;
				successParticles.getGroup('Right').speed = 400;
				textBox.visible = false;
				optionFlow.visible = false;
			}
		};

		dialogue.dialogue.nodeCompleteHandler = function(nodeName:String) {
			textBox.visible = false;
			optionFlow.visible = false;
		}

		dialogue.dialogue.dialogueCompleteHandler = function() {
			bg.visible = false;
			textBox.visible = false;
			optionFlow.visible = false;
			options = null;
			end = true;

			endText = new Text(textFont, s2d);
			endText.text = "The feature freaks me out...";
			endText.x = width / 2 - endText.textWidth / 2;
			endText.y = height / 2 - endText.textHeight / 2;

			turnOnTracks();
		};

		SoundManager.getInstance().loadMusic();
		SoundManager.getInstance().playTitleMusic();
	}

	function startGame() {
		SoundManager.getInstance().stopMusic();
		SoundManager.getInstance().startMusic();
		currentTrackIndex = -1;
		onTitle = false;
		dialogue.runNode("WakeUp");
		textBox.visible = true;
		bg.tile = backgrounds[0];
		bgIndex = 0;
		onTitle = false;
		bg.visible = true;
	}

	function moveSuccessText() {
		successText.x = 16 + (width - successText.textWidth - 32) * Math.random();
		successText.y = 16 + (height - successText.textHeight - 32) * Math.random();
	}

	function turnOnTracks() {
		for (i in currentTracksToBeOn[currentTrackIndex]) {
			SoundManager.getInstance().turnOnTrack(i);
		}
	}

	function clearOptions() {
		for (i in 0...3) {
			var t = cast(optionFlow.getChildAt(i), Text);
			t.text = "";
			var i = optionInteractions[i];
			i.visible = false;
			i.onClick = null;
		}

		options = null;
	}

	function selectOption(id:Int) {
		dialogue.dialogue.setSelectedOption(id);
		options = null;
		optionFlow.visible = false;
		textBox.visible = false;
		dialogue.resume();
		clearOptions();
	}

	function toTitle() {
		SoundManager.getInstance().stopMusic();
		SoundManager.getInstance().playTitleMusic();

		bg.tile = backgrounds[backgrounds.length - 1];
		bg.visible = true;
		endText.remove();
		optionFlow.visible = false;
		textBox.visible = false;
		onTitle = true;
		end = false;
	}

	override function update(dt:Float) {
		super.update(dt);

		if (onTitle && (Key.isPressed(Key.SPACE) || Key.isPressed(Key.MOUSE_LEFT))) {
			startGame();
		}

		if (onTitle) {
			return;
		}

		if (end) {
			if (Key.isPressed(Key.SPACE) || Key.isPressed(Key.MOUSE_LEFT)) {
				toTitle();
			}
			return;
		}

		if (nextSceneTrigger || showingSuccess) {
			successTextTimer += Timer.elapsedTime;

			if (successText.visible && successTextTimer > successTextOnLength) {
				successText.visible = false;
				successTextTimer = 0;
			} else if (successTextTimer > successTextOffLength) {
				moveSuccessText();
				successText.visible = true;
				successTextTimer = 0;
			}
		}

		if (nextSceneTrigger) {
			nextSceneTimer += Timer.elapsedTime;
			if (nextSceneTimer > nextSceneTimerLength) {
				dialogue.resume();
				nextSceneTrigger = false;
				successBar.visible = false;
				successText.visible = false;
				successParticles.visible = false;
				successParticles.getGroup('Left').speed = -400;
				successParticles.getGroup('Right').speed = -400;
			}

			return;
		}

		if (showingSuccess) {
			successShowTime += Timer.elapsedTime;
			success = Math.max(0, targetSuccess - successIncrement) + (successIncrement * (successShowTime / successShowLength));
			successBar.set(Math.min(success, 1), 1);

			if (successShowTime >= successShowLength) {
				success = targetSuccess;
				showingSuccess = false;
				nextSceneTimer = 0;
				nextSceneTrigger = true;
			}

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

		if (!firstFrame && options == null && (Key.isPressed(Key.SPACE) || Key.isPressed(Key.MOUSE_LEFT))) {
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
				selectOption(0);
			} else if (options.options.length > 1 && Key.isPressed(Key.NUMBER_2)) {
				selectOption(1);
			} else if (options.options.length > 2 && Key.isPressed(Key.NUMBER_3)) {
				selectOption(2);
			}
		}
	}

	static function main() {
		new Main();
	}
}
