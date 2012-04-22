package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Cell extends Entity
	{
		public var beingSplit:Boolean = false;
		
		public var splitsLeft:int;
		
		public var text:Text;
		
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
			if (splitsLeft && Input.mousePressed && collidePoint(x, y, world.mouseX, world.mouseY)) {
				beingSplit = true;
			}
			
			if (beingSplit) {
				var mx:Number = world.mouseX;
				var my:Number = world.mouseY;
				
				var dx:int = 0;
				var dy:int = 0;
				
				if (mx >= x && mx <= x + width) {
					if (my < y - height*0.5) {
						dy = -1;
					} else if (my > y + height*1.5) {
						dy = 1;
					}
				} else if (my >= y && my <= y + height) {
					if (mx < x - width*0.5) {
						dx = -1;
					} else if (mx > x + width*1.5) {
						dx = 1;
					}
				}
				
				if (dx || dy) {
					if (canMove(dx, dy)) {
						splitsLeft--;
						
						var x2:int = x + dx * Main.TW;
						var y2:int = y + dy * Main.TW;
					
						var pushCell:Cell = collide("cell", x2, y2) as Cell;
						
						while (pushCell) {
							x2 += dx*Main.TW;
							y2 += dy*Main.TW;
							FP.tween(pushCell, {x: x2, y: y2}, 20);
							
							pushCell = collide("cell", x2, y2) as Cell;
						}
					
						x2 = x + dx * Main.TW;
						y2 = y + dy * Main.TW;
					
						var newCell:Cell = new Cell(x, y, splitsLeft);
					
						world.add(newCell);
						
						FP.tween(newCell, {x: x2, y: y2}, 20);
					
						text.text = "" + splitsLeft;
						text.centerOO();
					}
					
					beingSplit = false;
				}
			}
			
			if (Input.mouseReleased) {
				beingSplit = false;
			}
		}
		
		public override function render (): void
		{
			var over:Boolean = collidePoint(x, y, world.mouseX, world.mouseY);
			
			if (! splitsLeft) over = false;
			
			if (beingSplit) over = true;
			
			var c:uint = over ? 0x00FF00 : 0xFF0000;
			Draw.circlePlus(centerX, centerY, Main.TW*0.5 - 3, c, 1.0, false, 2.0);
			
			super.render();
		}
	}
}

