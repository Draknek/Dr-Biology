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
		
		public static var defaultColorNormal:uint = 0x000000;
		public static var defaultColorHover:uint = 0x6d6d6d;
		
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
			
				image = new Text(_gfx.text, 0, 0, textOpts);
			}
			
			normalColor = defaultColorNormal;
			hoverColor = defaultColorHover;
			
			if (options) {
				if (options.hasOwnProperty("normalColor")) normalColor = options.normalColor;
				if (options.hasOwnProperty("hoverColor")) normalColor = options.hoverColor;
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
			
			if (over) {
				Input.mouseCursor = "button";
			}
			
			image.color = over ? hoverColor : normalColor;
			
			if (over && Input.mousePressed && callback != null) {
				lastPressed = this;
				callback();
			}
		}
	}
}

