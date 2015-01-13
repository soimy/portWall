package  {

	import flash.display.MovieClip;
	import flash.events.*;


	public class nav_btn extends MovieClip {

		public var queryType:String;
        public var sortType:String;
        public var keyword:String;
        public var isActive:Boolean;
		public var btnWidth:Number;

        public var currentBtn:uint;

		public function nav_btn() {
			// constructor code
            btnBG.gotoAndStop(1);
            expandIcon.visible = false;
            mouseChildren = false;
			btnWidth = width;
			//this.addEventListener(Event.ADDED_TO_STAGE, setBtn);
		}

        public function setBtn():void {
			
			//this.removeEventListener(Event.ADDED_TO_STAGE, setBtn);
			
			var type:uint = int(this.name.substr(3,1));
			btnBG.width = btnWidth;
            btnIcon.gotoAndStop(type);
			btnIcon.x = btnWidth - 3;
			btnIcon.y = 10;
			
            currentBtn = type;
            mouseChildren = false;

            switch(currentBtn){
                case 1:
                    queryType = "all";
                    sortType = "bh";
                    keyword = "";
                    btn_txt.text = "按笔画";
                    div_txt.text = "";
                    break;
                case 2:
                    queryType = "all";
                    sortType = "py";
                    keyword = "";
                    btn_txt.text = "按拼音";
                    div_txt.text = "";
                    break;
                case 3:
                    queryType = "all";
                    sortType = "nf";
                    keyword = "";
                    btn_txt.text = "按年份";
                    div_txt.text = "";
                    break;
                case 4:
                    //mouseChildren = true;
                    queryType = "all";
                    sortType = "xb";
                    keyword = "";
                    btn_txt.text = "按学部";
                    div_txt.text = "";
                    break;
                case 5:
                    queryType = "back";
                    sortType = "";
                    keyword = "";
                    btn_txt.text = "返回首页";
                    div_txt.text = "";
					btnBG.gotoAndStop(3);
                    break;
            }
        }

        public function setActive(status:Boolean):void {
            btnBG.gotoAndStop(int(status)+1);
            isActive = status;
            if(queryType == "sign")
                expandIcon.visible = false;
            else
                expandIcon.visible = status;
        }
	}

}
