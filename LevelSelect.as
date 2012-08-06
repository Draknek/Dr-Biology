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
			var button:Entity = new Entity;
			
			button.x = (i % 4) * (FP.width/4);
			button.y = int(i / 4) * (FP.height/3);
			
			button.width = 10*12;
			button.height = 8*12;
			
			button.graphic = Image.createRect(button.width, button.height, 0xFF0000);
			
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
		}
	}
}

