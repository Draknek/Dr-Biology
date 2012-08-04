package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Cell extends Entity
	{
		public var pendingSplit:Boolean = false;
		
		public var splitsLeft:int;
		
		public var text:Text;
		
		public var textAlpha:Number = 1.0;
		
		
		[Embed(source="images/arrows.png")]
		public static const ArrowsGfx: Class;
		
		[Embed(source="images/idlegerm.png")]
		public static const Gfx: Class;
		
		public static var sharedArrows:Image = new Image(ArrowsGfx);
		
		public var image:Spritemap;
		public var image2:Spritemap;
		
		public static var cell1:Cell;
		public static var cell2:Cell;
		
		public function Cell (_x:Number, _y:Number, splitCount:int)
		{
			x = _x;
			y = _y;
			
			splitsLeft = splitCount;
			
			setHitbox(Main.TW, Main.TW, Main.TW*0.5, Main.TW*0.5);
			
			
			var sprite:Spritemap = new Spritemap(Gfx, 32, 32);
			
			sprite.add("wobble", FP.frames(0, sprite.frameCount), 0.04 + Math.random()*0.04);
			
			sprite.play("wobble");
			
			sprite.centerOO();
			
			image = sprite;
			
			sprite = new Spritemap(Gfx, 32, 32);
			
			sprite.add("wobble", FP.frames(0, sprite.frameCount), 0.04 + Math.random()*0.04);
			
			sprite.play("wobble");
			
			sprite.centerOO();
			
			image2 = sprite;
			image2.blend = "lighten";
			
			
			text = new Text(""+splitsLeft, 0, 0, {color: 0x000000});
			text.centerOO();
			
			addGraphic(image);
			addGraphic(image2);
			addGraphic(text);
			
			type = "cell";
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
				pendingSplit = false;
				return;
			}
			
			if (splitsLeft && collidePoint(x, y, world.mouseX, world.mouseY)) {
				if (!Input.mouseDown) Input.mouseCursor = "button";
				
				if (Input.mousePressed) {
					pendingSplit = true;
				}
			}
			
			if (pendingSplit) {
				Input.mouseCursor = "hand";
				
				var mx:Number = world.mouseX;
				var my:Number = world.mouseY;
				
				var dx:int = 0;
				var dy:int = 0;
				
				var dist:Number = 0.75;
				
				if (mx >= x - halfWidth && mx <= x + halfWidth) {
					if (my < y - height*dist) {
						dy = -1;
					} else if (my > y + height*dist) {
						dy = 1;
					} else if (! (my >= y - halfHeight && my <= y + halfHeight)) {
						image2.x = 0;
						image2.y = my - y + ((my > y) ? -halfHeight : halfHeight);
						image2.visible = true;
					}
				} else if (my >= y - halfHeight && my <= y + halfHeight) {
					if (mx < x - width*dist) {
						dx = -1;
					} else if (mx > x + width*dist) {
						dx = 1;
					} else {
						image2.x = mx - x + ((mx > x) ? -halfWidth : halfWidth);
						image2.y = 0;
						image2.visible = true;
					}
				}
				
				if (dx || dy) {
					Level(world).queueSplit(this, dx, dy);
					pendingSplit = false;
				}
			}
			
			if (Input.mouseReleased) {
				if (pendingSplit) {
					pendingSplit = false;
					image2.visible = false;
				}
			}
		}
		
		public function split (dx:int, dy:int):void
		{
			if (! canMove(dx, dy)) {
				image2.visible = false;
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
			
			while (pushCell) {
				undoData.pushed.push(pushCell);
				
				x2 += dx;
				y2 += dy;
				FP.tween(pushCell, {x: x2, y: y2}, 20);
				
				pushCell = collide("cell", x2, y2) as Cell;
			}
		
			var newCell:Cell = new Cell(x + dx, y + dy, splitsLeft);
		
			world.add(newCell);
			
			FP.tween(image2, {x: dx, y: dy}, 20, level.unbusy);
			
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
		
		public override function render (): void
		{
			var alphaDiff:Number = textAlpha - text.alpha;
			
			var maxAlphaChange:Number = 1.0/10.0;
			
			if (alphaDiff < -maxAlphaChange) {
				text.alpha -= maxAlphaChange;
			} else if (alphaDiff > maxAlphaChange) {
				text.alpha += maxAlphaChange;
			} else {
				text.alpha = textAlpha;
			}
			
			text.centerOO();
			
			var over:Boolean = collidePoint(x, y, world.mouseX, world.mouseY);
			
			if (! splitsLeft) over = false;
			
			if (pendingSplit) over = true;
			
			//if (Level(world).done) over = true;
			
			if (over) {
				var c:uint = 0xFF0000;
				Draw.circlePlus(centerX, centerY, Main.TW*0.5 - 3, c, 1.0, false, 2.0);
			}
			
			if (image2.visible) {
				renderSpecial();
			} else {
				super.render();
			}
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
			
			Draw.setTarget(FP.buffer, FP.camera);
			Draw.graphic(text, x, y);
		}
		
		public static var buffer:BitmapData;
	}
}

