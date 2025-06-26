import hxyarn.dialogue.OptionSet;
import hxd.Key;
import h2d.Text.Align;
import hxyarn.dialogue.Line;
import hxyarn.dialogue.Dialogue.HandlerExecutionType;

class Main extends hxd.App {
    var dialogue:DialogueManager;
    var options:OptionSet = null;

    override function init() {
        s2d.scaleMode = ScaleMode.LetterBox(800, 600);
        s2d.setScale(2);

        // Heaps resources
		#if (hl && debug)
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end

        var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        tf.textAlign = Align.Left; 
        tf.setScale(1);
        tf.maxWidth = 600;
        tf.tileWrap = true;
        tf.text = "";

        dialogue = new DialogueManager();
        dialogue.lineHandlerCallback = function (line:Line):HandlerExecutionType {
            var text = dialogue.getComposedTextForLine(line);

            // Show text
            tf.text = text; 

            return HandlerExecutionType.ContinueExecution;
        }
        dialogue.optionHandlerCallback = function (options:OptionSet) {
            this.options = options;
            tf.text = "";
            var optionText = new Array<String>();

            for (option in options.options) {
                var text = dialogue.getComposedTextForLine(option.line);
                optionText.push(text);
                if (tf.text == "") {
                    tf.text = text;
                } else {
                    tf.text = tf.text + "\n" + text;
                }
            }
        }
        dialogue.runNode("WakeUp");
    }

    override function update(dt:Float) {
        super.update(dt);

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