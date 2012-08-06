package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
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
			
			button.visible = false;
			button.layer = i + 1;
			
			if (locked) {
				var text:Text = new Text("LOCKED", button.x + button.width*0.5, button.y + button.height*0.5, {size: 30, color: 0x0});
				text.centerOO();
				addGraphic(text, -20);
			} else {
				button.type = "levelregion";
			}
			
			add(button);
			
			var data:LevelData = LevelData.levels[i];
			
			var tiles:Tilemap = data.tiles;
			
			Level.centerLevelMagic(tiles, camera, 1, button.width*3, button.height*3);
			
			for (var i:int = 0; i < tiles.columns; i++) {
				for (var j:int = 0; j < tiles.rows; j++) {
					var tile:uint = tiles.getTile(i, j);
					
					if (tile == 0) continue;
					
					var x:int = i*Main.TW;
					var y:int = j*Main.TW;
					
					var e:Entity;
					
					if (tile == 1) {
						var wall:Wall = new Wall(x + Main.TW*0.5, y + Main.TW*0.5);
						wall.image.scale = 1.0/3.0;
						e = wall;
					} else {
						if (locked) continue;
						var cell:Cell = new Cell(x + Main.TW*0.5, y + Main.TW*0.5, tile - 1);
						cell.image.scale = 1.0/3.0;
						cell.text.visible = false;
						e = cell;
					}
					
					add(e);
					
					e.active = false;
					
					e.x -= camera.x;
					e.y -= camera.y;
					
					e.x /= 3.0;
					e.y /= 3.0;
					
					e.x += button.x;
					e.y += button.y;
				}
			}
			
			camera.x = 0;
			camera.y = 0;
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
	}
}

