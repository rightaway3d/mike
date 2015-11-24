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
	import morn.core.components.CheckBox;
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
		
		
		private function initOptionsTopWallWidthLabel():void
		{
			var title1:Label = new Label("顶墙封板最大宽度：");
			title1.font = MainUI.FontName;
			title1.embedFonts = true;
			title1.size = 16;
			title1.color = 0xFFFFFF;
			title1.align = TextFormatAlign.LEFT;
			title1.setSize(153,30);
			title1.x = 20;
			title1.y = 65;
			
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
			format.size = 16;
			format.color = 0xFFFFFF;
			
			var inputText:TextField = new TextField();
			inputText.defaultTextFormat = format;
			inputText.type = TextFieldType.INPUT;
			inputText.width =200;
			inputText.height = 30;
			inputText.x = 180;
			inputText.y = 65;
			inputText.restrict ="0-9";
			inputText.text = inputTextValue;//GlobalConfig.instance.wallPlateWidth.toString();;
			//inputText.tabEnabled = true;
			inputText.name = "inputText";
			options.addChild(inputText);
			//			inputText.addEventListener(FocusEvent.FOCUS_IN,onTextInputInFocus);
			//			inputText.addEventListener(FocusEvent.FOCUS_OUT,onTextInputInFocus);
			inputText.addEventListener(Event.CHANGE,onTextInputChange);
			var lineW:int = inputText.width;
			var lineH:int = inputText.height+55;
			
			var line:Shape = new Shape;
			line.graphics.lineStyle(1,0xEEEEEE,0.8);
			line.graphics.moveTo(180,lineH+5);
			line.graphics.lineTo(380,lineH+5);
			line.graphics.endFill();
			options.addChild(title1);
			options.addChild(line);
		}
		//初始化水盆开口宽度
		private function initOptionsBirdbathOpenWidthLabel():void
		{
			var checkBox:CheckBox = new CheckBox('png.comp.checkbox',"水盆开口尺寸 (单位:mm)");
			options.addChild(checkBox);
			checkBox.labelSize = 16;
			checkBox.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
			checkBox.labelFont = MainUI.FontName;
			checkBox.btnLabel.embedFonts = true;
			checkBox.labelMargin = "8";
			checkBox.y = 115;
			checkBox.x = 13;
			checkBox.name = "birdbathCheckBox";
			
			
			
			
			var format:TextFormat = new TextFormat();
			format.align = "center";
			format.size = 14;
			format.color = 0xFFFFFF;
			
			var title1:Label = new Label("长度");
			title1.font = MainUI.FontName;
			title1.embedFonts = true;
			title1.size = 14;
			title1.color = 0xFFFFFF;
			title1.align = TextFormatAlign.LEFT;
			title1.setSize(40,30);
			title1.x = 40;
			title1.y = 137;
			var inputText:TextField = new TextField();
			inputText.defaultTextFormat = format;
			inputText.type = TextFieldType.INPUT;
			inputText.width =40;
			inputText.height = 30;
			inputText.x = title1.x+title1.width+5;
			inputText.y = 140;
			inputText.restrict ="0-9";
			inputText.text = inputTextValue;
			inputText.name = "birdbathText1";
			options.addChild(inputText);
			inputText.addEventListener(Event.CHANGE,onTextInputChange);
			var lineW:int = inputText.width;
			var lineH:int = inputText.height+125;
			var line:Shape = new Shape;
			line.graphics.lineStyle(1,0xEEEEEE,0.8);
			line.graphics.moveTo(title1.x+title1.width+5,lineH+3);
			line.graphics.lineTo(inputText.x+inputText.width,lineH+3);
			options.addChild(title1);
			options.addChild(line);
			
			
			
			var title2:Label = new Label("进深");
			title2.font = MainUI.FontName;
			title2.embedFonts = true;
			title2.size = 14;
			title2.color = 0xFFFFFF;
			title2.align = TextFormatAlign.LEFT;
			title2.setSize(40,30);
			title2.x = inputText.x+inputText.width+15;
			title2.y = 137;
			var inputText2:TextField = new TextField();
			inputText2.defaultTextFormat = format;
			inputText2.type = TextFieldType.INPUT;
			inputText2.width =40;
			inputText2.height = 30;
			inputText2.x = title2.x+title2.width+5;
			inputText2.y = 140;
			inputText2.restrict ="0-9";
			inputText2.text = inputTextValue;
			inputText2.name = "birdbathText2";
			options.addChild(inputText2);
			inputText2.addEventListener(Event.CHANGE,onTextInputChange);
			var lineW2:int = inputText.width;
			var lineH2:int = inputText.height+125;
			line.graphics.moveTo(title2.x+title2.width+5,lineH2+3);
			line.graphics.lineTo(inputText2.x+inputText2.width,lineH2+3);
			options.addChild(title2);
			
			
			var title3:Label = new Label("圆角半径");
			title3.font = MainUI.FontName;
			title3.embedFonts = true;
			title3.size = 14;
			title3.color = 0xFFFFFF;
			title3.align = TextFormatAlign.LEFT;
			title3.setSize(70,30);
			title3.x = inputText2.x+inputText2.width+15;
			title3.y = 137;
			var inputText3:TextField = new TextField();
			inputText3.defaultTextFormat = format;
			inputText3.type = TextFieldType.INPUT;
			inputText3.width =40;
			inputText3.height = 30;
			inputText3.x = title3.x+title3.width+5;
			inputText3.y = 140;
			inputText3.restrict ="0-9";
			inputText3.text = inputTextValue;
			inputText3.name = "birdbathText3";
			options.addChild(inputText3);
			inputText3.addEventListener(Event.CHANGE,onTextInputChange);
			var lineW3:int = inputText.width;
			var lineH3:int = inputText.height+125;
			line.graphics.moveTo(title3.x+title3.width+5,lineH3+3);
			line.graphics.lineTo(inputText3.x+inputText3.width,lineH3+3);
			line.graphics.endFill();
			options.addChild(title3);
		}
		
		private function initOptionsStoveOpenWidthLabel():void
		{
			var checkBox:CheckBox = new CheckBox('png.comp.checkbox',"灶台开口尺寸 (单位:mm)");
			options.addChild(checkBox);
			checkBox.labelSize = 16;
			checkBox.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
			checkBox.labelFont = MainUI.FontName;
			checkBox.btnLabel.embedFonts = true;
			checkBox.labelMargin = "8";
			checkBox.y = 185;
			checkBox.x = 13;
			checkBox.name = "stoveCheckBox";

			var format:TextFormat = new TextFormat();
			format.align = "center";
			format.size = 14;
			format.color = 0xFFFFFF;
			
			var title1:Label = new Label("长度");
			title1.font = MainUI.FontName;
			title1.embedFonts = true;
			title1.size = 14;
			title1.color = 0xFFFFFF;
			title1.align = TextFormatAlign.LEFT;
			title1.setSize(40,30);
			title1.x = 40;
			title1.y = 207;
			var inputText:TextField = new TextField();
			inputText.defaultTextFormat = format;
			inputText.type = TextFieldType.INPUT;
			inputText.width =40;
			inputText.height = 30;
			inputText.x = title1.x+title1.width+5;
			inputText.y = 210;
			inputText.restrict ="0-9";
			inputText.text = inputTextValue;
			inputText.name = "stoveText1";
			options.addChild(inputText);
			inputText.addEventListener(Event.CHANGE,onTextInputChange);
			var lineW:int = inputText.width;
			var lineH:int = inputText.height+195;
			var line:Shape = new Shape;
			line.graphics.lineStyle(1,0xEEEEEE,0.8);
			line.graphics.moveTo(title1.x+title1.width+5,lineH+3);
			line.graphics.lineTo(inputText.x+inputText.width,lineH+3);
			options.addChild(title1);
			options.addChild(line);
			
			
			
			var title2:Label = new Label("进深");
			title2.font = MainUI.FontName;
			title2.embedFonts = true;
			title2.size = 14;
			title2.color = 0xFFFFFF;
			title2.align = TextFormatAlign.LEFT;
			title2.setSize(40,30);
			title2.x = inputText.x+inputText.width+15;
			title2.y = 210;
			var inputText2:TextField = new TextField();
			inputText2.defaultTextFormat = format;
			inputText2.type = TextFieldType.INPUT;
			inputText2.width =40;
			inputText2.height = 30;
			inputText2.x = title2.x+title2.width+5;
			inputText2.y = 210;
			inputText2.restrict ="0-9";
			inputText2.text = inputTextValue;
			inputText2.name = "stoveText2";
			options.addChild(inputText2);
			inputText2.addEventListener(Event.CHANGE,onTextInputChange);
			var lineW2:int = inputText.width;
			var lineH2:int = inputText.height+195;
			line.graphics.moveTo(title2.x+title2.width+5,lineH2+3);
			line.graphics.lineTo(inputText2.x+inputText2.width,lineH2+3);
			options.addChild(title2);
			
			
			var title3:Label = new Label("圆角半径");
			title3.font = MainUI.FontName;
			title3.embedFonts = true;
			title3.size = 14;
			title3.color = 0xFFFFFF;
			title3.align = TextFormatAlign.LEFT;
			title3.setSize(70,30);
			title3.x = inputText2.x+inputText2.width+15;
			title3.y = 210;
			var inputText3:TextField = new TextField();
			inputText3.defaultTextFormat = format;
			inputText3.type = TextFieldType.INPUT;
			inputText3.width =40;
			inputText3.height = 30;
			inputText3.x = title3.x+title3.width+5;
			inputText3.y = 210;
			inputText3.restrict ="0-9";
			inputText3.text = inputTextValue;
			inputText3.name = "stoveText3";
			options.addChild(inputText3);
			inputText3.addEventListener(Event.CHANGE,onTextInputChange);
			var lineW3:int = inputText.width;
			var lineH3:int = inputText.height+195;
			line.graphics.moveTo(title3.x+title3.width+5,lineH3+3);
			line.graphics.lineTo(inputText3.x+inputText3.width,lineH3+3);
			line.graphics.endFill();
			options.addChild(title3);
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
			
			initOptionsTopWallWidthLabel();
			initOptionsBirdbathOpenWidthLabel();
			initOptionsStoveOpenWidthLabel();
			
			
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
			
			if((options.getChildByName("birdbathCheckBox") as CheckBox).selected)
			{
				var birdbathText1:String = (options.getChildByName("birdbathText1") as TextField).text;
				var birdbathText2:String = (options.getChildByName("birdbathText2") as TextField).text;
				var birdbathText3:String = (options.getChildByName("birdbathText3") as TextField).text;
				
			}
			if((options.getChildByName("stoveCheckBox") as CheckBox).selected)
			{
				var stoveText1:String = (options.getChildByName("stoveText1") as TextField).text;
				var stoveText2:String = (options.getChildByName("stoveText2") as TextField).text;
				var stoveText3:String = (options.getChildByName("stoveText3") as TextField).text;
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