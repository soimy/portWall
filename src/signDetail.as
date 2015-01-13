package  {

	import flash.display.MovieClip;
	import flash.events.*;
    import com.adobe.images.JPGEncoder;

    import com.greensock.*;
    import com.greensock.easing.*;
    import flash.utils.ByteArray;
    import flash.net.*;
    import flash.display.DisplayObject;
    import flash.display.Loader;

	public class signDetail extends MovieClip {

        public var siteUrl:String = "http://shader.jios.org:8080";
        public var uploadUrl:String = "/xml/default.aspx?uploadsign=";
        public var uploadAutoShow:uint = 1;

		public var editable:Boolean = false;
		public var signUrl:String;
        public var signCanvas:canvas;

        private var loadMC:MovieClip;

        public var isDiag:Boolean = true;


		public function signDetail() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, start);

            loadMC = new MovieClip();
            loadMC.graphics.lineStyle(1, 0x000000);
            loadMC.graphics.beginFill(0x000000);
            loadMC.graphics.drawRect(0, 0, width, height);
            loadMC.graphics.endFill();
            var loadIcon:loading = new loading();
            loadMC.addChild(loadIcon);
            loadIcon.x = width/2;
            loadIcon.y = height/2;
            loadMC.alpha = 0.5

		}

		private function start(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, start);
			this.addEventListener(MouseEvent.CLICK, onClick);
		    toggleMode();
            btn_signClose.mouseChildren = false;
            btn_signSave.mouseChildren = false;
            //if(signUrl.length !=0)
                //pushPort(signUrl);

            signCanvas = new canvas();
            signCanvas.boardWidth = width;
            signCanvas.boardHeight = height;
            if(isDiag) trace("[signDetail] Canvas resolution: " +width+"x"+height);
		}

        public function toggleMode():void {
            btn_signSave.visible = editable;
            btn_brush.visible = editable;
            btn_pen.visible = editable;
            btn_rubber.visible = editable;
            btn_undo.visible = editable;
            btn_new.visible = editable;
            btnGlow.visible = editable;
        }

        public function pushSign(portUrl:String):void {
            editable = false;
            toggleMode();
            //var signCard:port = new port();
            //signCard.frameWidth = width;
            //signCard.frameHeight = height;
            //signCard.imgUrl = portUrl;

            signContainer.removeChildren();
            signContainer.addChild(loadMC);

            if(portUrl.length != 0){
                var imgLoader:Loader = new Loader();
                imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImgLoaded);
                //imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
                imgLoader.load(new URLRequest(portUrl));
            }
        }

        private function onImgLoaded(e:Event):void {
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            // Clear all child previously added
            signContainer.removeChildren();

            var portImg:DisplayObject = e.target.content;

            signContainer.addChild(portImg);
            var scale:Number = Math.max(width/portImg.width, height/portImg.height);
            portImg.width *= scale;
            portImg.height *= scale;
            portImg.x = -portImg.width/2 + width/2;
            portImg.y = -portImg.height/2 + height/2;

            if(isDiag) trace("[signDetail] Sign Loaded ");
        }

        public function addSign():void {
            editable = true;
            toggleMode();

            //signCanvas.erase();
            signContainer.removeChildren();
            signContainer.addChild(signCanvas);

        }

        private function onClick(e:MouseEvent):void {

            switch(e.target.name){
                case "btn_signClose":
                    TweenLite.to(this, 0.5, {y:-1083});
                    MovieClip(this.parent).queryInProgress = false;
                    break;
                case "btn_signSave":
                    this.addChild(loadMC);
                    uploadSign();
                    break;
                case "btn_brush":
                    signCanvas.setColor(0x0f0f0f, 0x808080);
                    signCanvas.minThickness = 12;
                    signCanvas.thicknessFactor = -0.5;
                    TweenLite.to(btnGlow, 0.2, {x:btn_brush.x, y:btn_brush.y});
                    break;
                case "btn_pen":
                    signCanvas.setColor(0x0f0f0f, 0x808080);
                    signCanvas.minThickness = 0.5;
                    signCanvas.thicknessFactor = 0.2;
                    TweenLite.to(btnGlow, 0.2, {x:btn_pen.x, y:btn_pen.y});
                    break;
                case "btn_rubber":
                    signCanvas.setColor(0xffffff, 0xffffff);
                    signCanvas.minThickness = 10;
                    signCanvas.thicknessFactor = 0.5;
                    TweenLite.to(btnGlow, 0.2, {x:btn_rubber.x, y:btn_rubber.y});
                    break;
                case "btn_undo":
                    signCanvas.undo();
                    break;
                case "btn_new":
                    signCanvas.erase();
                    break;
            }


        }

        public function uploadSign():void {
            // Encode the canvas bitmapData to jpg byteArray
            var jpg:JPGEncoder = new JPGEncoder();
            var jpgByteArray:ByteArray = jpg.encode(signCanvas.boardBitmapData);
            var urlRequest:URLRequest = new URLRequest();
            //parameters.uploadsign = 1;

            urlRequest.url = siteUrl + uploadUrl + uploadAutoShow;
            if(isDiag) trace("[signDetail] Uploading to : " + urlRequest.url);
            urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
            urlRequest.method = URLRequestMethod.POST;
            var dat:ByteArray = UploadPostHelper.getPostData("sign.jpg", jpgByteArray);
            urlRequest.data = dat;
            urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );


            var urlLoader:URLLoader = new URLLoader();
            urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            urlLoader.addEventListener(Event.COMPLETE, onComplete);
            //urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            //urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            urlLoader.load(urlRequest);

        }

        private function onComplete(e:Event):void {
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            if(isDiag) trace("[signDetail] Sign data uploaded.");
            removeChild(loadMC);
            TweenLite.to(this, 0.5, {y:-1083});
            MovieClip(this.parent).queryInProgress = false;
            MovieClip(this.parent).initCard("sign");
        }

        public static function encode(ba:ByteArray):String {
            var origPos:uint = ba.position;
            var result:Array = new Array();

            for (ba.position = 0; ba.position < ba.length - 1; )
                result.push(ba.readShort());

            if (ba.position != ba.length)
                result.push(ba.readByte() << 8);

            ba.position = origPos;
            return String.fromCharCode.apply(null, result);
        }
	}

}
