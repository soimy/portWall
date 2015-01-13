package  {

    import flash.display.*;
    import flash.system.Security;
    import flash.events.*;
    import flash.net.*;

    import com.greensock.*;
    import com.greensock.easing.*;

	public class portCard extends MovieClip {

        public var siteUrl:String;
        public var cardXML:XML = new XML();
        public var portId:String;

        private var portUrl:String;
        private var portName:String;
        private var portDiv:String;

        public var defImgUrl:String = "img/randport_undefined_thumb.jpg";

        public var isDiag:Boolean = true ;

		public function portCard() {
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
            var pMask:portMask = new portMask();
            addChild(pMask);
            pMask.x = pMask.y = 0;

            portPic.frameWidth = 292;
            portPic.frameHeight = 316;
            portPic.isDiag = isDiag;
            portPic.preloadMC = new portDef();
            portPic.portShiftY = 50;
            portPic.imgUrl = portUrl;
            portRoot.addChild(portPic);
            portRoot.mask = pMask;

            portName_txt.text = portName;
            portDiv_txt.text = portDiv;

            //bg.name = portId;

            //name = portId; // For compactable of MC
            //trace(name);
        }
	}

}
