package rightaway3d.house.editor2d
{
	import com.google.zxing.BarcodeFormat;
	import com.google.zxing.EncodeHintType;
	import com.google.zxing.common.BitMatrix;
	import com.google.zxing.common.flexdatatypes.HashTable;
	import com.google.zxing.qrcode.QRCodeWriter;
	import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import rightaway3d.utils.MyTextField;
	import rightaway3d.utils.Tween;
	
	public class ShareBox extends Sprite
	{
		[Embed(source="/../assets/logo.png")]
		private var Logo:Class;
		
		private var bg_shp:Shape;
		private var ti_txt:MyTextField;
		private var qr_bmp:Bitmap;
		
		private var writer:QRCodeWriter;
		
		private var timer:Timer;
		
		public function ShareBox()
		{
			super();
			init();
		}
		
		private function init():void
		{
			bg_shp = new Shape();
			this.addChild(bg_shp);
			
			ti_txt = new MyTextField();
			this.addChild(ti_txt);
			ti_txt.text = "微信分享扫一扫";
			ti_txt.textSize = 20;
			ti_txt.textColor = 0x777777;
			ti_txt.align = TextFormatAlign.CENTER;
			
			ti_txt.width = ti_txt.textWidth+9;
			ti_txt.height = ti_txt.textHeight;
			
			ti_txt.y = 5;
			ti_txt.x = (qrSize-ti_txt.width)/2;
			
			ti_txt.mouseEnabled = ti_txt.mouseWheelEnabled = false;
			
			qr_bmp = new Bitmap();
			this.addChild(qr_bmp);
			qr_bmp.y = ti_txt.y + ti_txt.height - 5;
			
			var logo:Bitmap = new Logo();
			this.addChild(logo);
			logo.x = (qrSize-logo.width)/2;
			logo.y = qr_bmp.y + logo.x;
			
			updateBG();
			
			writer = new QRCodeWriter();
			
			timer = new Timer(20000);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			timer.start();
			
			this.addEventListener(MouseEvent.MOUSE_MOVE,show);
		}
		
		protected function show(e:MouseEvent):void
		{
			if(!isTween)
			{
				if(isClose)
				{
					tween(vh - qr_bmp.y - qrSize);
					isClose = false;
				}
				else
				{
					timer.reset();
				}
				timer.start();
			}
		}
		
		private var vw:int;
		private var vh:int;
		
		private var isTween:Boolean = false;
		private var isClose:Boolean = false;
		
		protected function onTimer(e:TimerEvent):void
		{
			timer.stop();
			
			tween(vh - ti_txt.y - ti_txt.height);
			isClose = true;
		}
		
		private function tween(y_:Number,time:int=500):void
		{
			Tween.to(this,time,{y:y_},onTweenComplete);
			isTween = true;
		}
		
		private function onTweenComplete(target:Object):void
		{
			isTween = false;
		}
		
		private var qrSize:int = 200;
		private var border:int = 0;
		
		public function updateQR(url:String):void
		{
			 var ht:HashTable = new HashTable(2);
			 ht.Add(EncodeHintType.CHARACTER_SET, "UTF-8");
			 ht.Add(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
			 
			 var bm:BitMatrix = writer.encode(url, BarcodeFormat.QR_CODE, qrSize, qrSize, ht) as BitMatrix;
			 qr_bmp.bitmapData = toBitmapData(bm);
			 
			 show(null);
		}
		
		private function toBitmapData(bytes:BitMatrix):BitmapData
		{
			var w:int = bytes.width, h:int = bytes.height;
			var bmp:BitmapData = new BitmapData(w, h, true, 0);
			
			for (var i:int = 0; i < w; i++)
			{
				for (var j:int = 0; j < h;j++)
				{
					//bmp.setPixel(i, j, bytes._get(i,j)?0:0xffffff);
					bmp.setPixel32(i, j, bytes._get(i,j) ? 0xff000000 : 0);//0x66000000
				}
			}
			
			return bmp;
		}
		
		public function updateView(w:int,h:int):void
		{
			vw = w;
			vh = h;
			
			//var n:Number = (h<w ? h : w) * 0.2;//二维码尺寸取短边1/5的长度
			//qrSize = n>200 ? 200 : (n<100 ? 100 : n);//二维码尺寸限制在100-200之间
			trace("qrSize:"+qrSize,w,h);
			
			this.x = w - qrSize - border;
			this.y = h - qr_bmp.y - qrSize;
		}
		
		private function updateBG():void
		{
			var g:Graphics = bg_shp.graphics;
			g.clear();
			
			var a:Number = 0.8;
			var c:int = 0xffffff;
			g.lineStyle(0,c,a);
			g.beginFill(c,a);
			g.drawRoundRect(0,0,qrSize,qr_bmp.y+qrSize,28);
			g.endFill();
		}
		
		static private var _instance:ShareBox;
		static public function get instance():ShareBox
		{
			_instance ||= new ShareBox();
			return _instance;
		}
	}
}