package  {

	import flash.display.MovieClip;
    import flash.events.*;
	import flash.text.TextFieldAutoSize;

	public class groupLabel extends MovieClip {

        public var keyword:String;

		public function groupLabel() {
			// constructor code
            this.addEventListener(Event.ADDED_TO_STAGE, start);
		}

        private function start(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, start);
            mouseChildren = false;
            label_txt.autoSize = TextFieldAutoSize.LEFT;
            if(label_txt.width > 113)
                labelBG.width = label_txt.width + 10;
            label_txt.x = labelBG.width/2 - label_txt.width/2;

        }
	}

}
