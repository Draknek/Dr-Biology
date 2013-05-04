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
			
			var buttonImage:Spritemap = new Spritemap(History.ButtonsGfx, 48, 48);
			buttonImage.scale = Main.SCALE;
			buttonImage.smooth = true;
			buttonImage.frame = 2;
			
			var button:Button = new Button(buttonImage, gotoMenu);
			
			add(button);
		}
		
		public override function update (): void
		{
			History.buttonsVisible = 1;
			
			Main.so.data.currentlevel = 0;
			
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.ESCAPE) || Input.pressed(Key.SPACE)) {
				gotoMenu();
				return;
			}
			
			super.update();
		}
		
		public static function gotoMenu ():void
		{
			Audio.play("button_click");
			
			FP.world = new Menu;
		}
	}
}

