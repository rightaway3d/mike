/**Created by the Morn,do not modify.*/
package game.ui.mike {
	import morn.core.components.*;
	public class AddItemListUI extends View {
		protected static var uiXML:XML =
			<View width="700" height="400">
			  <List x="19" y="23" repeatX="1" repeatY="5" spaceX="2" spaceY="5" name="addItemList">
			    <Box name="render" x="0" y="0" width="596" height="81">
			      <Image skin="png.comp.blank" x="9" y="-4" width="613" height="81" alpha="0" smoothing="true"/>
			      <Image skin="png.comp.blank" width="80" height="80" name="icon" x="10" y="0" smoothing="true"/>
			      <Label text="物品名称：" x="112" y="10" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Label text="规格：" x="112" y="38" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Label text="数量：" x="310" y="10" width="50" height="19" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Label text="单价：" x="310" y="38" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Label text="label" x="179" y="10" width="130" height="18" name="name" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Label text="label2" x="156" y="38" width="108" height="18" name="specifications" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Label text="label" x="353" y="10" width="58" height="18" name="memo" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Label text="label" x="353" y="38" width="80" height="18" name="price" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Image skin="png.comp.blank" x="428" y="6" width="4" height="61" alpha="0.5" smoothing="true"/>
			      <Label text="总价：" x="455" y="27" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Label text="label" x="496" y="27" width="71" height="18" name="totalPrice" color="0xffffff" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			      <Button skin="png.comp.iconDel_up" x="574" y="26" stateNum="1" width="20" height="20" name="removeBtn" smoothing="true"/>
			    </Box>
			    <VScrollBar skin="png.comp.vscroll" x="640" width="17" height="354" name="scrollBar" y="0" showButtons="false" touchScrollEnable="true" visible="false"/>
			  </List>
			</View>;
		public function AddItemListUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}