package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import com.adobe.crypto.*;
	
	public class LevelData
	{
		public static const VERSION:String = "A";
		
		public var tiles:Tilemap;
		
		public var md5:String;
		
		public static var levels:Array;
		
		public static function readLevelPack (list:String):void
		{
			levels = [];
			
			list = list.replace(/\s+$/, ''); // trim end of string
			
			var parts:Array = list.split("\n");
			
			for each (var levelInfo:String in parts) {
				if (levelInfo.length == 0) {
					continue;
				}
				
				var data:LevelData = new LevelData;
				data.fromString(levelInfo);
				
				levels.push(data);
			}
		}
		
		/*public static function writeLevelPack ():String
		{
			var data:String = "LEVELPACK VERSION 1";
			
			data += "\n\n";
			
			var grid:BitmapData = layout;
			
			data += grid.width + "\t" + grid.height + "\n";
			
			for (var j:int = 0; j < grid.height; j++) {
				for (var i:int = 0; i < grid.width; i++) {
					data += grid.getPixel(i, j) + "\t";
				}
				data += "\n";
			}
			
			data += "\n";
			
			for each (var level:Object in levels) {
				data += level.name + "\t" + level.data + "\n";
			}
			
			return data;
		}*/
		
		public function fromString (data:String):void
		{
			if (! tiles) {
				tiles = new Tilemap(Editor.EditTilesGfx, 640, 480, 32, 32);
			}
			
			md5 = MD5.hash(data);
			
			if (data.length == 0) return;
			
			var version:String = data.charAt(0);
			
			data = data.substring(1);
			
			var i:int;
			var j:int;
			var tile:uint;
			var bytes:ByteArray;
			
			bytes = Base64.decode(data);
			
			//bytes.writeUTFBytes(data);
			
			bytes.uncompress();
			
			for (i = 0; i < tiles.columns; i++) {
				for (j = 0; j < tiles.rows; j++) {
					tile = bytes.readByte();
					
					tiles.setTile(i, j, tile);
				}
			}
		}
		
		public function toString ():String
		{
			var i:int;
			var j:int;
			var tile:uint;
			var bytes:ByteArray = new ByteArray;
			
			for (i = 0; i < tiles.columns; i++) {
				for (j = 0; j < tiles.rows; j++) {
					tile = tiles.getTile(i, j);
					
					bytes.writeByte(tile);
				}
			}
			
			bytes.compress();
			
			return VERSION + Base64.encode(bytes);
		}
		
		/*private static function writeArray (bytes:ByteArray, array:Array):void
		{
			bytes.writeByte(array.length);
			
			for each (var item:Point in array) {
				var ix:int = Math.round(item.x / Main.TW);
				var iy:int = Math.round(item.y / Main.TW);
				
				bytes.writeByte(ix + iy * 11);
			}
		}
		
		private static function readArray (bytes:ByteArray):Array
		{
			var array:Array = [];
			
			var l:int = bytes.readByte();
			
			for (var i:int = 0; i < l; i++) {
				var posID:int = bytes.readByte();
				
				var point:Point = new Point();
				point.x = int(posID % 11) * Main.TW;
				point.y = int(posID / 11) * Main.TW;
				
				array.push(point);
			}
			
			return array;
		}*/
	}
}

