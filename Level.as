package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Level extends World
	{
		public var bg:Tilemap;
		public var solidGrid:Grid;
		
		public function Level (tiles:Tilemap = null, id:int = 0)
		{
			bg = new Tilemap(Editor.EditTilesGfx, FP.width, FP.height, Main.TW, Main.TW);
			
			addGraphic(bg);
			
			solidGrid = new Grid(FP.width, FP.height, Main.TW, Main.TW);
			
			addMask(solidGrid, "solid");
			
			for (var i:int = 0; i < tiles.columns; i++) {
				for (var j:int = 0; j < tiles.rows; j++) {
					var tile:uint = tiles.getTile(i, j);
					
					if (tile == 0) continue;
					if (tile == 1) {
						bg.setTile(i, j, 1);
						solidGrid.setTile(i, j, true);
						continue;
					}
					
					var x:int = i*Main.TW;
					var y:int = j*Main.TW;
					
					add(new Cell(x, y, tile - 1));
				}
			}
		}
		
		public override function update (): void
		{
			if (Input.pressed(Key.E)) {
				FP.world = new Editor;
				return;
			}
			
			super.update();
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

