package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class ThanksScreen extends World
	{	
		public function ThanksScreen ()
		{
			Main.so.data.currentlevel = 0;
			Main.MenuClass = Menu;
			History.buttonsVisible = 1;
			
			var title:Text = new Text("Thanks for playing\nDr. Biology's\nEducational Game!\n ", 0, 0, {size: 48, color: 0x0, align: "center"});
		
			title.centerOO();
		
			title.x = FP.width * 0.5;
			title.y = FP.height * 0.3;
			
			//title.scrollX = title.scrollY = 0;
		
			addGraphic(title);
			
			title = new Text("Made by Dr. Biology\nand Alan Hazelden\n\nGraphics by Cap'n Lee\n ", 0, 0, {size: 36, color: 0x0, align: "center"});
		
			title.centerOO();
		
			title.x = FP.width * 0.5;
			title.y = FP.height * 0.75;
			
			//title.scrollX = title.scrollY = 0;
		
			addGraphic(title);
		}
		
		public override function update (): void
		{
			Main.so.data.currentlevel = 0;
			
			if (Input.pressed(Key.ESCAPE) || Input.pressed(Key.SPACE)) {
				gotoMenu();
				return;
			}
		}
		
		public static function gotoMenu ():void
		{
			Audio.play("button_click");
			
			FP.world = new Menu;
		}
	}
}

