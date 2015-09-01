package game.ui.mike
{
	import morn.core.components.Button;
	import morn.core.components.Dialog;
	import morn.core.components.Label;

	public class Alert extends Dialog
	{
		public var msg_label:Label;
		public var yes_btn:Button;
		public var no_btn:Button;
		
		protected static var uiXML:XML =
			<Dialog width="400" height="250" sceneColor="0xffffff" compId="1" layers="1,1,0,0,第 1 层;2,1,0,0,第 2 层">
			  <Image compId="5" skin="png.comp.bg" x="0" y="0" layer="2" width="400" height="250" sizeGrid="4,40,4,4"/>
			  <Button compId="2" label="确定" skin="png.comp.button" x="80" y="200" layer="1" var="yes_btn" name="yes"/>
			  <Button compId="3" label="取消" skin="png.comp.button" x="262" y="200" layer="1" var="no_btn" name="no"/>
			  <Label compId="6" text="提示信息" styleSkin="png.comp.label" x="8" y="8" layer="1" color="0xffffff" size="15"/>
			  <Label compId="7" text="label" styleSkin="png.comp.label" x="68" y="94" layer="1" size="15" var="msg_label"/>
			</Dialog>;
		
		public function Alert(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}