/**Created by the Morn,do not modify.*/
package game.ui.mike {
	import morn.core.components.*;
	import game.ui.mike.listItemViewUI;
	public class mainUI extends View {
		protected static var uiXML:XML =
			<View>
			  <Container x="10" y="105" name="assets" width="150" height="489" visible="false" alpha="1">
			   <Image skin="png.comp.blank" x="-5" y="-5" width="167" height="499" top="-5" bottom="-5" right="-2" left="-5" alpha="1" smoothing="true"/>
			    <Tree width="150" height="373" spaceLeft="15" spaceBottom="2" scrollBarSkin="png.comp.vscroll" name="tree" top="0" bottom="0">
			      <Box y="0" width="134" height="21" x="0" name="render">
			        <Clip skin="png.comp.clip_selectBox" x="15" y="-1" clipY="2" width="116" height="20" name="selectBox" clipX="1"/>
			        <Label text="label" name="label" x="36" y="0" width="87" height="24" color="0xffffff" stroke="0x333333" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			        <Clip skin="png.comp.clip_tree_arrow" x="0" y="1" width="17" height="17" clipY="2" name="arrow"/>
			        <Clip skin="png.comp.clip_tree_folder" x="17" y="1" clipY="3" name="folder"/>
			      </Box>
			    </Tree>
			    <List x="151" y="1" width="260" height="372" spaceY="2" name="list" top="0" bottom="0" vScrollBarSkin="png.comp.vscroll" >
			      <listItemView x="0" y="0" name="render" runtime="game.ui.mike.listItemViewUI"/>
			    </List>
			  </Container>

			  <Box name="mainBtn">
			    <Image skin="png.comp.mike_cat" x="0" y="0" width="80" height="80" smoothing="true"/>
			    <Label text="手动编辑" x="13" y="70" align="center" width="60" height="18" color="0xffffff" stroke="0x333333" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			  </Box>
			  <List x="118.5" y="496" width="93" height="24" name="bottomBtns" spaceX="5" spaceY="5" centerX="0" bottom="50">
			    <Box name="render">
			      <Image skin="png.comp.btnbg" width="93" height="24" smoothing="true"/>
			      <Clip skin="png.comp.btnbg1" x="0" y="0" width="93" height="24" clipY="2" name="selectBox"/>
				<Image skin="png.comp.blue" x="10" y="5" width="15" height="15" name="icon" smoothing="true"/>
			      <Label text="删除" x="10" y="3" width="90" height="18" align="center" color="0xffffff" stroke="0x333333" name="label" font="造字工房悦黑(非商用)细体" embedFonts="true"/>
			    </Box>
			  </List>
			</View>;
//		
		public function mainUI(){}
		override protected function createChildren():void {
			viewClassMap["game.ui.mike.listItemViewUI"] = listItemViewUI;
			super.createChildren();
			createView(uiXML);
		}
	}
}