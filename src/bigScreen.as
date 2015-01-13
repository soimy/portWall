package  {

	import flash.display.MovieClip;
    import flash.system.Security;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.Timer;

	public class bigScreen extends MovieClip {

		public var row:uint = 5;
        public var col:uint = 1;
        public var frameWidth:uint = 1920;
        public var frameHeight:uint = 1080;

        public var interval:uint = 5; // Interval in second for portrait change
        public var siteUrl:String = "http://shader.jios.org:8080";
        public var queryUrl:String = "/xml/Default.aspx?searchtype=wall";
        public var tweenSpeed:Number = 0.5;

        private var portList:Array;
        private var xmlData:XML;
        private var userPool:Array;
        private var randTimer:Timer;

        public var isDiag:Boolean = true;

		public function bigScreen() {
			// constructor code
            Security.allowDomain("*");
            this.addEventListener(Event.ADDED_TO_STAGE, start);
		}

        private function start(event:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, start);
            if(isDiag){
                trace("Stage inited.");
                trace("[randPort] size: "+ frameWidth + "x"+ frameHeight);
            }

            var xmlLoader:URLLoader = new URLLoader();
            xmlLoader.load(new URLRequest(siteUrl+queryUrl));
            xmlLoader.addEventListener(Event.COMPLETE, onXmlLoad);
        }

        private function onXmlLoad(e:Event):void {
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            if(isDiag) trace("[bigScreen] XML Loaded.")

            xmlData = new XML(e.target.data);
            userPool = new Array();
            for each (var user:XML in xmlData.user){
                var tmpUrl:String = String(user.portrait);
                if(tmpUrl != ""){
                    var finalUrl:String = siteUrl + tmpUrl;
                    if(isDiag)trace("[bigScreen] Added : "+finalUrl);
                    userPool.push(finalUrl);
                }
            }
            init();
        }

        private function init():void {
            var portW:uint = frameWidth/row;
            var portH:uint = frameHeight/col;

            portList = new Array();

            for(var i=0; i<row; i++){
                for(var j=0; j<col; j++){
                    var randp:randPort = new randPort();
                    randp.gridid = i+j;
                    randp.frameWidth = portW;
                    randp.frameHeight = portH;
                    randp.imgUrl = getPort();
                    randp.isDiag = isDiag;
                    randp.tweenSpeed = tweenSpeed;

                    portList.push(randp);
                    addChild(portList[portList.length-1]);
                    portList[portList.length-1].x = portW*i;
                    portList[portList.length-1].y = portH*j;

                }
            }

            //for(var m=0; m<portList.length; m++)
                //addChild(portList[m]);

            randTimer = new Timer(interval*1000);
            randTimer.addEventListener(TimerEvent.TIMER, onSlide);
            randTimer.start();
        }

        private function onSlide(e:TimerEvent):void {
            var randid:uint = Math.random() * portList.length;
            if(isDiag) trace("[bigScreen] Rand on Port #"+randid);
            userPool.push(portList[randid].pushPort(getPort()));
        }

        private function getPort():String {
            if(userPool.length == 0)
                return "img/randport_undefined.jpg";

            var rand:uint = Math.random() * userPool.length;
            var randUrl:String = userPool[rand];
            if(isDiag) trace("[randPort] randomize port ["+rand+"/"+userPool.length+"] "+randUrl);
            userPool.splice(rand,1);
            return randUrl;
        }


	}

}
