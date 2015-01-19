package  {

	import flash.display.MovieClip;
	import flash.display.Shape;
    import flash.system.Security;
    import flash.events.*;
    import flash.net.*;

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

        private var portName:String;
        private var portDiv:String;
        private var portIntro:String;

        private var portUrl:String;
        private var movieUrl:String;
        private var xmlInfo:XML;

        private var pgWidth:uint = 1100;
        private var pgCount:uint ;

		private var vid:Video;
		private var ns:NetStream;

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
            mask.graphics.drawRect(0, 0, 1100, 720);
            mask.graphics.endFill();
            addChild(mask);
            mask.x = 660;
            mask.y = 300;
            introMC.mask = mask;

            btn0.addEventListener(MouseEvent.CLICK, onBtnClick);
            btn1.addEventListener(MouseEvent.CLICK, onBtnClick);
            btn2.addEventListener(MouseEvent.CLICK, onBtnClick);

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

            xmlInfo = detailXML;

            //portId = String(detailXML.id);
            portUrl = siteUrl + String(detailXML.portrait);
            portName = String(detailXML.surname) + String(detailXML.name);
            portDiv = String(detailXML.researchpart);

            portName_txt.text = portName;
            portDiv_txt.text = portDiv;

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

            // Initialize the video frame
            movieUrl = siteUrl + String(detailXML.movie);
			if(isDiag) trace("[detailCard] Streaming video : "+movieUrl);

            var nc:NetConnection = new NetConnection();
            nc.connect(null);
            ns = new NetStream(nc);
            ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
            ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            ns.play(movieUrl);
			ns.client={};
			ns.client.onPlayStatus = onVidEnd;
            vid = new Video();
            vid.attachNetStream(ns);
            addChild(vid);
            vid.x = 1920;
            vid.y = 0;
            vid.width = 1920;
            vid.height = 1080;

        }

        private function setBtnActive(id:uint){
            currentPage = id;
			var stat:uint;
            for(var i:uint = 0; i<3; i++){
				if(i == id) stat = 2;
				else stat = 1;
                MovieClip(this.getChildByName("btn"+i)).gotoAndStop(stat);
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

                default:
                    txt = String(xmlInfo.introduction);
            }
            pushIntro(txt);
            return;
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
		}

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
            flow.columnWidth = 500;
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
                var flowCC:ContainerController = new ContainerController(txtMC, 1060, 710);
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

            if(e.target.name == "back_btn"){


                if(isDiag) trace("[detailCard] back");
                TweenLite.to(this, 0.5, {y:-1083, onComplete:disableVid});
                MovieClip(this.parent).queryInProgress = false;
                return;
            }

            if(e.target is Slider2){
                removeEventListener(MouseEvent.CLICK, onClick);
                var direction:Number = e.target.rotation;
                var newx = Math.cos(direction / 180 * Math.PI) * pgWidth/2;
                //if(isDiag) trace("[portWall] Sliding to : " + (cardLayer.x + newx));
                TweenLite.to(introMC, 0.5, { x:String(newx), onComplete:testSlide });

            }

        }

        private function disableVid():void {
            if(vid != null){
                removeChild(vid);
                vid = null;
                ns.close();
                ns = null;
            }
        }

        private function testSlide():void {
            if(introMC.x >= 660)
                slider2L.y = -500;
            else
                slider2L.y = 625;

            if(introMC.x <= - pgWidth/2 * (pgCount - 2) )
                slider2R.y = -500;
            else
                slider2R.y = 625;

            addEventListener(MouseEvent.CLICK, onClick);
        }



	}

}
