package  {

	import flash.display.MovieClip;
	import flash.display.Shape;
    import flash.system.Security;
    import flash.events.*;
    import flash.net.*;
	import flash.text.TextFieldAutoSize;
	import flash.media.SoundTransform;


    import com.greensock.*;
    import com.greensock.easing.*;

    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.elements.ParagraphElement;
    import flashx.textLayout.elements.SpanElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.formats.TextLayoutFormat;
    import flash.text.engine.FontLookup;
    import flash.text.Font;
    import flash.text.engine.FontDescription;
    import flash.media.Video;

	public class detailCard extends MovieClip {

        //public var detailXML:XML;
        public var siteUrl:String;
        public var currentPage:uint = 0;
        public var mute:Boolean = false;

        private var portName:String;
        private var portDiv:String;
        private var portIntro:String;

        private var portUrl:String;
        private var movieUrl:String;
        private var xmlInfo:XML;

        private var pgWidth:uint = 1180;
        private var pgCount:uint ;

		//private var vid:Video;
		//private var ns:NetStream;
        private var tl:TimelineLite;
        private var scrollSpeed:Number = 20; // 20px per second

        private var introCard:tweenCard;
		private var bigCard:tweenCard;
        private var currentCardId:uint = 0;
        private var cardXMLList:XMLList;

        public var isDiag:Boolean = true;

		public function detailCard() {
			// constructor code
            Security.allowDomain("*");
            this.addEventListener(Event.ADDED_TO_STAGE, start);
			//vid = new Video();
			//ns = new NetStream();
		}

        private function start(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, start);

            back_btn.mouseChildren = false;
            slider2L.mouseChildren = slider2R.mouseChildren = false;

            //addEventListener(MouseEvent.CLICK, onClick);

            var mask:Shape = new Shape();
            mask.graphics.lineStyle(1, 0x000000);
            mask.graphics.beginFill(0x000000);
            mask.graphics.drawRect(0, 0, 1180, 670);
            mask.graphics.endFill();
            addChild(mask);
            mask.x = 660;
            mask.y = 240;
            introMC.mask = mask;

            btn0.addEventListener(MouseEvent.CLICK, onBtnClick);
            btn1.addEventListener(MouseEvent.CLICK, onBtnClick);
            btn2.addEventListener(MouseEvent.CLICK, onBtnClick);
            btn3.addEventListener(MouseEvent.CLICK, onBtnClick);
            btn4.addEventListener(MouseEvent.CLICK, onBtnClick);

        }

        private function onBtnClick(e:MouseEvent):void {
            var id:uint = int(e.currentTarget.name.substr(3,1));
            if(isDiag) trace ("detailCard] Clicked Btn id: "+id);
            setBtnActive(id);
        }

        public function pushPort(detailXML:XML):void {

            if(detailXML.id == undefined){
                if(isDiag) trace("[detailCard] XML Data Error!");
                return;
            }

			tl = new TimelineLite();
            introCard = new tweenCard();
            introCard.frameWidth = pgWidth;
            introCard.frameHeight = 660;
            introCard.tweenSpeed = 0.5;
            introCard.fillMode = 1;
			introCard.mute = this.mute;
			introCard.mouseChildren = false;


			bigCard = new tweenCard();
			bigCard.frameWidth = 1536;
			bigCard.frameHeight = 1080;
			bigCard.fillMode = 2;
			bigCard.pixelAspect = 1.25;
			bigCard.mute = true;
			bigCard.tweenType = 5;

            xmlInfo = detailXML;

            //portId = String(detailXML.id);
            portUrl = siteUrl + String(detailXML.portrait);
            portName = String(detailXML.surname) + String(detailXML.name);
            portDiv = String(detailXML.researchpart);
            cardXMLList = detailXML.movie;
            cardXMLList += detailXML.pic.per;

            portName_txt.text = portName;
            portDiv_txt.text = portDiv;
            portType_txt.text = String(detailXML.types);

            detailPortMC.removeChildren();

            var detailPort:port = new port();
            detailPort.frameWidth = 572;
            detailPort.frameHeight = 954;
            detailPort.imgUrl = portUrl;
            detailPort.preloadMC = new portDef();
            detailPortMC.addChild(detailPort);

            // By default, use introduction xml as intro text.
            //pushIntro(String(detailXML.introduction));
            setBtnActive(0);


            // Big Screen section
            // Initialize the video frame
            //movieUrl = siteUrl + String(detailXML.movie);
			//if(isDiag) trace("[detailCard] Streaming video : "+movieUrl);

            // Bigscreen portrait
            var bigPort:port = new port();
            bigPort.frameWidth = 512;
            bigPort.frameHeight = 900;
            bigPort.imgUrl = portUrl;
            bigPort.preloadMC = new portDef();
            bigPort.pixelAspect = 1.25;
            detailPortMC.addChild(bigPort);
            bigPort.x = 2432;

            bigName_txt.text = portName;
            switch(String(detailXML.id).substr(0,1)){
                case "G":
                    bigType_txt.text = "中国工程院院士";
                    break;
                case "Z":
                    bigType_txt.text = "中国科学院院士";
                    break;
                case "C":
                    bigType_txt.text = "长江学者";
                    break;
                case "Y":
                    bigType_txt.text = "中原学者";
                    break;
            }
            bigDiv_txt.text = portDiv;
            bigIntro_txt.autoSize = TextFieldAutoSize.LEFT
            bigIntro_txt.htmlText = String(detailXML.introduction);

            // Setup bigIntro scrolling animation
            if(bigIntro_txt.height > 1000){
                var dist:Number = bigIntro_txt.height - 1000;
                tl = new TimelineLite();
                tl.to(bigIntro_txt, 1, {alpha:1});
                tl.to(bigIntro_txt, dist / scrollSpeed, {
                    y:bigIntro_txt.y - dist,
                    ease: Linear.easeOut
                }, "+=15");
                tl.to(bigIntro_txt, 1, {
                    alpha:0,
                    onComplete: function(){
                        bigIntro_txt.y = 50;
                        tl.restart();
                    }
                }, "+=2");
            }
        }

        private function setBtnActive(id:uint){
            currentPage = id;
            MovieClip(this.parent).bgMusic.volume(mute?0:1);
			var stat:uint;
            for(var i:uint = 0; i<5; i++){
				if(i == id) stat = 2;
				else stat = 1;
                MovieClip(this.getChildByName("btn"+i)).gotoAndStop(stat);
                if(i!=4) MovieClip(this.getChildByName("bigBtn"+i)).gotoAndStop(stat);
            }

            var txt:String;
            switch(id){
                case 0:
                    txt = String(xmlInfo.introduction);
                    break;
                case 1:
                    txt = String(xmlInfo.intro1);
                    break;
                case 2:
                    txt = String(xmlInfo.intro2);
                    break;
                case 3:
                    txt = String(xmlInfo.intro3);
                    break;
                case 4:
                    txt = "";
                    break;

                default:
                    txt = String(xmlInfo.introduction);
            }

            pushIntro(txt);
            bigIntro_txt.htmlText = txt;
            tl.restart();

			if(id == 4){
                introMC.removeChildren();
				introMC.addChild(introCard);
                introCard.mute = mute;
                currentCardId = 0;
				var cardUrl:String = getPort();
				introCard.pushUrl(cardUrl);
				slider2L.y = slider2R.y = 550;
				addChild(bigCard);
				bigCard.x = 2431;
				bigCard.pushUrl(cardUrl);
            }else{
				introCard.disableVid();
				bigCard.disableVid();
				if(this.contains(bigCard)) removeChild(bigCard);
			}

            return;
        }

 /*       private function playVid(mUrl:String) {

            var nc:NetConnection = new NetConnection();
            nc.connect(null);
            ns = new NetStream(nc);
            ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
            ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            ns.play(mUrl);
            ns.soundTransform = new SoundTransform(mute?0:1);
			ns.client={};
			ns.client.onPlayStatus = onVidEnd;
            vid = new Video();
            vid.attachNetStream(ns);
            addChild(vid);
            vid.x = 1920 + 512;
            vid.y = 0;
            vid.width = 1536;
            vid.height = 1080;
        }

        private function netStatusHandler(e:NetStatusEvent):void {
            if(e.info.code == "NetStream.Play.StreamNotFound")
                trace("[detailCard] Movie load error: "+e);
        }

        private function asyncErrorHandler(e:AsyncErrorEvent):void {
            trace("[detailCard] Movie load error: "+e);
        }

		private function onVidEnd(item:Object):void {
			if(isDiag) trace ("[detailCard] Video finished.");
            disableVid();
		}*/

        private function pushIntro(txt:String):void {

            introMC.removeChildren();
            introMC.x = 660;

            var format1:TextLayoutFormat = new TextLayoutFormat();
            format1.color = 0xffffff;
            format1.fontLookup = FontLookup.DEVICE;
            format1.trackingLeft = "5%";
            format1.fontFamily = "兰亭黑-简, Times New Roman, _serif";
            format1.fontWeight = flash.text.engine.FontWeight.NORMAL;
            format1.fontSize = 25;
            format1.lineHeight = "150%";
            format1.paragraphSpaceAfter = 20;

            var flow:TextFlow = new TextFlow();
            //flow.columnCount=2;
            flow.columnGap = 50;
            flow.columnWidth = 550;
            flow.hostFormat = format1;

            var intros:String;
            //var introArray:Array = String(detailXML.introduction).split(" ").join("").split("\n");
            var introArray:Array = txt.split(" ").join("").split("\n");
            if(introArray[0].charAt(0) == "<"){
                introArray.pop();
                introArray.shift();
            }
            introArray = introArray.join("").split("<br/>");
            //trace(introArray);

            for each (var intro:String in introArray){
                var p:ParagraphElement = new ParagraphElement();
                var span:SpanElement = new SpanElement();
                span.text = intro;
                p.addChild(span);
                p.textIndent = 55;
                flow.addChild(p);
            }

            var TLFContainers:Array = new Array();
            pgCount = 0;

            while(true){
                var txtMC:MovieClip = new MovieClip();
                txtMC.x = pgWidth * pgCount;
                introMC.addChild(txtMC);
                var flowCC:ContainerController = new ContainerController(txtMC, 1150, 660);
                flow.flowComposer.addController(flowCC);
                flow.flowComposer.updateAllControllers();


                if(flowCC.textLength == 0)
                    break;

                pgCount ++;

            }
            if(isDiag) trace("[detailCard] intro page added :"+ pgCount);

            testSlide();

        }

        private function onClick(e:MouseEvent):void {

			//trace(e.target);

            if(e.target.name == "back_btn"){

                if(isDiag) trace("[detailCard] back");
                TweenLite.to(this, 0.5, {y:-1083, onComplete:disableVid});
                MovieClip(this.parent).queryInProgress = false;
                bigIntro_txt.text = "";
                return;
            }

            if(e.target is Slider2){

                var direction:Number = e.target.rotation;
                if(currentPage == 4){
					var cardUrl:String;
                    if(direction == 0) {
                        introCard.tweenType = 2;
                        cardUrl = getPort(2);
                    }
                    else{
                        introCard.tweenType = 1;
                        cardUrl = getPort(1);
                    }
                    introCard.pushUrl(cardUrl);
					bigCard.pushUrl(cardUrl);
                    return;
                }
                MovieClip(this.parent).bgMusic.volume(mute?0:1);
                removeEventListener(MouseEvent.CLICK, onClick);
                var newx = Math.cos(direction / 180 * Math.PI) * pgWidth/2;
                //if(isDiag) trace("[portWall] Sliding to : " + (cardLayer.x + newx));
                TweenLite.to(introMC, 0.5, { x:String(newx), onComplete:testSlide });

            }

			if(e.target is tweenCard){
				//trace(e.target.currentUrl);
				var tmpUrl:String = e.target.currentUrl;
				var typ:String = tmpUrl.substr(tmpUrl.length-3);
				if(typ == "mp4" || typ == "flv") bigCard.playVid(tmpUrl);
                MovieClip(this.parent).bgMusic.volume(0);
			}

        }

        private function disableVid():void {
/*            if(vid != null){
                removeChild(vid);
                vid = null;
                ns.close();
                ns = null;
            }*/
			introCard.disableVid();
			bigCard.disableVid();
            MovieClip(this.parent).bgMusic.volume(mute?0:1);
            if(this.contains(bigCard)) removeChild(bigCard);
            tl.stop();
            bigIntro_txt.y = 50;
            bigIntro_txt.alpha = 1;
        }

        private function testSlide():void {
            if(introMC.x >= 660)
                slider2L.y = -500;
            else
                slider2L.y = 550;

            if(introMC.x <= - pgWidth/2 * (pgCount - 2) )
                slider2R.y = -500;
            else
                slider2R.y = 550;

            addEventListener(MouseEvent.CLICK, onClick);
        }

		private function getPort(dir:uint = 0):String {
            switch(dir){
                case 0:
                    break;
                case 1:
                    currentCardId ++;
                    currentCardId %= this.cardXMLList.length();
                    break;
                case 2:
                    if(currentCardId > 0 )currentCardId --;
                    else currentCardId += cardXMLList.length()-1;
                    break;
            }
			var result:String = cardXMLList[currentCardId].toString();
			if(isDiag) trace("[detailCard] introCard["+currentCardId+"] "+result);
			if(result == "") return result;
			else return siteUrl+result;
		}

	}

}
