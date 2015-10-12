package game.ui.mike
{
	
	/**
	 *配置参数菜单－－－－－－－－－－－－－ 
	 */	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import morn.core.components.Button;
	import morn.core.components.Label;
	import morn.core.handlers.Handler;
	
	import rightaway3d.engine.utils.Tips;
	import rightaway3d.house.editor2d.Mike;
	import rightaway3d.house.utils.GlobalConfig;
	
	public class OptionsUI extends Sprite
	{
		
		public var options:Sprite;
		public var stageWidth:Number;
		public var stageHeight:Number;
		public var inited:Boolean = false;
		private var oldText:String="";
		private var bgMax:Sprite ;
		
		private var inputTextValue:String;
		public function OptionsUI()
		{
			super();
		}
		
		private function init():void
		{
			inputTextValue = GlobalConfig.instance.wallPlateWidth.toString();
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
			//font="造字工房悦黑(非商用)细体" embedFonts="true"
			var title:Label = new Label("参数配置");
			title.size = 20;
			title.font = MainUI.FontName;
			title.embedFonts = true;
			title.setSize(400,50);
			title.align = "center";
			title.color = 0xFFFFFF;
			options.addChild(title);
			title.x = 0;
			title.y = 15;	
			
			
			
			var title1:Label = new Label("顶墙封板最大宽度：");
			title1.font = MainUI.FontName;
			title1.embedFonts = true;
			title1.size = 18;
			title1.color = 0xFFFFFF;
			title1.align = TextFormatAlign.LEFT;
			title1.setSize(153,30);
			title1.x = 20;
			title1.y = 100;
			
//			var title2:Label = new Label("最小值不可以小于100");
//			title2.size = 12;
//			title2.color = 0xcccccc;
//			title2.align = TextFormatAlign.LEFT;
//			title2.setSize(200,30);
//			title2.x = 180;
//			title2.y = 101;
//			options.addChild(title2);
//			title2.align = "center";
//			title2.name = "hint";
//			title2.alpha = 0.7;
//			title2.visible = false;
			
			var format:TextFormat = new TextFormat();
			format.align = "center";
			format.size = 18;
			format.color = 0xFFFFFF;
			
			var inputText:TextField = new TextField();
			inputText.defaultTextFormat = format;
			inputText.type = TextFieldType.INPUT;
			inputText.width =200;
			inputText.height = 30;
			inputText.x = 180;
			inputText.y = 100;
			inputText.restrict ="0-9";
			inputText.text = inputTextValue;//GlobalConfig.instance.wallPlateWidth.toString();;
			//inputText.tabEnabled = true;
			inputText.name = "inputText";
			options.addChild(inputText);
//			inputText.addEventListener(FocusEvent.FOCUS_IN,onTextInputInFocus);
//			inputText.addEventListener(FocusEvent.FOCUS_OUT,onTextInputInFocus);
			inputText.addEventListener(Event.CHANGE,onTextInputChange);
			var lineW:int = inputText.width;
			var lineH:int = inputText.height+90;
			
			var line:Shape = new Shape;
			line.graphics.lineStyle(1,0xEEEEEE,0.8);
			line.graphics.moveTo(180,lineH+5);
			line.graphics.lineTo(380,lineH+5);
			line.graphics.endFill();
			options.addChild(title1);
			options.addChild(line);
			
			
			var cancel:Button = new Button();
			cancel.setSize( 60,30);
			cancel.label = "取消";
			cancel.btnLabel.font = MainUI.FontName;
			cancel.btnLabel.embedFonts = true;
			options.addChild(cancel);
			cancel.showBorder(0xFFFFFF);
			
			var okBtn:Button = new Button();
			okBtn.setSize( 60,30);
			okBtn.label = "确定";
			okBtn.btnLabel.font = MainUI.FontName;
			okBtn.btnLabel.embedFonts = true;
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
		
		private function optionsOkClick():void
		{
			var text:String = (options.getChildByName("inputText") as TextField).text;
			if(text=="")
			{
				text ="0";
			}
			var wallPlateWidth:uint = parseInt(text);
			if(wallPlateWidth<100)
			{
				Tips.show("顶墙封板最大宽度不能小于100",stage.mouseX,stage.mouseY);
			}else
			{
				if(inputTextValue != text)
				{
					GlobalConfig.instance.wallPlateWidth =wallPlateWidth;
					inputTextValue = text;
				}
				optionsCloseClick();
			}
		}
		
		private function optionsCloseClick():void
		{
			parent.removeChild(this);
 			Mike.instance.startKeyAction();
		}
		
//		protected function onTextInputInFocus(event:FocusEvent):void
//		{
//			if(event.type ==FocusEvent.FOCUS_IN)
//			{
//				oldText = event.currentTarget.text;
//				
//				if(oldText=="")
//				{
//					options.getChildByName("hint").visible =false;
//				}
//			}else
//			{
//				if(oldText=="")
//				{
//					options.getChildByName("hint").visible =true;
//				}
//			}
//		}
		
		protected function onTextInputChange(event:Event):void
		{
			var text:TextField = event.currentTarget as TextField;
			if(text.text.charAt(0)=="0")
			{
				text.text = text.text.slice(1);
			}
//			if(text.text.charAt(0)=="0"&&text.text.length==2)
//			{
//				if(text.text !="0.")
//				{
//					text.text = text.text.slice(1);
//				}
//			}
//			else if(text.text.charAt(0)=='.'&&text.text.length==1)
//			{
//				text.text = "0.";
//				text.setSelection(text.length,text.length)  ;
//			}
			
//			if(parseInt(text.text)<=100)
//			{
////				text.text = oldText;
//			}else
//			{
//				oldText = text.text;
//			}
//			if(text.text=="")
//			{
//				options.getChildByName("hint").visible =true;
//			}else
//			{
//				options.getChildByName("hint").visible =false;
//			}
		}
		
		
		public function showOptionsUI(parent:DisplayObjectContainer):void
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
			(options.getChildByName("inputText") as TextField).text = inputTextValue;
//			options.getChildByName("hint").visible =false;
			
			
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