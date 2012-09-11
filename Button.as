package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Button extends Entity
	{
		public var image:Image;
		public var callback:Function;
		
		public static var defaultColorTextNormal:uint = 0x6AAE26;
		public static var defaultColorTextHover:uint = 0x1F922E;
		public static var defaultColorImageNormal:uint = 0xFFFFFF;
		public static var defaultColorImageHover:uint = 0xCCCCCC;
		
		public var normalColor:uint;
		public var hoverColor:uint;
		
		public var over:Boolean;
		
		public static var lastPressed:Button;
		
		public function Button (_gfx:*, _callback:Function, options:Object = null)
		{
			if (_gfx is Image) {
				image = _gfx;
			} else {
				var textOpts:Object = {};
				textOpts.size = _gfx.size;
				//textOpts.font = "orbitron";
				textOpts.outlineStrength = 4.0;
				textOpts.outlineColor = defaultColorTextHover;
				textOpts.letterSpacing = 2.0;
			
				image = new Text(_gfx.text, 0, 0, textOpts);
			}
			
			if (image is Text) {
				normalColor = defaultColorTextNormal;
				hoverColor = defaultColorTextHover;
			} else {
				normalColor = defaultColorImageNormal;
				hoverColor = defaultColorImageHover;
			}
			
			if (options) {
				if (options.hasOwnProperty("normalColor")) normalColor = options.normalColor;
				if (options.hasOwnProperty("hoverColor")) hoverColor = options.hoverColor;
			}
			
			image.color = normalColor;
			
			image.scrollX = image.scrollY = 0;
			
			graphic = image;
			
			type = "button";
			
			width = image.width;
			height = image.height;
			
			callback = _callback;
		}
		
		public override function update (): void
		{
			if (!world || !collidable || !visible) return;
			
			over = collidePoint(x, y, Input.mouseX, Input.mouseY);
			
			if (Main.touchscreen && ! Input.mouseDown) over = false;
			
			if (over) {
				Input.mouseCursor = "button";
			}
			
			image.color = over ? hoverColor : normalColor;
			
			if (image is Text) {
				Text(image).outlineColor = over ? FP.colorLerp(0x0, defaultColorTextHover, 0.8) : defaultColorTextHover;
				Text(image).updateTextBuffer();
			}
			
			if (over && Input.mousePressed && callback != null) {
				lastPressed = this;
				callback();
			}
		}
	}
}

