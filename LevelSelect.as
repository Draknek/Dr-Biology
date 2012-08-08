package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class LevelSelect extends World
	{
		public function LevelSelect ()
		{
			for (var i:int = 0; i < 12; i++) {
				addLevel(i);
			}
		}
		
		public function addLevel (i:int):void
		{
			var locked:Boolean = true;
			
			if (i == 0 || Main.so.data.completed[i]) {
				locked = false;
			}
			
			var button:Entity = new Entity;
			
			button.width = 10*12;
			button.height = 8*12;
			
			var spacingX:Number = (FP.width - button.width*4)/5;
			var spacingY:Number = (FP.height - button.height*3)/4;
			
			button.x = (i % 4) * (button.width + spacingX) + spacingX;
			button.y = int(i / 4) * (button.height + spacingY) + spacingY;
			
			button.layer = i + 1;
			
			var image:Image = new Image(getLevelImage(i, locked));
			
			image.scale = 1.0/3.0;
			
			button.graphic = image;
			
			if (locked) {
				var text:Text = new Text("LOCKED", button.x + button.width*0.5, button.y + button.height*0.5, {size: 30, color: 0x0});
				text.centerOO();
				addGraphic(text, -20);
			} else {
				button.type = "levelregion";
			}
			
			add(button);
			
			
		}
		
		public override function update ():void
		{
			Input.mouseCursor = "auto";
			super.update();
			
			var e:Entity = collidePoint("levelregion", mouseX, mouseY);
			
			if (e) {
				Input.mouseCursor = "button";
				
				if (Input.mousePressed) {
					FP.world = new Level(null, e.layer);
				}
			}
		}
		
		private static var imageCache:Vector.<BitmapData> = new Vector.<BitmapData>(24, true);
		
		private static function getLevelImage (i:int, locked:Boolean):BitmapData
		{
			var lookup:int = i;
			
			if (locked) {
				lookup += 12;
			}
			
			if (imageCache[lookup]) {
				return imageCache[lookup];
			}
			
			FP.randomSeed = i + 1;
			
			var w:int = 10*36;
			var h:int = 8*36;
			
			var bitmap:BitmapData = new BitmapData(w, h, true, 0x0);
			
			var data:LevelData = LevelData.levels[i];
			
			var tiles:Tilemap = data.tiles;
			
			var point:Point = new Point;
			
			Level.centerLevelMagic(tiles, point, 1, w, h);
			
			Draw.setTarget(bitmap, point);
			
			for (var i:int = 0; i < tiles.columns; i++) {
				for (var j:int = 0; j < tiles.rows; j++) {
					var tile:uint = tiles.getTile(i, j);
					
					if (tile == 0) continue;
					
					var x:int = i*Main.TW;
					var y:int = j*Main.TW;
					
					var image:Image;
					
					if (tile == 1) {
						var wall:Wall = new Wall(0,0);
						image = wall.image;
						//image.angle = FP.rand(4) * 90;
						//image.scaleX = FP.choose(1, -1);
					} else {
						if (locked) continue;
						var cell:Cell = new Cell(0,0, tile - 1);
						image = cell.image;
						image.color = Cell.COLORS[tile-1];
					}
					
					image.centerOO();
					
					Draw.graphic(image, x + Main.TW*0.5, y + Main.TW*0.5);
				}
			}
			
			imageCache[lookup] = bitmap;
			
			return bitmap;
		}
	}
}

