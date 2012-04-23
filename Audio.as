package
{
	import net.flashpunk.*;
	
	public class Audio
	{
		[Embed(source="audio/split.mp3")] public static const Sfx_split:Class;
		[Embed(source="audio/yay.mp3")] public static const Sfx_yay:Class;
		
		private static var sounds:Object = {};
		
		public static function play (sound:String):void
		{
			if (! sounds[sound]) {
				var embed:Class = Audio["Sfx_" + sound];
				
				if (embed) {
					sounds[sound] = new Sfx(embed);
				}
			}
			
			if (sounds[sound]) {
				sounds[sound].play();
			}
		}
	}
}
