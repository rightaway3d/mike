/**Created by the Morn,do not modify.*/
package game.ui.mike {
	import morn.core.components.*;
	import game.ui.mike.listItemViewUI;
	public class mainUI extends View {
		protected static var uiXML:XML =
			<View>
			  <Container x="10" y="55.5" name="assets" centerY="0" width="130" height="489" visible="false" alpha="1">
			    <Image skin="png.comp.blank" x="0" y="-5" width="396" height="398" top="-5" bottom="-5" right="-2" left="-5" alpha="1"/>
			    <Tree width="130" height="373" spaceLeft="15" spaceBottom="2" scrollBarSkin="png.comp.vscroll" name="tree" top="0" bottom="0">
			      <Box y="0" width="114" height="21" x="0" name="render">
			        <Clip skin="png.comp.clip_selectBox" x="15" y="-1" clipY="2" width="96" height="20" name="selectBox" clipX="1"/>
			        <Label text="label" name="label" x="36" y="0" width="67" height="24" color="0xffffff" stroke="0x333333"/>
			        <Clip skin="png.comp.clip_tree_arrow" x="0" y="1" width="17" height="17" clipY="2" name="arrow"/>
			        <Clip skin="png.comp.clip_tree_folder" x="17" y="1" clipY="3" name="folder"/>
			      </Box>
			    </Tree>
			    <List x="131" y="1" width="260" height="372" spaceY="2" name="list" top="0" bottom="0" vScrollBarSkin="png.comp.vscroll">
			      <listItemView x="0" y="0" name="render" runtime="game.ui.mike.listItemViewUI"/>
			    </List>
			  </Container>
			  <Image skin="png.comp.image" x="10" y="10" name="mainBtn" width="60" height="60"/>
			</View>;
		public function mainUI(){}
		override protected function createChildren():void {
			viewClassMap["game.ui.mike.listItemViewUI"] = listItemViewUI;
			super.createChildren();
			createView(uiXML);
		}
	}
}