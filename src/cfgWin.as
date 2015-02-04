package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
    import flash.text.TextFormat; 
    import flash.system.fscommand;
	
    import com.greensock.*;
    import com.greensock.easing.*;
	
	public class cfgWin extends MovieClip {
		
		public var pwd:String = "1234";
        public var mute:Boolean = false;
        public var siteUrl:String = "http://192.168.1.100";
        public var randPortInterval:uint = 30;
        public var signAutoShow:uint = 1;
        public var isDiag = true;

		private var tryPwd:String ="____";
        private var currentDigit:uint = 0;
		
		
		public function cfgWin() {
			// constructor code
            this.addEventListener(Event.ADDED_TO_STAGE, start);
		}
		
		private function start(e:Event):void {
			//removeEventListener(Event.ADDED_TO_STAGE, start);
            gotoAndStop(1);
			
			for(var i:uint = 0; i <= 9; i++){
				var btnName:String = "btn"+i;
				var btn:MovieClip = this.getChildByName(btnName) as MovieClip;
				btn.num_txt.text = i;
                btn.mouseChildren = false;
			}

            this.x = 960;
            this.y = 540;
            TweenLite.from(this, 0.5, {y:-500});
			
            var format:TextFormat = new TextFormat(); 
            format.letterSpacing = 10; 
            pwd_txt.defaultTextFormat = format; 

			this.addEventListener(MouseEvent.CLICK, onCfgClick);
		}
		
		private function onCfgClick(e:MouseEvent):void {
			var target:String = e.target.name;
            if(isDiag) trace("[cfgWin] Clicked : "+target);
			if(target.substr(0,3) ==  "btn"){
				var clickName:String = target.substr(3);
				switch(clickName){
					case "0":
					case "1":
					case "2":
					case "3":
					case "4":
					case "5":
					case "6":
					case "7":
					case "8":
					case "9":
                        tryPwd = replaceDigit(tryPwd, clickName, currentDigit);
						pwd_txt.text = tryPwd;
                        currentDigit++;
                        if(currentDigit > pwd.length-1){
                            currentDigit %= pwd.length;
                            if(tryPwd == pwd){
                                tryPwd = "____";
                                gotoAndStop(2);
                                btns.mouseChildren = false;
                                if(mute) btns.txt.text = "音量：关";
                                else btns.txt.text = "音量：开";
                            }
                            else{
                                tryPwd = "____";
								pwd_txt.text = tryPwd;
                                var tl:TimelineMax = new TimelineMax();
                                tl.to(this, 0.1, {x:"-20", ease:Linear.easeOut});
                                tl.to(this, 0.1, {x:"40", ease:Linear.easeInOut});
                                tl.to(this, 0.1, {x:"-20", ease:Linear.easeIn});
                            }
                        }
                        break;
                    case "d":
                        if(currentDigit){
                            tryPwd =  replaceDigit(tryPwd, "_", currentDigit-1);
                            currentDigit--;
                        }
                        pwd_txt.text = tryPwd;
                        break;
                    case "x":
                        TweenLite.to(this, 0.5, {y:-500, 
                                onComplete:onCfgClose
                        });
                        portWall(this.parent).dim(false);
                        break;
                    case "c":
                        // Todo: invoke autoit function to close app
                        fscommand("quit");
                        break;
                    case "s":
                        mute = !mute;
                        if(mute) btns.txt.text = "音量：关";
                        else btns.txt.text = "音量：开";
                        break;
				}
			}
		}

        private function replaceDigit(sourceStr:String, digit:String, pos:uint):String {
            if(pos>sourceStr.length-1) return sourceStr;
            var preStr:String;
            var postStr:String;
            if(!pos) preStr = "";
            else preStr = sourceStr.substr(0,pos);
            if(pos == sourceStr.length-1) postStr = "";
            else postStr = sourceStr.substr(pos+1);
            return preStr+digit+postStr;
        }
		
		private function onCfgClose():void {
			this.removeEventListener(MouseEvent.CLICK, onCfgClick);
            this.parent.removeChild(this);
		}
	}
	
}
