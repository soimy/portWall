package  {

	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Shape;
    import flash.system.Security;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.Timer;

    import com.greensock.*;
    import com.greensock.easing.*;

	public class bigScreen extends MovieClip {

		public var row:uint = 5;
        public var col:uint = 3;
        public var frameWidth:uint = 2560;
        public var frameHeight:uint = 1080;
        public var pixelAspect:Number = 1.25;

        public var interval:uint = 5; // Interval in second for portrait change
        public var siteUrl:String = "http://192.168.96.200";
        public var queryUrl:String = "/xml/Default.aspx?searchtype=wall";
        public var tweenSpeed:Number = 1;

        private var portList:Array;
        private var xmlData:XML;
        private var userPool:Array;
        private var randTimer:Timer;

        private var portH:uint;
        private var portW:uint;
        private var tweenMask:Shape;
        private var lastRandid:uint;

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
                    userPool.push(user);
                }
            }
            init();
        }

        private function init():void {
            portW= frameWidth/row;
            portH= frameHeight/col;

            // Apply mask for rand
            tweenMask = new Shape();
            tweenMask.graphics.lineStyle(1, 0x000000);
            tweenMask.graphics.beginFill(0x000000);
            tweenMask.graphics.drawRect(0, 0, portW, portH);
            tweenMask.graphics.endFill();

            portList = new Array();

            for(var i=0; i<row; i++){
                for(var j=0; j<col; j++){
                    var randp:randCard = new randCard();
                    randp.siteUrl = siteUrl;
                    randp.gridid = i * col + j;
                    //randp.frameWidth = portW;
                    //randp.frameHeight = portH;
                    randp.cardXML = getPort();
                    randp.isDiag = isDiag;
                    randp.pixelAspect = pixelAspect;

                    portList.push(randp);
                    addChild(randp);
                    randp.x = portW*i;
                    randp.y = portH*j;

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
            while(randid == lastRandid){
                randid = Math.random() * portList.length;
            } // Never repeat last random card

            if(isDiag) trace("[bigScreen] Rand on Port #"+randid);
            //userPool.push(portList[randid].pushPort(getPort()));
            var tmpXML:XML = getPort();
            var tweenCard:randCard = new randCard();
            tweenCard.siteUrl = siteUrl;
            tweenCard.cardXML = tmpXML;
            tweenCard.pixelAspect = pixelAspect;
            tweenCard.gridid = randid;

            var currentRow:uint = Math.floor(randid / col);
            var currentCol:uint = randid % col;

            // Apply mask for rand
            addChild(tweenMask);
            tweenMask.x = portW * currentRow;
            tweenMask.y = portH * currentCol;

            addChild(tweenCard);
            tweenCard.x = portW * currentRow;
            tweenCard.y = portH * currentCol;
            tweenCard.mask = tweenMask;

            var direction:int = Math.random()*4;
            var offsetX, offsetY:int;
            if(isDiag) trace("[randPort] direction: "+direction);
            if(direction == 0){
                offsetX = 0;
                offsetY = - portH;
            }else if (direction == 1){
                offsetX = - portW;
                offsetY = 0;
            }else if (direction == 2){
                offsetX = 0;
                offsetY = portH;
            }else if (direction == 3){
                offsetX = portW;
                offsetY = 0;
            }
            TweenLite.from(tweenCard, tweenSpeed, {
                x: tweenCard.x + offsetX,
                y: tweenCard.y + offsetY,
                onComplete:onTween,
                onCompleteParams:[tweenCard]
            });

            userPool.push(portList[randid].cardXML);
            lastRandid = randid;
        }

        private function onTween(tweenCard:randCard):void {
            var gridid:uint = tweenCard.gridid;
            removeChild(portList[gridid]);
			trace("Removing : "+gridid);
            portList[gridid] = tweenCard;
			//removeChild(tweenMask);
        }

        private function getPort():XML {
            if(userPool.length == 0)
                return new XML("img/randport_undefined.jpg");

            var rand:uint = Math.random() * userPool.length;
            var randXML:XML = userPool[rand];
            if(isDiag) trace("[randPort] randomize port ["+rand+"/"+userPool.length+"] "+ randXML.portrait);
            userPool.splice(rand,1);
            return randXML;
        }


	}

}
