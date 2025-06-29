import hxd.snd.Channel;
import hxd.res.Sound;

class SoundManager {
	static var _instance:SoundManager = null;

	public static function getInstance() {
		if (_instance == null) {
			_instance = new SoundManager();
		}
		return _instance;
	}

	var introResource:Sound;
	var introMusic:Channel;
	var music = new Array<Channel>();
	var musicResource = new Array<Sound>();
	var successRes:Sound;

	private function new() {
		// If your audio file is named 'my_music.mp3'
	}

	public function loadMusic() {
		// If we support mp3 we have our sound
		if (hxd.res.Sound.supportedFormat(Wav)) {
			#if hl
			successRes = hxd.Res.sound.success;
			#end
		}
		if (hxd.res.Sound.supportedFormat(OggVorbis)) {
			#if hl
			introResource = hxd.Res.sound.intro;
			musicResource.push(hxd.Res.sound.track_00);
			musicResource.push(hxd.Res.sound.track_01);
			musicResource.push(hxd.Res.sound.track_02);
			musicResource.push(hxd.Res.sound.track_03);
			musicResource.push(hxd.Res.sound.track_04);
			musicResource.push(hxd.Res.sound.track_05);
			#end
		} else if (hxd.res.Sound.supportedFormat(Mp3)) {
			#if js
			introResource = hxd.Res.sound.intro;
			successRes = hxd.Res.sound.success;
			musicResource.push(hxd.Res.sound.track_00);
			musicResource.push(hxd.Res.sound.track_01);
			musicResource.push(hxd.Res.sound.track_02);
			musicResource.push(hxd.Res.sound.track_03);
			musicResource.push(hxd.Res.sound.track_04);
			musicResource.push(hxd.Res.sound.track_05);
			#end
		}
	}

	public function playTitleMusic() {
		if (introResource == null) {
			loadMusic();
		}

		// Play the music and loop it
		introMusic = introResource.play(true, 1);
	}

	public function success() {
		successRes.play(false, 1);
	}

	public function startMusic() {
		if (musicResource == null) {
			loadMusic();
		}

		for (resource in musicResource) {
			var c = resource.play(true, 0);
			music.push(c);
		}
	}

	public function turnOnTrack(sceneId:Int) {
		if (music[sceneId] == null)
			return;

		music[sceneId].fadeTo(1, .1);
	}

	public function stopMusic() {
		introMusic.fadeTo(0, .5, function() {
			introMusic.stop();
		});

		for (track in music) {
			track.fadeTo(0, .33);
		}
	}
}
