package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class Editor extends World
	{
		[Embed(source="images/tiles.png")]
		public static const EditTilesGfx: Class;
		
		public static var editTile:Spritemap = new Spritemap(EditTilesGfx, Main.TW, Main.TW);
		public static var palette:Entity = createPalette();
		public static var paletteClicked:Boolean = false;
		public static var paletteMouseover:Stamp;
		
		public static var tiles:Tilemap;
		
		public static var PERSISTENT:Boolean = false;
		
		public static function init ():void
		{
			PERSISTENT = Main.devMode;
			
			tiles = new Tilemap(EditTilesGfx, FP.width, FP.height, Main.TW, Main.TW);
			
			var startLevel:String ='';
			
			if (PERSISTENT && Main.so.data.editState) {
				startLevel = Main.so.data.editState;
			} else {
				//startLevel = new DefaultRoom;
			}
			
			tiles.loadFromString(startLevel);
		}
		
		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.SPACE)) {
				togglePalette();
			}
			
			if (Input.pressed(Key.E)) {
				FP.world = new Level(tiles, 0);
				return;
			}
			
			
			// SPACE: Palette
			// E: Test
			// C: Clear
			// 0-9: choose tile
			
			if (Input.check(Key.SHIFT) && Input.pressed(Key.ESCAPE)) {
				clear();
			}
			
			var i:int;
			var j:int;
			
			for (i = 0; i < 10; i++) {
				if (Input.pressed(Key.DIGIT_1 + i)) {
					editTile.frame = i;
				}
			}
			
			//if (Input.mouseCursor != "auto") return;
			
			var mx:int = mouseX / editTile.width;
			var my:int = mouseY / editTile.height;
			
			var overPalette:Boolean = palette.visible && palette.collidePoint(palette.x, palette.y, Input.mouseX, Input.mouseY);
			
			if (overPalette) {
				editTile.alpha = 0;
				Input.mouseCursor = "button";
			} else {
				editTile.x = mx * editTile.width;
				editTile.y = my * editTile.height;
				
				editTile.originX = editTile.originY = 0;
				
				editTile.alpha = 0.5;
			}
			
			if (palette.visible) {
				if (overPalette) {
					mx = Input.mouseX - palette.x;
					my = Input.mouseY - palette.y;
					
					mx /= editTile.width;
					my /= editTile.height;
					
					paletteMouseover.x = -1 + mx * editTile.width;
					paletteMouseover.y = -1 + my * editTile.height;
				} else {
					paletteMouseover.x = -1 + int(editTile.frame % 4) * editTile.width;
					paletteMouseover.y = -1 + int(editTile.frame / 4) * editTile.height;
				}
			}
			
			if (Input.mouseDown) {
				if (overPalette && Input.mousePressed) {
					editTile.frame = mx + (palette.width / editTile.width) * my;
					
					paletteClicked = true;
				}
				
				if (! overPalette && ! paletteClicked) {
					var id:int = getTile(mx, my);
			
					if (id != editTile.frame) {
						if(Input.check(Key.B))
						{
							for(i = mx-1; i<mx+2; i++)
								for(j = my-1; j<my+2; j++)
									setTile(i, j, editTile.frame);							
						}
						else
						{
							setTile(mx, my, editTile.frame);
						}
					}
				}
				
				palette.visible = false;
			} else {
				paletteClicked = false;
			}
			
		}
		
		public function clear ():void
		{
			tiles.setRect(0, 0, tiles.columns, tiles.rows, 0);
			
			changed();
		}
		
		public function getTile (i:int, j:int): int
		{
			return tiles.getTile(i, j);
		}
		
		public function setTile (i:int, j:int, tile:int): void
		{
			if(i<0 || i>=tiles.columns || j<0 || j>=tiles.rows) return;
			
			tiles.setTile(i, j, tile);
			
			changed();
		}
		
		public override function render (): void
		{
			Draw.graphic(tiles);
			
			Draw.graphic(editTile);
			
			Draw.entity(palette, palette.x, palette.y);
		}
		
		public static function togglePalette ():void
		{
			palette.visible = ! palette.visible;
		}
		
		private static function createPalette ():Entity
		{
			var palette:Entity = new Entity;
			palette.visible = false;
			var tiles:Image = new Image(EditTilesGfx);
			palette.width = tiles.width;
			palette.height = tiles.height;
			
			palette.x = int((FP.width - palette.width)*0.5);
			palette.y = int((FP.height - palette.height)*0.5);
			
			tiles.scrollX = tiles.scrollY = 0;
			
			var border:Stamp = new Stamp(new BitmapData(palette.width+4, palette.height+4, false, 0xFF0000));
			FP.rect.x = 2;
			FP.rect.y = 2;
			FP.rect.width = palette.width;
			FP.rect.height = palette.height;
			border.source.fillRect(FP.rect, 0x202020);
			
			border.x = -2;
			border.y = -2;
			border.scrollX = border.scrollY = 0;
			
			paletteMouseover = new Stamp(new BitmapData(editTile.width+2, editTile.height+2, true, 0xFFFFFFFF));
			
			FP.rect.x = FP.rect.y = 1;
			FP.rect.width = editTile.width;
			FP.rect.height = editTile.height;
			paletteMouseover.source.fillRect(FP.rect, 0x0);
			
			paletteMouseover.x = -1;
			paletteMouseover.y = -1;
			
			paletteMouseover.scrollX = paletteMouseover.scrollY = 0;
			
			palette.graphic = new Graphiclist(border, tiles, paletteMouseover);
			
			return palette;
		}
		
		public static function GetTile(tiles:Tilemap, i:int, j:int):uint
		{
			//if(i<0 || i>=tiles.columns || j<0 || j>=tiles.rows) return WALL;
			return tiles.getTile(i,j);
		}
		
		public static function clear ():void
		{
			tiles.setRect(0, 0, tiles.columns, tiles.rows, 0);
		}
		
		public function getWorldData (): *
		{
			return tiles.saveToString();
		}
		
		public function setWorldData (bytedata: ByteArray): void {
			tiles.loadFromString(bytedata.toString());
			
			changed();
		}
		
		private function changed (): void
		{
			Main.so.data.editState = getWorldData();
		}
	}
}

