import h2d.Mask;
import h2d.Bitmap;
import h2d.Object;

class Bar extends Object {
	public var innerBarMaxWidth(get, never):Float;
	public var innerBarHeight(get, never):Float;
	public var outerWidth(get, never):Float;
	public var outerHeight(get, never):Float;

	var bg:Bitmap;
	var bar:Bitmap;
	var barMask:Mask;
	var curValue:Float;
	var curMax:Float;
	var padding:Int;

	public function new(wid:Int, hei:Int, ?parent:Object) {
		super(parent);

		curValue = 0;
		curMax = 1;

		var tiles = hxd.Res.images.success_bar.toTile().split(2);

		bg = new Bitmap(tiles[0], this);
		barMask = new h2d.Mask(0, 0, this);
		bar = new Bitmap(tiles[1], barMask);

		setSize(wid, hei, 1);
	}

	inline function get_innerBarMaxWidth()
		return outerWidth - padding * 2;

	inline function get_innerBarHeight()
		return outerHeight - padding * 2;

	inline function get_outerWidth()
		return bg.width;

	inline function get_outerHeight()
		return bg.height;

	public function setSize(wid:Int, hei:Int, pad:Int) {
		padding = pad;

		bar.setPosition(padding, padding);

		bg.width = wid + padding * 2;
		bar.width = wid;
		barMask.width = 0;

		bg.height = hei + padding * 2;
		bar.height = hei;
		barMask.height = hei;
	}

	public function set(v:Float, max:Float) {
		curValue = v;
		curMax = max;
		renderBar();
	}

	function renderBar() {
		bar.visible = curValue > 0;
		barMask.width = Math.floor(innerBarMaxWidth * (curValue / curMax));
	}
}
