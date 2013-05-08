package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Cell extends Entity
	{
		public static var clickPos:Point = new Point;
		
		public var pendingSplit:Boolean = false;
		public var doingSplit:Boolean = false;
		
		public var splitsLeft:int;
		
		public var text:Text;
		
		public var textAlpha:Number = 1.0;
		
		
		[Embed(source="images/arrows.png")]
		public static const ArrowsGfx: Class;
		
		[Embed(source="images/idlegerm.png")]
		public static const Gfx: Class;
		
		public static var imageSource:BitmapData;
		
		public static var sharedArrows:Image = new Image(ArrowsGfx);
		
		public var image:Spritemap;
		public var image2:Spritemap;
		
		public static var cell1:Cell;
		public static var cell2:Cell;
		
		public static var COLORS:Array = [
			0xe6e8d1,
			0xe6962e,
			0xe32f55,
			0xcb40af,
			0x9f4fdc,
			0x0090ff
		];
		
		public function Cell (_x:Number, _y:Number, splitCount:int)
		{
			x = _x;
			y = _y;
			
			splitsLeft = splitCount;
			
			setHitbox(Main.TW, Main.TW, Main.TW*0.5, Main.TW*0.5);
			
			var imageSize:int = 32 * Main.SCALE;
			
			if (! imageSource) {
				imageSource = Main.scaleFunction(FP.getBitmap(Gfx));
			}
			
			var sprite:Spritemap = new Spritemap(imageSource, imageSize, imageSize);
			
			sprite.add("wobble", FP.frames(0, sprite.frameCount-1), 0.04*(1 + Math.random()));
			
			sprite.play("wobble");
			
			sprite.centerOO();
			
			image = sprite;
			
			sprite = new Spritemap(imageSource, imageSize, imageSize);
			
			sprite.add("wobble", FP.frames(0, sprite.frameCount-1), 0.04*(1 + Math.random()));
			
			sprite.play("wobble");
			
			sprite.centerOO();
			
			image2 = sprite;
			image2.visible = false;
			image2.blend = "lighten";
			
			
			text = new Text(""+splitsLeft, 0, 0, {color: 0x000000});
			text.centerOO();
			
			addGraphic(image);
			addGraphic(image2);
			addGraphic(text);
			
			type = "cell";
			
			layer = -1;
		}
		
		public function canMove (dx:int, dy:int):Boolean {
			var x2:int = x + dx * Main.TW;
			var y2:int = y + dy * Main.TW;
			
			var solid:Entity = collide("solid", x2, y2);
			
			if (solid) return false;
			
			var cell:Cell = collide("cell", x2, y2) as Cell;
			
			if (cell) {
				return cell.canMove(dx, dy);
			}
			
			return true;
		}
		
		public override function update (): void
		{
			if (Level(world).history.reseting) {
				text.color = 0x0;
				pendingSplit = false;
				doingSplit = false;
				image2.visible = false;
				return;
			}
			
			if (splitsLeft && collidePoint(x, y, world.mouseX, world.mouseY)) {
				if (! Input.mouseDown && ! Main.touchscreen) {
					Input.mouseCursor = "button";
					text.color = 0xFFFFFF;
				}
				
				if (Main.touchscreen && ! Input.mouseDown) {
					text.color = 0x0;
				}
				
				if (Input.mousePressed) {
					pendingSplit = true;
					clickPos.x = world.mouseX;
					clickPos.y = world.mouseY;
					text.color = 0xFFFFFF;
				}
			} else if (pendingSplit) {
				text.color = 0xFFFFFF;
			} else {
				text.color = 0x0;
			}
			
			if (pendingSplit) {
				Input.mouseCursor = "hand";
				
				var mx:Number = world.mouseX - clickPos.x;
				var my:Number = world.mouseY - clickPos.y;
				
				var dx:int = 0;
				var dy:int = 0;
				
				var dist:Number = 0.75;
				
				if (! image2.visible) {
					image2.visible = true;
					image2.x = image2.y = 0;
				}
				
				if (Math.abs(my) > Math.abs(mx)) {
					if (my < -height*dist) {
						dy = -1;
					} else if (my > height*dist) {
						dy = 1;
					}
					
					image2.x = 0;
					if (! dy) image2.y = my*0.33;
				} else {
					if (mx < -width*dist) {
						dx = -1;
					} else if (mx > width*dist) {
						dx = 1;
					}
					
					if (! dx) image2.x = mx*0.33;
					image2.y = 0;
				}
				
				if (dx || dy) {
					Level(world).queueSplit(this, dx, dy);
					pendingSplit = false;
					doingSplit = true;
				}
			}
			
			if (Input.mouseReleased) {
				if (pendingSplit) {
					pendingSplit = false;
				}
			}
			
			if (! pendingSplit && ! doingSplit && image2.visible) {
				image2.x = FP.approach(image2.x, 0, 0.25);
				image2.y = FP.approach(image2.y, 0, 0.25);
				
				if (! image2.x && ! image2.y) {
					image2.visible = false;
				}
			}
		}
		
		public function split (dx:int, dy:int):void
		{
			if (splitsLeft <= 0 || ! canMove(dx, dy)) {
				doingSplit = false;
				image2.visible = true;
				var dist:Number = 0.75;
				image2.x = width*dist*dx*0.33;
				image2.y = height*dist*dy*0.33;
				Audio.play("nope");
				return;
			}
			
			if (! image2.visible) {
				image2.visible = true;
				image2.x = image2.y = 0;
			}
			
			var undoData:Object = {origCell:this, dx:dx, dy:dy, pushed:[]};
			
			var level:Level = world as Level;
			
			level.busy = true;
			
			splitsLeft--;
			
			dx *= Main.TW;
			dy *= Main.TW;
			
			var x2:int = x + dx;
			var y2:int = y + dy;
		
			var pushCell:Cell = collide("cell", x2, y2) as Cell;
			
			var moveTime:int = 20;
			var delay:int = 0;
			
			while (pushCell) {
				undoData.pushed.push(pushCell);
				
				x2 += dx;
				y2 += dy;
				
				delay += 4;
				FP.tween(pushCell, {x: x2, y: y2}, moveTime, {delay: delay});
				
				pushCell = collide("cell", x2, y2) as Cell;
			}
		
			var newCell:Cell = new Cell(x + dx, y + dy, splitsLeft);
		
			world.add(newCell);
			
			FP.tween(image2, {x: dx, y: dy}, moveTime, endSplit);
			
			FP.alarm(moveTime + delay, level.unbusy);
			
			undoData.newCell = newCell;
		
			Audio.play("split");
			
			level.history.moved(undoData);
			
			cell1 = this;
			cell2 = newCell;
			
			textAlpha = 0;
			newCell.textAlpha = 0;
			newCell.text.alpha = 0;
			newCell.visible = false;
		}
		
		public static function endSplit ():void
		{
			if (Cell.cell1.splitsLeft) {
				Cell.cell1.textAlpha = 1;
				Cell.cell2.textAlpha = 1;
				Cell.cell1.text.visible = true;
				Cell.cell2.text.visible = true;
			} else {
				Cell.cell1.text.visible = false;
				Cell.cell2.text.visible = false;
			}
			
			Cell.cell1.image2.visible = false;
			Cell.cell2.visible = true;
			
			Cell.cell1.text.text = "" + Cell.cell1.splitsLeft;
			
			Cell.cell1.doingSplit = false;
			Cell.cell2.doingSplit = false;
		}
		
		private var lastFrameValue:int;
		
		public override function render (): void
		{
			calculateColor();
			
			var alphaDiff:Number = textAlpha - text.alpha;
			
			var maxAlphaChange:Number = 1.0/10.0;
			
			if (alphaDiff < -maxAlphaChange) {
				text.alpha -= maxAlphaChange;
			} else if (alphaDiff > maxAlphaChange) {
				text.alpha += maxAlphaChange;
			} else {
				text.alpha = textAlpha;
			}
			
			if (lastFrameValue != image.frame) {
				text.size = FP.rand(4) + 15*Main.SCALE;
				
				lastFrameValue = image.frame;
			}
			
			text.originX = text.textWidth/2;
			text.originY = text.textHeight/2;
			
			var over:Boolean = collidePoint(x, y, world.mouseX, world.mouseY);
			
			if (! splitsLeft) over = false;
			
			if (pendingSplit) over = true;
			
			//if (Level(world).done) over = true;
			
			if (image2.visible) {
				renderSpecial();
			} else {
				super.render();
			}
		}
		
		public function calculateColor ():void
		{
			image.color = COLORS[splitsLeft];
			image2.color = COLORS[splitsLeft];
		}
		
		public function renderSpecial ():void
		{
			if (! buffer) {
				buffer = new BitmapData(Main.TW*4, Main.TW*4, true, 0x0);
			}
			
			FP.point.x = x - Main.TW*2 - FP.camera.x;
			FP.point.y = y - Main.TW*2 - FP.camera.y;
			
			FP.rect.x = 0;
			FP.rect.y = 0;
			FP.rect.width = Main.TW*4;
			FP.rect.height = Main.TW*4;
			
			buffer.fillRect(FP.rect, 0x0);
			
			Draw.setTarget(buffer);
			Draw.graphic(image, Main.TW*2, Main.TW*2);
			
			Draw.graphic(image2, Main.TW*2, Main.TW*2);
			
			FP.point.x = x - Main.TW*2 - FP.camera.x;
			FP.point.y = y - Main.TW*2 - FP.camera.y;
			
			FP.rect.x = 0;
			FP.rect.y = 0;
			FP.rect.width = Main.TW*4;
			FP.rect.height = Main.TW*4;
			
			FP.buffer.copyPixels(buffer, FP.rect, FP.point, null, null, true);
			
			if (text.visible) {
				Draw.setTarget(FP.buffer, FP.camera);
				Draw.graphic(text, x, y);
			}
		}
		
		public static var buffer:BitmapData;
	}
}

