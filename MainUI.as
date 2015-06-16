package
{
	import flash.events.MouseEvent;
	
	import game.ui.mike.mainUI;
	
	import morn.core.components.Container;
	import morn.core.components.Image;
	import morn.core.components.List;
	import morn.core.components.Tree;
	import morn.core.handlers.Handler;
	
	import ztc.utils.Tween;
	
	public class MainUI extends mainUI
	{
		public var assets:Container;
		public var tree:Tree;
		public var list:List;
		public var mainBtn:Image;
		public var uiShow:Boolean = true;
		
		private var originalX:Number;
		
		public function MainUI()
		{
			super();
			initUI();
		}
		
		private function initUI():void
		{
			// container
			assets = getChildByName('assets') as Container;
			originalX = assets.x;
			// 树
			tree = assets.getChildByName('tree') as Tree;
			tree.mouseHandler = new Handler(treeMouseHandler);
			// List
			list = assets.getChildByName('list') as List;
			list.mouseHandler = new Handler(listMouseHandler);
			// mainBtn
			mainBtn = getChildByName('mainBtn') as Image;
			mainBtn.addEventListener(MouseEvent.CLICK, onMainBtnClick);
		}
		
		protected function onMainBtnClick(event:MouseEvent):void
		{
			mainBtn.visible = false;
			assets.visible = true;
			var alpha:Number, x:Number;
			assets.alpha = uiShow ? 0 : 1.0;
			assets.x = uiShow ? originalX - 200 : originalX;
			Tween.Instance.action(assets, .4, {
				alpha: uiShow ? 1.0 : 0.0,
				x : uiShow ? originalX : originalX - 200.0
			}, Tween.EaseOutBack, function():void {
				assets.visible = uiShow;
				uiShow = !uiShow;
				mainBtn.visible = true;
			});
		}
		
		private function listMouseHandler(e:MouseEvent, index:int):void
		{
			if(e.type == MouseEvent.CLICK) {
				e.stopPropagation();
				
				if (MikeUI.instance.listSelectHandler) {
					MikeUI.instance.listSelectHandler(MikeUI.instance.itemList[index]);
				}
			}	
		}
		
		private function treeMouseHandler(e:MouseEvent, index:int):void
		{
			if(e.type == MouseEvent.CLICK) {
				if(MikeUI.instance.treeSelectHandler) {
					MikeUI.instance.treeSelectHandler(tree.selectedItem);
				}
			}			
		}
	}
}