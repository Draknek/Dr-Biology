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
			var scale:Number = FP.height / 480;
			
			Main.so.data.currentlevel = 0;
			Main.MenuClass = Menu;
			
			var title:Text = new Text("Dr. Biology's\nEducational Game", 0, 0, {
				//outlineStrength: 0.0, outlineColor: Button.defaultColorTextHover, letterSpacing: 0,
				size: 50*scale, color: 0x0E394E, align: "center"
			});
		
			title.x = (FP.width - title.width) * 0.5;
			//title.x = logo.x + logo.scaledWidth;
			title.y = 50*scale;
		
			addGraphic(title);
			
			var text:Text = new Text("Thanks for playing", 0, 0, {size: 30*scale, color: 0x0});
		
			text.x = (FP.width - text.width) * 0.5;
			text.y = title.y - text.height;
		
			addGraphic(text);
			
			text = new Text("!", 0, 0, {size: 50*scale, color: 0x0});
		
			text.x = title.x + title.width;
			text.y = title.y + title.height - text.height;
		
			addGraphic(text);
			
			text = new Text("If you enjoyed it, please\ncheck out my other games!", 0, 0, {size: 36*scale, color: 0x0, align: "center"});
		
			text.centerOO();
		
			text.x = FP.width * 0.5;
			text.y = FP.height * 0.55;
			
			addGraphic(text);
			
			var button:Button = new Button({text: "More games", size: 40*scale}, Menu.gotoMoreGames);
			
			button.x = (FP.width - button.width) * 0.5;
			button.y = text.y + text.height*0.5;
			
			add(button);
			
			text = new Text("(and tell people about them)", 0, 0, {size: 36*scale, color: 0x0, align: "center"});
		
			text.centerOO();
		
			text.x = FP.width * 0.5;
			text.y = button.y + button.height + text.height*0.5;
			
			addGraphic(text);
			
			var buttonImage:Spritemap = new Spritemap(History.ButtonsGfx, 48, 48);
			buttonImage.scale = Main.SCALE;
			buttonImage.smooth = true;
			buttonImage.frame = 2;
			
			button = new Button(buttonImage, gotoMenu);
			
			add(button);
		}
		
		public override function update (): void
		{
			History.buttonsVisible = 1;
			
			Main.so.data.currentlevel = 0;
			
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

