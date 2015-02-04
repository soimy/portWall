package  {

	import flash.display.*;
    import flash.system.Security;
    import flash.events.*;
    import flash.net.*;
	import flash.text.TextFieldAutoSize;

    import com.greensock.*;
    import com.greensock.easing.*;

	public class randCard extends MovieClip{

        public var siteUrl:String;
        public var cardXML:XML = new XML();
        public var portId:String;

        private var portUrl:String;
        private var portName:String;
        private var portDiv:String;

        public var defImgUrl:String = "img/randport_undefined_thumb.jpg";

        public var isDiag:Boolean = true ;

        public var pixelAspect:Number = 1.0;
        public var gridid:uint = 0;
        public var scrollSpeed:Number = 10; // 10px/second

		public function randCard() {
			// constructor code
            Security.allowDomain("*");
            this.addEventListener(Event.ADDED_TO_STAGE, start);
		}

        private function start(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, start);
            if(cardXML.id != undefined){
                init();
            }else{
                trace("[portCard] XML Data error!");
            }

        }

		public function init():void {

            // Resolve XML data
            portId = String(cardXML.id);
            if(String(cardXML.portrait).length != 0)
                portUrl = siteUrl + String(cardXML.portrait);
            else
                portUrl = defImgUrl;

            portName = String(cardXML.surname) + String(cardXML.name);
            portDiv = String(cardXML.researchpart);

            if(isDiag) trace("[portCard] Adding ID:"+portId+" Name:"+portName);

            var portPic:port = new port();

            portPic.frameWidth = 250;
            portPic.frameHeight = 360;
            portPic.isDiag = isDiag;
            portPic.preloadMC = new portDef();
            portPic.portShiftY = 50;
            portPic.imgUrl = portUrl;
            portPic.pixelAspect = pixelAspect;
            addChild(portPic);

            portName_txt.text = portName;
            portDiv_txt.text = portDiv;
            //randtxt.portYr_txt.text = String(cardXML.date);
            randtxt.portIntro_txt.autoSize = TextFieldAutoSize.LEFT;
            randtxt.portIntro_txt.htmlText = String(cardXML.introduction);
            switch(String(cardXML.id).substr(0,1)){
                case "G":
                    portYr_txt.text = "中国工程院院士";
                    break;
                case "Z":
                    portYr_txt.text = "中国科学院院士";
                    break;
                case "C":
                    portYr_txt.text = "长江学者";
                    break;
                case "Y":
                    portYr_txt.text = "中原学者";
                    break;
            }

            // Apply mask for text info
            var tmask:Shape = new Shape();
            tmask.graphics.lineStyle(1, 0x000000);
            tmask.graphics.beginFill(0x000000);
            tmask.graphics.drawRect(0, 0, 310, 205);
            tmask.graphics.endFill();
            addChild(tmask);
            tmask.x = 265;
            tmask.y = 145;
            randtxt.mask = tmask;

            // TODO: Add mask blur filter

            // TODO: Add textfield scrolling animation
            if(randtxt.height > tmask.height){
                var dist:Number = randtxt.height - tmask.height;
                TweenLite.to(randtxt, dist/scrollSpeed, {
                    y:randtxt.y-dist, 
                    delay:5, 
                    ease:Linear.easeOut
                });

            }

        }

  	}

}
