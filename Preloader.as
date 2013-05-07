
package
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.getDefinitionByName;
	import flash.system.*;

	[SWF(width = "640", height = "480", backgroundColor = "#f7dfd4")]
	public class Preloader extends Sprite
	{
		// Change these values
		private static const mustClick: Boolean = false;
		private static const mainClassName: String = "Main";
		
		private static const BG_COLOR:uint = 0xf7dfd4;
		private static const FG_COLOR:uint = 0x0;
		
		[Embed(source="images/back.png")]
		public static const BgGfx: Class;
		
		[Embed(source = 'fonts/7x5.ttf', embedAsCFF="false", fontFamily = '7x5')]
		public static const FONT1:Class;
		
		public static var stage:Stage;
		
		public static var bg:BitmapData;
		
		
		
		// Ignore everything else
		
		
		
		private var progressBar: Shape;
		private var text: TextField;
		
		private var px:int;
		private var py:int;
		private var w:int;
		private var h:int;
		private var sw:int;
		private var sh:int;
		
		public function Preloader ()
		{
			Preloader.stage = this.stage;
			
			var touchscreen:Boolean = false;
			
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				touchscreen = true;
			}
			else if (Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0) {
				touchscreen = true;
			} else if (Capabilities.os.indexOf("QNX") >= 0) {
				touchscreen = true;
			}
			
			sw = stage.stageWidth;
			sh = stage.stageHeight;
			
			if (touchscreen) {
				sw = stage.fullScreenWidth;
				sh = stage.fullScreenHeight;
			}
			
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			w = stage.stageWidth * 0.8;
			h = 20;
			
			px = (sw - w) * 0.5;
			py = (sh - h) * 0.5;
			
			addBG();
			
			progressBar = new Shape();
			
			text = new TextField();
			
			text.textColor = FG_COLOR;
			text.selectable = false;
			text.mouseEnabled = false;
			text.defaultTextFormat = new TextFormat("7x5", 16);
			text.embedFonts = true;
			text.autoSize = "left";
			text.text = "0%";
			text.x = (sw - text.width) * 0.5;
			text.y = sh * 0.5 + h;
			
			if (! touchscreen) {
				addChild(progressBar);
				addChild(text);
			}
			
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if (mustClick) {
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}

		private function addBG ():void
		{
			bg = new BitmapData(sw, sh, true, 0x0);
			
			var m:Matrix = new Matrix;
			var sprite:Sprite = new Sprite;
			
			sprite.graphics.beginBitmapFill((new BgGfx).bitmapData);
			sprite.graphics.drawRect(0, 0, sw, sh);
			sprite.graphics.endFill();
			
			bg.draw(sprite);
			
			m.createGradientBox(sw, sh, 0, 0, 0);
			sprite.graphics.clear();
			sprite.graphics.beginGradientFill("radial", [0x0, 0x0], [0.0,1.0], [0,255], m);
			sprite.graphics.drawRect(0, 0, sw, sh);
			sprite.graphics.endFill();
			
			bg.draw(sprite, null, null, "overlay");
			
			var bitmap:Bitmap = new Bitmap(bg);
			
			bitmap.x = (stage.stageWidth - sw)*0.5;
			bitmap.y = (stage.stageHeight - sh)*0.5;
			
			addChild(bitmap);
		}

		public function onEnterFrame (e:Event): void
		{
			if (hasLoaded())
			{
				if (! mustClick) {
					startup();
				} else {
					text.scaleX = 2.0;
					text.scaleY = 2.0;
				
					text.text = "Click to start";
			
					text.y = (sh - text.height) * 0.5;
				}
			} else {
				var p:Number = (loaderInfo.bytesLoaded / loaderInfo.bytesTotal);
				
				progressBar.graphics.clear();
				progressBar.graphics.beginFill(FG_COLOR);
				progressBar.graphics.drawRect(px - 2, py - 2, w + 4, h + 4);
				progressBar.graphics.endFill();
				progressBar.graphics.beginFill(BG_COLOR);
				progressBar.graphics.drawRect(px, py, p * w, h);
				progressBar.graphics.endFill();
				
				text.text = int(p * 100) + "%";
			}
			
			text.x = (sw - text.width) * 0.5;
		}
		
		private function onMouseDown(e:MouseEvent):void {
			if (hasLoaded())
			{
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				startup();
			}
		}
		
		private function hasLoaded (): Boolean {
			return (loaderInfo.bytesLoaded >= loaderInfo.bytesTotal);
		}
		
		private function startup (): void {
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			var mainClass:Class = getDefinitionByName(mainClassName) as Class;
			parent.addChild(new mainClass as DisplayObject);
			
			parent.removeChild(this);
		}
	}
}


