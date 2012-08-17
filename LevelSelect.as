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
		public var buttons:Array = [];
		public var lockedTexts:Array = [];
		
		public var nextWorld:World;
		
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
			
			button.setHitbox(10*12, 8*12, 10*6, 8*6);
			
			var spacingX:Number = (FP.width - button.width*4)/5;
			var spacingY:Number = (FP.height - button.height*3)/4;
			
			button.x = (i % 4) * (button.width + spacingX) + spacingX + button.width*0.5;
			button.y = int(i / 4) * (button.height + spacingY) + spacingY + button.height*0.5;
			
			button.layer = i + 1;
			
			var image:Image = new Image(getLevelImage(i, locked));
			
			image.scale = 1.0/3.0;
			image.centerOO();
			
			button.graphic = image;
			
			if (locked) {
				var text:Text = new Text("LOCKED", button.x, button.y, {size: 30, color: 0x0});
				text.centerOO();
				addGraphic(text, -20);
				lockedTexts.push(text);
			} else {
				button.type = "levelregion";
			}
			
			add(button);
			
			buttons.push(button);
		}
		
		public override function update ():void
		{
			Main.MenuClass = LevelSelect;
			
			Input.mouseCursor = "auto";
			
			super.update();
			
			if (nextWorld) return;
			
			if (Input.pressed(Key.ESCAPE)) {
				FP.world = new Menu;
				return;
			}
			
			var e:Entity = collidePoint("levelregion", mouseX, mouseY);
			
			var b:Entity;
			
			if (e) {
				Input.mouseCursor = "button";
				
				if (Input.mousePressed) {
					nextWorld = new Level(null, e.layer);
					
					var tweenTime:Number = 20;
					var fadeTime:Number = 10;
					
					FP.tween(e.graphic, {scale: 1.0}, tweenTime);
					FP.tween(e, {x: FP.width*0.5, y: FP.height*0.5}, tweenTime, {complete: tweenComplete});
					
					for each (b in buttons) {
						if (b != e) {
							FP.tween(b.graphic, {alpha: 0}, fadeTime);
						}	
					}
					
					for each (var t:Text in lockedTexts) {
						FP.tween(t, {alpha: 0}, fadeTime);
					}
					
					return;
				}
			}
			
			for each (b in buttons) {
				if (b.type != "levelregion") continue;
				
				var image:Image = b.graphic as Image;
				
				if (! image) continue;
				
				var targetScale:Number = 1.0/3.0;
				
				if (b == e) {
					targetScale = 0.5;
				}
				
				var diff:Number = targetScale - image.scale;
				
				if (diff > -0.01 && diff < 0.01) {
					image.scale = targetScale;
				} else {
					image.scale += (targetScale - image.scale) * 0.3;
				}
			}
		}
		
		private function tweenComplete ():void
		{
			FP.world = nextWorld;
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

