package game.ui.mike
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import morn.core.components.Button;
	import morn.core.components.Label;
	import morn.core.handlers.Handler;
	
	import rightaway3d.engine.utils.GlobalVar;
	import rightaway3d.engine.utils.Tips;
	import rightaway3d.house.editor2d.Mike;
	
	public class SquarePillarSizer extends Sprite
	{
		public var options:Sprite;
		public var stageWidth:Number;
		public var stageHeight:Number;
		public var inited:Boolean = false;
		private var bgMax:Sprite ;
		
		public var pillarWidth_txt:TextField;
		public var pillarDepth_txt:TextField;
		public var tips_txt:TextField;
		
		public var onOkFun:Function;
		
		public function SquarePillarSizer()
		{
			super();
		}
		
		private function init():void
		{
			options = new Sprite();
			bgMax = new Sprite();
			bgMax.graphics.beginFill(0x0,0.3);
			bgMax.graphics.drawRect(0,0,stageWidth,stageHeight);
			bgMax.graphics.endFill();
			bgMax.name = "bgMax";
			addChild(bgMax);
			addChild(options);
			inited = true;
		}
		
		private function initContent():void
		{
			
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0x0,0.5);
			bg.graphics.drawRect(0,0,400,300);
			bg.graphics.endFill();
			options.addChild(bg); 
			
			var title:Label = new Label("修改立柱尺寸");
			title.size = 20;
			title.setSize(400,50);
			//title.align = "center";
			title.color = 0xFFFFFF;
			options.addChild(title);
			title.x = 15;
			title.y = 15;	
			
			pillarWidth_txt = addInputItem("立柱宽度：","3000",50,100);
			pillarDepth_txt = addInputItem("立柱进深：","3000",50,150);
			//tips_txt = addInputItem("墙体厚度：","200",50,160);
			
			var cancel:Button = new Button();
			cancel.setSize( 60,30);
			cancel.label = "取消";
			options.addChild(cancel);
			cancel.showBorder(0xFFFFFF);
			
			var okBtn:Button = new Button();
			okBtn.setSize( 60,30);
			okBtn.label = "确定";
			
			options.addChild(okBtn);
			okBtn.showBorder(0xFFFFFF);
			okBtn.x = 80;
			cancel.x = 260;
			cancel.labelSize = okBtn.labelSize = 18;
			cancel.labelColors = okBtn.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
			cancel.clickHandler = new Handler(optionsCloseClick);
			okBtn.clickHandler = new Handler(optionsOkClick);
			okBtn.y = cancel.y = 250;
			okBtn.buttonMode = cancel.buttonMode = true;
			
			//关闭按钮
			var closeBtn:Button = new Button("png.comp.icon_close_large");
			closeBtn.setSize(25,20);
			closeBtn.x = 400-30;
			closeBtn.y = 5;
			options.addChild(closeBtn);
			closeBtn.clickHandler = new Handler(optionsCloseClick);
			closeBtn.stateNum = 1;
			closeBtn.buttonMode = true;
			
		}
		
		private function addInputItem(label:String,value:String,x_:Number,y_:Number):TextField
		{
			var title1:Label = new Label(label);
			title1.size = 18;
			title1.color = 0xFFFFFF;
			title1.align = TextFormatAlign.LEFT;
			title1.setSize(153,30);
			title1.x = x_;//20;
			title1.y = y_;//100;
			
			var format:TextFormat = new TextFormat();
			format.align = "center";
			format.size = 18;
			format.color = 0xFFFFFF;
			
			var inputText:TextField = new TextField();
			inputText.defaultTextFormat = format;
			inputText.type = TextFieldType.INPUT;
			inputText.width =200;
			inputText.height = 30;
			inputText.x = x_+80;//180;
			inputText.y = y_;//100;
			inputText.restrict ="0-9";
			inputText.text = value;
			inputText.name = "inputText";
			options.addChild(inputText);
			var lineW:int = inputText.width;
			var lineH:int = inputText.height+y_-4;//90;
			
			var line:Shape = new Shape();
			line.graphics.lineStyle(1,0xEEEEEE,0.8);
			//line.graphics.moveTo(180,lineH+5);
			//line.graphics.lineTo(380,lineH+5);
			line.graphics.moveTo(x_+80,lineH);
			line.graphics.lineTo(x_+280,lineH);
			line.graphics.endFill();
			options.addChild(title1);
			options.addChild(line);
			
			return inputText;
		}
		
		private function optionsOkClick():void
		{
			//if(onOkFun)
			//{
				var rw:int = int(pillarWidth_txt.text);
				var rd:int = int(pillarDepth_txt.text);
				if(onOkFun(GlobalVar.own.currProduct,rw,rd))
				{
					optionsCloseClick();
				}
				else
				{
					Tips.show("空间不够放置立柱",stage.mouseX-80,stage.mouseY,4000);
				}
			//}
			
		}
		
		private function optionsCloseClick():void
		{
			parent.removeChild(this);
			Mike.instance.startKeyAction();
		}
		
		public function show(parent:DisplayObjectContainer):void
		{
			Mike.instance.stopKeyAction(null);
			if(!inited) 
			{
				init();
				initContent();
			}else
			{
			}
			parent.addChild(this);
			
			options.x =(stageWidth-options.width)>>1
			options.y =(stageHeight-options.height)>>1
		}
		
		public function resizeContent():void
		{
			if(options)
			{
				options.x = (stageWidth-options.width)>>1;
				options.y = (stageHeight-options.height)>>1;
				bgMax.width = stageWidth;
				bgMax.height = stageHeight;
				bgMax.x = bgMax.y = 0;
			}
			
		}
	}
}

