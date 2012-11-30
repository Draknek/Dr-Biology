package
{
	import net.flashpunk.*;
	
	public class Audio
	{
		[Embed(source="audio/split.mp3")] public static const Sfx_split:Class;
		[Embed(source="audio/yay.mp3")] public static const Sfx_yay:Class;
		[Embed(source="audio/music.mp3")] public static const Sfx_music:Class;
		
		private static var sounds:Object = {};
		
		public static var music:Sfx;
		
		public static function startMusic ():void
		{
			music = new Sfx(Sfx_music);
			music.loop();
		}
		
		public static function play (sound:String):void
		{
			if (! sounds[sound]) {
				var embed:Class = Audio["Sfx_" + sound];
				
				if (embed) {
					sounds[sound] = new Sfx(embed);
				}
			}
			
			if (sounds[sound]) {
				sounds[sound].play(0.4);
			}
		}
	}
}
