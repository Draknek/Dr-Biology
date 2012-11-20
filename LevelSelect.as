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
		public var imagesSmall:Array = [];
		public var imagesLarge:Array = [];
		
		public var fromWorld:Level;
		public var nextWorld:World;
		
		public function LevelSelect ()
		{
			for (var i:int = 0; i < 12; i++) {
				addLevel(i);
			}
			
			var buttonImage:Spritemap = new Spritemap(History.ButtonsGfx, 48, 48);
			buttonImage.frame = 2;
			
			var button:Button = new Button(buttonImage, gotoMenu);
			
			add(button);
			
			if (FP.world is Level) {
				fromWorld = FP.world as Level;
				
				var id:int = fromWorld.id;
				
				var e:Entity = buttons[id-1];
				
				e.graphic = imagesLarge[e.layer];
				
				var image:Image = e.graphic as Image;
				
				image.scale = 1.0;
				
				var toX:Number = e.x;
				var toY:Number = e.y;
				
				e.x = FP.width * 0.5;
				e.y = FP.height * 0.5;
				
				var tweenTime:Number = 20;
				var fadeTime:Number = 10;
				
				FP.tween(e, {x: toX, y: toY}, tweenTime, stopTweenFromLevel);
				FP.tween(image, {scale: 1.0/3.0}, tweenTime);
				
				var b:Entity = e;
				
				for each (e in buttons) {
					if (b != e) {
						Image(e.graphic).alpha = 0;
						FP.tween(e.graphic, {alpha: 1}, fadeTime, {delay: tweenTime - fadeTime});
					}
				}
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
			
			var imageLarge:Image = new Image(getLevelImage(i, locked));
			imageLarge.scale = 1/3;
			imageLarge.centerOO();
			imagesLarge[button.layer] = imageLarge;
			
			var imageSmall:Image = new Image(getLevelImageSmall(i, locked));
			imageSmall.centerOO();
			imagesSmall[button.layer] = imageSmall;
			
			button.graphic = imageSmall;
			
			if (! locked) {
				button.type = "levelregion";
			}
			
			add(button);
			
			buttons.push(button);
		}
		
		public override function update ():void
		{
			History.buttonsVisible = 1;
			Main.MenuClass = LevelSelect;
			
			Input.mouseCursor = "auto";
			
			super.update();
			
			if (Input.pressed(Key.ESCAPE)) {
				gotoMenu();
				return;
			}
			
			if (nextWorld || fromWorld) return;
			
			var e:Entity = collidePoint("levelregion", mouseX, mouseY);
			
			var b:Entity = collidePoint("button", mouseX, mouseY);
			
			if (b) {
				e = null;
				b = null;
			}
			
			if (e) {
				Input.mouseCursor = "button";
				
				if (Input.mousePressed) {
					nextWorld = new Level(null, e.layer);
					
					var tweenTime:Number = 20;
					var fadeTime:Number = 10;
					
					e.graphic = imagesLarge[e.layer];
					
					FP.tween(e.graphic, {scale: 1.0}, tweenTime);
					FP.tween(e, {x: FP.width*0.5, y: FP.height*0.5}, tweenTime, {complete: tweenComplete});
					
					for each (b in buttons) {
						if (b != e) {
							FP.tween(b.graphic, {alpha: 0}, fadeTime);
						}
					}
					
					return;
				}
			}
			
			if (Main.touchscreen) return;
			
			for each (b in buttons) {
				if (b.type != "levelregion") continue;
				
				var image:Image = imagesLarge[b.layer];
				
				var targetScale:Number = 1.0/3.0;
				
				if (b == e) {
					targetScale = 0.5;
					b.graphic = image;
				}
				
				if (b.graphic != image) continue;
				
				var diff:Number = targetScale - image.scale;
				
				if (diff > -0.01 && diff < 0.01) {
					image.scale = targetScale;
					if (b != e) {
						b.graphic = imagesSmall[b.layer];
					}
				} else {
					image.scale += (targetScale - image.scale) * 0.3;
				}
			}
		}
		
		public function stopTweenFromLevel ():void
		{
			fromWorld = null;
			
			for each (var e:Entity in buttons) {
				e.graphic = imagesSmall[e.layer];
			}
		}
		
		public function gotoMenu ():void
		{
			if (! nextWorld) {
				FP.world = new Menu;
				return;
			}
			
			nextWorld = null;
			
			FP.world = new LevelSelect;
		}
		
		private function tweenComplete ():void
		{
			if (! nextWorld) return;
			
			FP.world = nextWorld;
		}
		
		private static var imageCache:Vector.<BitmapData> = new Vector.<BitmapData>(24, true);
		
		private static var imageCacheSmall:Vector.<BitmapData> = new Vector.<BitmapData>(24, true);
		
		private static var textCache:Text;
		
		private static function getLevelImageSmall (i:int, locked:Boolean):BitmapData
		{
			var lookup:int = i;
			
			if (locked) {
				lookup += 12;
			}
			
			if (imageCacheSmall[lookup]) {
				return imageCacheSmall[lookup];
			}
			
			var large:BitmapData = getLevelImage(i, locked);
			
			var w:int = large.width/3;
			var h:int = large.height/3;
			
			var small:BitmapData = new BitmapData(w, h, true, 0x0);
			
			if (locked && ! textCache) {
				var textSize:int = 30;
				
				var spacingX:Number = (FP.width - w*4)/5;
				var spacingY:Number = (FP.height - h*3)/4;
				
				var maxSpacingX:Number = (640 - w*4)/5;
				
				if (spacingX < maxSpacingX) {
					textSize = FP.lerp(24, 30, spacingX / maxSpacingX);
				}
				
				textCache = new Text("LOCKED", w*0.5, h*0.5, {size: textSize, color: 0x0});
				textCache.centerOO();
			
			}
			
			var image:Image = new Image(large);
			image.scale = 1/3;
			
			Draw.setTarget(small);
			Draw.graphic(image);
			if (locked) Draw.graphic(textCache);
			
			imageCacheSmall[lookup] = small;
			
			return small;
		}
		
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

