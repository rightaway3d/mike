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
			  <Image compId="5" skin="png.comp.blank" x="0" y="0" layer="2" width="400" height="250"/>
			  <Button compId="2" width = "50" height = "25" label="确定" skin="" x="80" y="200" labelSize="16" labelColors="0xFFFFFF,0xFFFFFF" layer="1" var="yes_btn" name="yes" />
			  <Button compId="3" width = "50" height = "25" label="取消" skin="" x="262" y="200" labelSize="16" labelColors="0xFFFFFF,0xFFFFFF" layer="1" var="no_btn" name="no" />
			  <Label compId="6" text="提示" styleSkin="" x="10" y="10" layer="1" color="0xffffff" size="18" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			  <Label compId="7" text="label" styleSkin="" x="20" y="94" width="360" height="100" align = "center"layer="1" color="0xffffff"  size="16" var="msg_label" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			</Dialog>;
		
		public function Alert(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
			yes_btn.btnLabel.font ="造字工房悦黑(非商用)细体" ;
			yes_btn.btnLabel.embedFonts = true;
			
			no_btn.btnLabel.font ="造字工房悦黑(非商用)细体" ;
			no_btn.btnLabel.embedFonts = true;
		}
	}
}