package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Cell extends Entity
	{
		public var pendingSplit:Boolean = false;
		
		public var splitsLeft:int;
		
		public var text:Text;
		
		
		[Embed(source="images/arrows.png")]
		public static const ArrowsGfx: Class;
		
		public static var sharedArrows:Image = new Image(ArrowsGfx);
		
		
		public function Cell (_x:Number, _y:Number, splitCount:int)
		{
			x = _x;
			y = _y;
			
			splitsLeft = splitCount;
			
			setHitbox(Main.TW, Main.TW);
			
			text = new Text(""+splitsLeft, Main.TW*0.5, Main.TW*0.5, {color: 0x000000});
			text.centerOO();
			
			graphic = text;
			
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
				
				var dist:Number = 0.25;
				var dist2:Number = 1 + dist;
				
				if (mx >= x && mx <= x + width) {
					if (my < y - height*dist) {
						dy = -1;
					} else if (my > y + height*dist2) {
						dy = 1;
					}
				} else if (my >= y && my <= y + height) {
					if (mx < x - width*dist) {
						dx = -1;
					} else if (mx > x + width*dist2) {
						dx = 1;
					}
				}
				
				if (dx || dy) {
					Level(world).queueSplit(this, dx, dy);
					pendingSplit = false;
				}
			}
			
			if (Input.mouseReleased) {
				pendingSplit = false;
			}
		}
		
		public function split (dx:int, dy:int):void
		{
			if (! canMove(dx, dy)) {
				return;
			}
			
			var undoData:Object = {origCell:this, dx:dx, dy:dy, pushed:[]};
			
			var level:Level = world as Level;
			
			level.busy = true;
			
			splitsLeft--;
			
			var x2:int = x + dx * Main.TW;
			var y2:int = y + dy * Main.TW;
		
			var pushCell:Cell = collide("cell", x2, y2) as Cell;
			
			while (pushCell) {
				undoData.pushed.push(pushCell);
				
				x2 += dx*Main.TW;
				y2 += dy*Main.TW;
				FP.tween(pushCell, {x: x2, y: y2}, 20);
				
				pushCell = collide("cell", x2, y2) as Cell;
			}
		
			x2 = x + dx * Main.TW;
			y2 = y + dy * Main.TW;
		
			var newCell:Cell = new Cell(x, y, splitsLeft);
		
			world.add(newCell);
			
			FP.tween(newCell, {x: x2, y: y2}, 20, level.unbusy);
			
			undoData.newCell = newCell;
		
			Audio.play("split");
			
			level.history.moved(undoData);
		}
		
		public override function render (): void
		{
			text.text = "" + splitsLeft;
			text.centerOO();
			
			var over:Boolean = collidePoint(x, y, world.mouseX, world.mouseY);
			
			if (! splitsLeft) over = false;
			
			if (pendingSplit) over = true;
			
			if (Level(world).done) over = true;
			
			var c:uint = over ? 0x00FF00 : 0xFF0000;
			Draw.circlePlus(centerX, centerY, Main.TW*0.5 - 3, c, 1.0, false, 2.0);
			
			super.render();
		}
	}
}

