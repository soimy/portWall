package  {

	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Shape;
    import flash.system.Security;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.Timer;
    import flash.geom.Point;

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
        public var utDef:Array = ["G","Z","C","Y"]; // id start letter defination

        private var portList:Array;
        private var xmlData:XML;
        private var userPool:Array;
        private var randTimer:Timer;
        private var poolPointer:Array;
        private var currentPointer:uint;
        private var currentPool:uint = 0;

        private var portH:uint;
        private var portW:uint;
        private var tweenMask:Shape;
        private var lastRandid:uint;
        private var lastGridid:uint;

        //private var tl:TimelineLite;

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
            xmlLoader.load(new URLRequest(siteUrl+queryUrl+"&nocache="+ new Date().getTime()));
            xmlLoader.addEventListener(Event.COMPLETE, onXmlLoad);
        }

        private function onXmlLoad(e:Event):void {
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            if(isDiag) trace("[bigScreen] XML Loaded.")

            xmlData = new XML(e.target.data);
            userPool = new Array();
            var tmpPool = new Array(4);
            for(var i:uint = 0; i<4; i++)
                tmpPool[i] = new Array();

            for each (var users:XML in xmlData.user){
                var tmpUrl:String = String(users.portrait);
                if(tmpUrl != ""){
                    var finalUrl:String = siteUrl + tmpUrl;
                    if(isDiag)trace("[bigScreen] Added : "+finalUrl);
                    switch(String(users.types)){
                        case "在豫工作院士":
                            tmpPool[0].push(users);
                            break;
                        case "豫籍院士":
                            tmpPool[1].push(users);
                            break;
                        case "长江学者":
                            tmpPool[2].push(users);
                            break;
                        case "中原学者":
                            tmpPool[3].push(users);
                            break;
                    }
                }
            }

            poolPointer = [0,0,0,0];

            for(var tmpId:uint = 0; tmpId < tmpPool.length; tmpId++){
                if(isDiag) trace("[bigScreen] Pool#"+tmpId+" length :" + tmpPool[tmpId].length);
                poolPointer[tmpId+1] = tmpPool[tmpId].length + poolPointer[tmpId];
				//trace(tmpPool[tmpId]);
                for(i=0; i<tmpPool[tmpId].length; i++){
                    userPool.push(tmpPool[tmpId][i]);
                }
            }
            if(isDiag) trace(poolPointer);

            init();
        }

        private function init():void {
            portW= frameWidth/row;
            portH= frameHeight/col;

            //tl = new TimelineLite();

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
                    randp.isDiag = false;
                    randp.pixelAspect = pixelAspect;
                    var cardHolder:MovieClip = new MovieClip();
                    cardHolder.addChild(randp);
                    randp.x = - portW/2;
                    randp.y = - portH/2;
                    portList.push(cardHolder);
                    addChild(cardHolder);
                    cardHolder.x = portW*i + portW/2;
                    cardHolder.y = portH*j + portH/2;

                }
            }

            if(interval < tweenSpeed*col*row + 1 )
                interval = tweenSpeed*col*row + 1;
            if(isDiag) trace("[bigScreen] Refresh interval : "+interval);

            randTimer = new Timer(interval*1000);
            randTimer.addEventListener(TimerEvent.TIMER, onSlide);
            randTimer.start();
        }

        private function onSlide(e:TimerEvent):void {
            flipCard(currentPool);
        }

        public function flipCard(ut:uint, gridid:uint = 0):void
        {
            var tmpXML:XML = getPort(ut);
            var tweenCard:randCard = new randCard();
            tweenCard.siteUrl = siteUrl;
            tweenCard.cardXML = tmpXML;
            tweenCard.pixelAspect = pixelAspect;
            tweenCard.gridid = gridid;
            tweenCard.isDiag = false;

            var currentRow:uint = Math.floor(gridid / col);
            var currentCol:uint = gridid % col;
            //trace("Fliping R:"+currentRow+" C:"+currentCol);

            // Apply mask for rand
            //addChild(tweenMask);
            //tweenMask.x = portW * currentRow + portW/2;
            //tweenMask.y = portH * currentCol + portH/2;

            var cardHolder:MovieClip = new MovieClip();
            cardHolder.addChild(tweenCard);
            tweenCard.x = - portW/2;
            tweenCard.y = - portH/2;
            addChild(cardHolder);
            cardHolder.x = portW * currentRow + portW/2;
            cardHolder.y = portH * currentCol + portH/2;
            //tweenCard.mask = tweenMask;

            this.transform.perspectiveProjection.projectionCenter = new Point(cardHolder.x, cardHolder.y);

            var tl:TimelineLite = new TimelineLite();
            tl.to(portList[gridid], tweenSpeed * 0.35, {
                rotationX: 90,
                ease:Quad.easeIn
            });

            tl.from(cardHolder, tweenSpeed * .65, {
                rotationX: -90,
                ease:Back.easeOut,
                onComplete:onTween,
                onCompleteParams:[cardHolder, gridid]
            });
        }

        private function onTween(holder:MovieClip, gridid:uint):void {
            removeChild(portList[gridid]);
			//trace("Removing : "+gridid);
            portList[gridid] = holder;
            if(gridid < row * col - 1)
                flipCard(currentPool, gridid + 1);
        }

        private function getPort(ut:uint = 0):XML {
            if(ut != currentPool){
                switchPool(ut);
                if(ut != 0)
                    currentPointer = poolPointer[ut-1];
                else
                    currentPointer = 0;
            }

            var tmpXML:XML = userPool[currentPointer++];

            switch(ut){
                case 0:
                    currentPointer %= userPool.length;
                    break;
                case 1:
                case 2:
                    if(currentPointer > poolPointer[2] - 1)
                        currentPointer = poolPointer[0];
                    break;
                case 3:
                case 4:
                    if(currentPointer > userPool.length - 1)
                        currentPointer = poolPointer[2];
                    break;
            }

            return tmpXML;
        }

        private function switchPool(ut:uint):void {
            currentPool = ut;
        }


	}

}
