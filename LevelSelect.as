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
		
		public static var thumbnailScale:Number;
		
		[Embed(source="images/locked.png")]
		public static const LockedGfx: Class;
		
		public function LevelSelect ()
		{
			thumbnailScale = 1.0/3.0;
			
			for (var i:int = 0; i < 12; i++) {
				addLevel(i);
			}
			
			var buttonImage:Spritemap = new Spritemap(History.ButtonsGfx, 48, 48);
			buttonImage.scale = Main.SCALE_BUTTONS;
			buttonImage.smooth = true;
			buttonImage.frame = 2;
			
			var button:Button = new Button(buttonImage, gotoMenu);
			
			if (Main.touchscreen) {
				button.x -= button.width * (1 - 1.5)*0.3;
				button.y -= button.height * (1 - 1.5)*0.3;
			}
			
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
				FP.tween(image, {scale: thumbnailScale}, tweenTime);
				
				e.layer = -e.layer;
				
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
			
			var w:int = Math.round(Main.TW * Main.TILES_WIDE * thumbnailScale);
			var h:int = Math.round(Main.TW * Main.TILES_HIGH * thumbnailScale);
			
			button.setHitbox(w, h, w/2, h/2);
			
			var spacingX:Number = (FP.width - button.width*4)/5;
			var spacingY:Number = (FP.height - button.height*3)/4;
			
			button.x = (i % 4) * (button.width + spacingX) + spacingX + button.width*0.5;
			button.y = int(i / 4) * (button.height + spacingY) + spacingY + button.height*0.5;
			
			button.layer = i + 1;
			
			var imageLarge:Image = new Image(getLevelImage(i, locked));
			imageLarge.scale = thumbnailScale;
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
					
					e.layer = -e.layer;
					
					FP.tween(e.graphic, {scale: 1.0}, tweenTime);
					FP.tween(e, {x: FP.width*0.5, y: FP.height*0.5}, tweenTime, {complete: tweenComplete});
					
					for each (b in buttons) {
						if (b != e) {
							FP.tween(b.graphic, {alpha: 0}, fadeTime);
						}
					}
					
					Audio.play("button_click");
					
					return;
				}
			}
			
			if (Main.touchscreen) return;
			
			for each (b in buttons) {
				if (b.type != "levelregion") continue;
				
				var image:Image = imagesLarge[b.layer];
				
				var targetScale:Number = thumbnailScale;
				
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
				e.layer = Math.abs(e.layer);
				e.graphic = imagesSmall[e.layer];
			}
		}
		
		public function gotoMenu ():void
		{
			Audio.play("button_click");
			
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
			
			var w:int = Math.round(large.width*thumbnailScale);
			var h:int = Math.round(large.height*thumbnailScale);
			
			var small:BitmapData = new BitmapData(w, h, true, 0x0);
			
			var image:Image = new Image(large);
			image.scale = thumbnailScale;
			image.smooth = true;
			if (locked) {
				image.alpha = 0.6;
			}
			
			Draw.setTarget(small);
			Draw.graphic(image);
			if (locked) {
				var lock:Image = new Image(LockedGfx);
				lock.centerOO();
				lock.x = w*0.5;
				lock.y = h*0.5;
				lock.scale = h / lock.height;
				lock.smooth = true;
				lock.color = 0x0E394E;
				lock.alpha = 0.9;
				Draw.graphic(lock);
			}
			
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
			
			var w:int = Main.TW*Main.TILES_WIDE;
			var h:int = Main.TW*Main.TILES_HIGH;
			
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

