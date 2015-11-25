package{	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import rightaway3d.house.editor2d.Mike;
	import rightaway3d.utils.MyTextField;
		[SWF(backgroundColor="#E2E2E2", frameRate="30", width="1600", height="800")]	public class Main extends Mike	{		public function Main()		{			super();			initBtn();		}				private var btn:Sprite;		private function initBtn():void		{			btn = new Sprite();			stage.addChild(btn);			btn.y = 10;			btn.mouseChildren = false;			btn.useHandCursor = true;			btn.addEventListener(MouseEvent.CLICK,onBtnClick);						var txt:MyTextField = new MyTextField();			txt.textSize = 18;			txt.textColor = 0xffffff;			txt.text = "2D/3D切换";			txt.width = txt.textWidth + 5;			txt.height = txt.textHeight + 2;			txt.x = 5;			txt.y = 5;						btn.addChild(txt);			btn.graphics.lineStyle(1,0xffffff);			btn.graphics.beginFill(0,0.2);			btn.graphics.drawRect(0,0,txt.width+10,txt.height+10);			btn.graphics.endFill();						stage.addEventListener(Event.RESIZE,onResized);			onResized();		}				private function onResized(e:Event=null):void		{			btn.x = stage.stageWidth - btn.width - 10;		}				protected function onBtnClick(event:MouseEvent):void
		{
			switchView();
		}	}}