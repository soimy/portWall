package  {

	import flash.display.*;
    import flash.system.Security;
    import flash.events.*;
    import flash.net.*;
    import flash.geom.Matrix;

    import com.greensock.*;
    import com.greensock.easing.*;

	public class port extends MovieClip {

		public var gridid:uint;
        public var frameWidth:uint = 320;
        public var frameHeight:uint = 540;
        public var pixelAspect:Number = 1.0;
        //public var fillMode:uint = 0; // 0 = fit, 1 = scale

        public var imgUrl:String = "/img/randport_undefined.jpg";
        public var preloadMC:MovieClip;
        public var frameMask:MovieClip;
        public var portShiftX:int = 0;
        public var portShiftY:int = 0;

        public var portImg:Bitmap;

        public var isDiag:Boolean;

		public function port() {
			// constructor code
            Security.allowDomain("*");
            this.addEventListener(Event.ADDED_TO_STAGE, start);
		}

        private function start(event:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, start);

            if(frameMask == null){
                // Apply mask with frame width/height
                frameMask = new MovieClip();
                frameMask.graphics.lineStyle(1, 0x000000);
                frameMask.graphics.beginFill(0x000000);
                frameMask.graphics.drawRect(0, 0, frameWidth, frameHeight);
                frameMask.graphics.endFill();
            }
            //addChild(frameMask);
            frameMask.x = 0;
            frameMask.y = 0;

            if(preloadMC != null){
                this.addChild(preloadMC);
                var scale:Number;
                //if(fillMode == 0)
                    //scale = Math.max(frameWidth/preloadMC.width*pixelAspect, frameHeight/preloadMC.height);
                //else
                scale = Math.max(frameWidth/preloadMC.width*pixelAspect, frameHeight/preloadMC.height);
                preloadMC.width *= scale/pixelAspect;
                preloadMC.height *= scale;
                preloadMC.x = -preloadMC.width/2 + frameWidth/2 + portShiftX;
                preloadMC.y = -preloadMC.height/2 + frameHeight/2 + portShiftY;
                addChild(frameMask);
                preloadMC.mask = frameMask;
            }

            if(imgUrl.length != 0){
                var imgLoader:Loader = new Loader();
                imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImgLoaded, false, 0, true);
                imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
                imgLoader.load(new URLRequest(imgUrl));
            }

        }

        private function onImgLoaded(e:Event):void {
            // Clear all child previously added
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            this.removeChildren();

            var tmpBMD:BitmapData = e.target.content.bitmapData;
            var scale:Number = Math.max(frameWidth/e.target.content.width*pixelAspect, frameHeight/e.target.content.height);
            portImg = drawScale(tmpBMD, scale/pixelAspect, scale);

            this.addChild(portImg);
            //portImg.width *= scale/pixelAspect;
            //portImg.height *= scale;
            portImg.x = -portImg.width/2 + frameWidth/2 + portShiftX;
            portImg.y = -portImg.height/2 + frameHeight/2 + portShiftY;
            addChild(frameMask);
            portImg.mask = frameMask;

            if(isDiag) trace("[Port] Loaded: "+imgUrl);
        }

        public function pushPort(url:String):String {
            var imgLoader:Loader = new Loader();
            imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPushLoaded);
            imgLoader.load(new URLRequest(url));

            if(isDiag) trace("[port] Loading: "+url);

            var tmpUrl:String = imgUrl;
            imgUrl = url;
            return tmpUrl;
        }

        public function onPushLoaded(e:Event):void {
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            this.removeChildren();
            var tmpBMD:BitmapData = e.target.content.bitmapData;
            var scale:Number = Math.max(frameWidth/e.target.content.width*pixelAspect, frameHeight/e.target.content.height);
            portImg = drawScale(tmpBMD, scale/pixelAspect, scale);
            addChild(portImg);
            portImg.x = -portImg.width/2 + frameWidth/2 + portShiftX;
            portImg.y = -portImg.height/2 + frameHeight/2 + portShiftY;
            addChild(frameMask);
            portImg.mask = frameMask;
        }

        private function onError(err:IOErrorEvent):void {
            EventDispatcher(err.target).removeEventListener(err.type, arguments.callee);
            if(isDiag) trace("[port] URL Load Error : " + imgUrl);
        }

        private function drawScale(bigBMD:BitmapData, scaleX:Number, scaleY:Number):Bitmap {
            var mat:Matrix = new Matrix();
            mat.scale(scaleX, scaleY);
            var smallBMD:BitmapData = new BitmapData(bigBMD.width * scaleX, bigBMD.height * scaleY, true, 0x000000);
            smallBMD.draw(bigBMD, mat, null, null, null, true);
            var result:Bitmap = new Bitmap(smallBMD, PixelSnapping.NEVER, true);
            return result;
        }
	}

}
