package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class AboutScreen extends World
	{	
		public function AboutScreen ()
		{
			var scale:Number = FP.height / 480;
			
			var title:Text = new Text("Dr. Biology's\nEducational Game", 0, 0, {
				//outlineStrength: 0.0, outlineColor: Button.defaultColorTextHover, letterSpacing: 0,
				size: 50*scale, color: 0x0E394E, align: "center"
			});
		
			title.x = (FP.width - title.width) * 0.5;
			//title.x = logo.x + logo.scaledWidth;
			title.y = 50*scale;
			
			//title.scrollX = title.scrollY = 0;
		
			addGraphic(title);
			
			title = new Text("was created by Dr. Biology\nwith assistance from Alan Hazelden\n\nGraphics by Cap'n Lee\n\nAudio by William Robinson\n ", 0, 0, {size: 32*scale, color: 0x0, align: "center"});
		
			title.centerOO();
		
			title.x = FP.width * 0.5;
			title.y = FP.height * 0.7;
			
			//title.scrollX = title.scrollY = 0;
		
			addGraphic(title);
			
			var buttonImage:Spritemap = new Spritemap(History.ButtonsGfx, 48, 48);
			buttonImage.scale = Main.SCALE_BUTTONS;
			buttonImage.smooth = true;
			buttonImage.frame = 2;
			
			var button:Button = new Button(buttonImage, gotoMenu);
			
			add(button);
		}
		
		public override function update (): void
		{
			History.buttonsVisible = 1;
			
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.ESCAPE) || Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER)) {
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

