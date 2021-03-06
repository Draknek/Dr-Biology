package
{
	import net.flashpunk.*;
	import net.flashpunk.debug.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.net.*;
	import flash.geom.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.desktop.*;
	import flash.display.*;
	import flash.ui.*;
	
	public class Main extends Engine
	{
		public static var TW:int = 36;
		public static var SCALE:int = 1;
		public static var SCALE_BUTTONS:Number = 1;
		
		public static var TILES_WIDE:int = 10;
		public static var TILES_HIGH:int = 8;
		
		public static var scaleFunction:Function;
		
		public static var devMode:Boolean = true;
		
		public static var noeditor:Boolean = true;
		
		public static var touchscreen:Boolean = false;
		public static var isAndroid:Boolean = false;
		public static var isIOS:Boolean = false;
		public static var isPlaybook:Boolean = false;
		public static var platform:String = "";
		
		public static var mouseX:int;
		public static var mouseY:int;
		
		public static const so:SharedObject = SharedObject.getLocal("draknek/cells", "/");
		
		
		[Embed(source="levels.list", mimeType="application/octet-stream")]
		public static const LEVELS:Class;
		
		[Embed(source = 'fonts/Maian.ttf', embedAsCFF="false", fontFamily = 'maian')]
		public static const FONT1:Class;
		
		public static var MenuClass:Class;
		
		
		public function Main () 
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				isIOS = true;
				touchscreen = true;
				platform = "ios";
			}
			else if (Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0) {
				isAndroid = true;
				touchscreen = true;
				platform = "android";
			} else if (Capabilities.os.indexOf("QNX") >= 0) {
				isPlaybook = true;
				touchscreen = true;
				platform = "blackberry";
			}
			
			if (! so.data.completed) {
				so.data.completed = [];
			}
			
			var w:int = 640;
			var h:int = 480;
			
			if (touchscreen) {
				try {
					Preloader.stage.displayState = StageDisplayState['FULL_SCREEN_INTERACTIVE'];
				} catch (e:Error) {}
				
				w = Preloader.stage.fullScreenWidth;
				h = Preloader.stage.fullScreenHeight;
				
				if (isAndroid && w < h) {
					var tmp:int = w;
					w = h;
					h = tmp;
				}
			} else {
				w = Preloader.stage.stageWidth;
				h = Preloader.stage.stageHeight;
			}
			
			TW = Math.min(Math.floor(w/TILES_WIDE), Math.floor(h/TILES_HIGH));
			
			TW = Math.floor(TW/2)*2;
			
			SCALE = Math.floor(TW/36);
			
			if (SCALE < 1) SCALE = 1;
			if (SCALE > 4) SCALE = 4;
			
			SCALE_BUTTONS = SCALE;
			
			if (SCALE > 1) SCALE_BUTTONS *= 0.75;
			
			TW = Math.floor(TW / SCALE);
			
			if (TW <= 32) TW = 32;
			else if (TW <= 40) TW = 34;
			else if (TW <= 48) TW = 36;
			else TW = 38;
			
			TW *= SCALE;
			
			TW = Math.floor(TW/2)*2;
			
			scaleFunction = ScaleX["scale" + SCALE + "x"];
			
			super(w, h, 60, true);
			
			FP.screen.color = 0xf7dfd4;
			
			//FP.console.enable();
		}
		
		public override function setStageProperties():void
		{
			super.setStageProperties();
			
			if (touchscreen) {
				try {
					stage.displayState = StageDisplayState['FULL_SCREEN_INTERACTIVE'];
				} catch (e:Error) {
					//stage.align = StageAlign.TOP;
					//stage.scaleMode = StageScaleMode.SHOW_ALL;
				}
			} else {
				stage.align = StageAlign.TOP;
				stage.scaleMode = StageScaleMode.SHOW_ALL;
			}
		}
		
		public override function init (): void
		{
			sitelock(["draknek.org", "flashgamelicense.com"]);
			
			Audio.init(this);
			
			Text.font = "maian";
			
			LevelData.readLevelPack(new LEVELS);
			
			Editor.init();
			
			super.init();
			
			var startWorld:World;
			
			if (stage.loaderInfo.parameters) {
				if (stage.loaderInfo.parameters.leveldata) {
					var dataString:String = stage.loaderInfo.parameters.leveldata;
					dataString = dataString.split(" ").join("+");
					
					var data:LevelData = new LevelData;
					data.fromString(dataString);
					
					startWorld = new Level(data);
					
					noeditor = true;
				}
				
				if (stage.loaderInfo.parameters.editor) {
					noeditor = false;
					startWorld = new Editor();
				}
				
				if (stage.loaderInfo.parameters.noeditor) {
					noeditor = true;
				}
			}
			
			if (! startWorld) startWorld = new Menu;
			
			//startWorld = new Level(null, 1);
			
			FP.world = startWorld;
			
			var menu:ContextMenu = contextMenu || new ContextMenu;
			
			menu.hideBuiltInItems();
			
			if (! noeditor) {
				menu.clipboardMenu = true;
				menu.clipboardItems.copy = true;
				menu.clipboardItems.paste = true;
				menu.clipboardItems.clear = true;
			
				addEventListener(Event.COPY, copyHandler);
				addEventListener(Event.PASTE, pasteHandler);
				addEventListener(Event.CLEAR, clearHandler);
			}
			
			contextMenu = menu;
			
			addEventHandlers();
		}
		
		private static function addEventHandlers ():void
		{
			FP.stage.addEventListener(MouseEvent.MOUSE_DOWN, extraMouseListener);
			
			if (touchscreen) {
				FP.stage.addEventListener(MouseEvent.MOUSE_UP, touchscreenMouseUp);
			}
			
			if (isAndroid) {
				try {
					var NativeApplication:Class = getDefinitionByName("flash.desktop.NativeApplication") as Class;
					
					NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, extraKeyListener);
				}
				catch (e:Error) {}
			
				//fixAndroidLag();
			}
			
			fixIOSOrientation();
		}
		
		private function copyHandler(event:Event):void 
		{
			var src:LevelData;
			
			var level:Level = FP.world as Level;
			
			if (level) {
				src = level.data;
			} else {
				src = Editor.data;
			}
			
			var levelcode:String = src.toString();
			
			if (FP.stage.loaderInfo.parameters && FP.stage.loaderInfo.parameters.editor) {
				levelcode = "http://draknek.org/games/drbiology/?level=" + levelcode;
			}
			
			System.setClipboard(levelcode);
		}
		
		private function pasteHandler(event:Event):void 
		{
			var clipboard:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
			
			var index:int = clipboard.indexOf('?');
			
			if (index != -1) {
				var index2:int = clipboard.indexOf('=', index);
				
				if (index2 == -1) {
					index += 1;
				} else {
					index = index2 + 1;
				}
				
				clipboard = clipboard.substring(index);
			}
			
			var level:Level = FP.world as Level;
			
			if (level) {
				var data:LevelData = new LevelData;
				data.fromString(clipboard);
				FP.world = new Level(data);
			}
			
			var editor:Editor = FP.world as Editor;
			
			if (editor) {
				Editor.data.fromString(clipboard);
			}
			
			//parseLevelPack(clipboard);
		}
		
		private function clearHandler(event:Event):void 
		{
			var level:Level = FP.world as Level;
			
			if (level) {
				//FP.world = new Level(level.src, level.id);
			}
			
			var editor:Editor = FP.world as Editor;
			
			if (editor) {
				Editor.clear();
			}
		}
		
		private static function extraMouseListener(event:MouseEvent):void
		{
			if (! FP.world.active) return;
			
			var a:Array = [];
			
			FP.world.getType("button", a);
			
			for each (var b:Button in a) {
				if (b.callback == null || b.disabled) continue;
				
				var _x:Number = b.x;
				var _y:Number = b.y;
			
				var over:Boolean = b.collidePoint(_x, _y, event.stageX, event.stageY);
				
				if (over) {
					Button.lastPressed = b;
					b.callback();
				}
			}
		}
		
		private static function touchscreenMouseUp (event:MouseEvent):void
		{
			Main.mouseX = FP.screen.mouseX;
			Main.mouseY = FP.screen.mouseY;
		}
		
		private static function extraKeyListener(e:KeyboardEvent):void
		{
			try {
			const BACK:uint   = ("BACK" in Keyboard)   ? Keyboard["BACK"]   : 0;
			const MENU:uint   = ("MENU" in Keyboard)   ? Keyboard["MENU"]   : 0;
			const SEARCH:uint = ("SEARCH" in Keyboard) ? Keyboard["SEARCH"] : 0;
			
			if(e.keyCode == BACK) {
				if (FP.world is Menu) {
					return;
				} else if (FP.world is Level) {
					FP.world = new MenuClass;
				} else {
					FP.world = new Menu;
				}
			} else if(e.keyCode == SEARCH) {
				
			} else {
				return;
			}
			
			e.preventDefault();
			e.stopImmediatePropagation();
			} catch (e:Error) {}
		}
		
		private static function fixIOSOrientation ():void
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				try {
					var StageAspectRatio:Class = getDefinitionByName("flash.display.StageAspectRatio") as Class;
					var StageOrientation:Class = getDefinitionByName("flash.display.StageOrientation") as Class;
					var StageOrientationEvent:Class = getDefinitionByName("flash.events.StageOrientationEvent") as Class;
					
					FP.stage["setAspectRatio"]( StageAspectRatio.LANDSCAPE );
					
					var startOrientation:String = FP.stage["orientation"];
					
					if (startOrientation == StageOrientation.DEFAULT || startOrientation == StageOrientation.UPSIDE_DOWN)
					{
						FP.stage["setOrientation"](StageOrientation.ROTATED_RIGHT);
					}
					else
					{
						FP.stage["setOrientation"](startOrientation);
					}

					FP.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, orientationChangeListener);
				} catch (e:Error){}
			}
		}
		
		private static function orientationChangeListener(e:*): void
		{
			if (e.afterOrientation == "default" || e.afterOrientation ==  "upsideDown")
			{
				e.preventDefault();
			}
		}
		
		public override function update (): void
		{
			if (! touchscreen || Input.mouseDown) {
				Main.mouseX = FP.screen.mouseX;
				Main.mouseY = FP.screen.mouseY;
			}
			
			if (Input.pressed(FP.console.toggleKey)) {
				// Doesn't matter if it's called when already enabled
				FP.console.enable();
			}
			
			if (! touchscreen || FP.focused) {
				super.update();
			} else {
				if (FP.tweener.active) FP.tweener.updateTweens();
			}
		}
		
		[Embed(source="images/back.png")]
		public static const BgGfx: Class;
		
		public static var bg:BitmapData;
		
		public override function preRender ():void
		{
			if (! bg) bg = Preloader.bg;
			
			FP.buffer.copyPixels(bg, bg.rect, FP.zero);
		}
		
		public override function render ():void
		{
			if (! touchscreen || FP.focused) {
				super.render();
			}
		}
		
		public function sitelock (allowed:*):Boolean
		{
			var url:String = FP.stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) != 'http://'
				&& url.substr(0, startCheck) != 'https://'
				&& url.substr(0, startCheck) != 'ftp://') return true;
			
			var domainLen:int = url.indexOf('/', startCheck) - startCheck;
			var host:String = url.substr(startCheck, domainLen);
			
			if (allowed is String) allowed = [allowed];
			for each (var d:String in allowed)
			{
				if (host.substr(-d.length, d.length) == d) return true;
			}
			
			parent.removeChild(this);
			throw new Error("Error: this game is sitelocked");
			
			return false;
		}
	}
}

