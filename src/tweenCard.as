package {
    
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
    import flash.geom.Point;
    import flash.geom.Matrix;
    import flash.geom.PerspectiveProjection;
    import com.greensock.*;
    import com.greensock.easing.*;
    import flash.media.Video;
	import flash.media.SoundTransform;


    public class tweenCard extends MovieClip {

        public var frameWidth:uint = 512;
        public var frameHeight:uint = 360;
        public var tweenSpeed:Number = 0.5;
        public var pixelAspect:Number = 1;
        public var tweenType:uint = 0; 
            // 0 = no animation
			// 1 = swipe left
            // 2 = swipe right
            // 3 = swipe top
            // 4 = swipe bottom
            // 5 = flip x
            // 6 = flip y
        public var fillMode:uint = 0; // 0 = fill, 1 = match, 2 = matchfill
		public var isDiag:Boolean = true;
		public var mute:Boolean = false;
		public var autoPlay:Boolean = false;
		
        private var tl:TimelineLite;
        private var mc1,mc2:MovieClip;
        private var cacheBM:Bitmap;
        private var frameMask:Shape;
		private var vid:Video;
		private var ns:NetStream;
		
		public var currentUrl:String;
    
        public function tweenCard(){
            this.addEventListener(Event.ADDED_TO_STAGE, start);
            tl = new TimelineLite();
            mc1 = new MovieClip();
            mc2 = new MovieClip();
        }

        private function start(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, start);
            addChild(mc1);
            addChild(mc2);
            mc1.x = mc2.x = frameWidth/2;
            mc1.y = mc2.y = frameHeight/2;

            //var bm1:Bitmap = new Bitmap(new BitmapData(frameWidth, frameHeight));
            //mc1.addChild(bm1);
            //bm1.x = -frameWidth/2;
            //bm1.y = -frameHeight/2;

            frameMask = new Shape();
            frameMask.graphics.lineStyle(1, 0x000000);
            frameMask.graphics.beginFill(0x000000);
            frameMask.graphics.drawRect(0, 0, frameWidth, frameHeight);
            frameMask.graphics.endFill();

            addChild(frameMask);
            this.mask = frameMask;

            transform.perspectiveProjection= new PerspectiveProjection();
            transform.perspectiveProjection.projectionCenter = new Point(frameWidth/2, frameHeight/2);
        }

        public function pushUrl(url:String):void {
			// typ : 0 = image, 1 = movie
			if(url == "") return;
			this.currentUrl = url;
			var typ:String = url.substr(url.length-3);
			// trace(typ);
			if(typ == "mp4" || typ == "flv"){
				var vidMC:MovieClip = new MovieClip();
				vidMC.graphics.lineStyle(1, 0x000000);
				vidMC.graphics.beginFill(0x000000);
				vidMC.graphics.drawRect(0, 0, frameWidth, frameHeight);
				vidMC.graphics.endFill();
				var pIcon:playIcon = new playIcon();
				pIcon.height = frameHeight * 0.3;
				pIcon.width = pIcon.height / this.pixelAspect;
				vidMC.addChild(pIcon);
				pIcon.x = this.frameWidth / 2;
				pIcon.y = this.frameHeight / 2;
				var bmd:BitmapData = new BitmapData(frameWidth, frameHeight);
				bmd.draw(vidMC);
				pushPort(bmd);
				
				if(!autoPlay) this.addEventListener(MouseEvent.CLICK, onVidClick);
				
			} else {
				this.removeEventListener(MouseEvent.CLICK, onVidClick);
				var imgLoader:Loader = new Loader();
				imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
				imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
				imgLoader.load(new URLRequest(url));
				return;
			}
        }
		
		private function onVidClick(e:MouseEvent):void {
			this.disableVid();
			this.playVid(currentUrl);
		}

        private function onLoaded(e:Event):void {
            pushPort(e.target.content.bitmapData);
        }
		
		private function onIOErrorHandler(e:IOErrorEvent):void {
            
        }

        public function pushPort(tmpBMD:BitmapData):void {
			this.disableVid();
			
            var mc:Bitmap = new Bitmap(tmpBMD);
            var scaleX, scaleY :Number;
            switch(fillMode){
                case 0:
                    scaleX = frameWidth/mc.width*pixelAspect;
                    scaleY = frameHeight/mc.height;
                    break;
                case 1:
                    scaleX = scaleY = Math.min(frameWidth/mc.width*pixelAspect, frameHeight/mc.height);
                    break;
                case 2:
                    scaleX = scaleY = Math.max(frameWidth/mc.width*pixelAspect, frameHeight/mc.height);
                    break;
            }
            cacheBM = drawScale(tmpBMD, scaleX/pixelAspect, scaleY);
            mc2.addChild(cacheBM);
            cacheBM.x = -cacheBM.width/2;
            cacheBM.y = -cacheBM.height/2;
            tweenit(tweenType);
        }

        private function tweenit(typ:uint):void {
            // trace(typ);
            mc1.x = mc2.x = frameWidth/2;
            mc1.y = mc2.y = frameHeight/2;
            switch(typ){
				case 0:
					onTweenEnd();
					break;
                case 1:
                case 2:
                    TweenLite.to(mc1, tweenSpeed, {
                        x:(frameWidth * (typ * 2 - 3 ) + frameWidth / 2)
                    });
                    TweenLite.from(mc2, tweenSpeed, {
                        x:(-frameWidth * (typ * 2 - 3 ) + frameWidth / 2), 
                        onComplete:onTweenEnd
                    });
                    break;
                case 3:
                case 4:
                    TweenLite.to(mc1, tweenSpeed, {
                        y:(frameHeight * (typ * 2 - 7 ) + frameHeight / 2)
                    });
                    TweenLite.from(mc2, tweenSpeed, {
                        y:(-frameHeight * (typ * 2 - 7 ) + frameHeight / 2), 
                        onComplete:onTweenEnd
                    });
                    break;
                case 5:
                    tl.clear();
                    tl.to(mc1, tweenSpeed * 0.35, {
                        rotationX: 90, 
                        ease: Quad.easeIn
                    });
                    tl.from(mc2, tweenSpeed * 0.65, {
                        rotationX: -90, 
                        ease: Back.easeOut, onComplete:onTweenEnd
                    });
                    break;
                case 6:
                    tl.clear();
                    tl.to(mc1, tweenSpeed * 0.35, {
                        rotationY: 90, 
                        ease: Quad.easeIn
                    });
                    tl.from(mc2, tweenSpeed * 0.65, {
                        rotationY: -90, 
                        ease: Back.easeOut, 
                        onComplete:onTweenEnd
                    });
                    break;
            }
        }

        private function onTweenEnd():void {
            mc1.removeChildren();
            mc2.removeChildren();
			mc1.addChild(cacheBM);
            mc1.x = mc2.x = frameWidth/2;
            mc1.y = mc2.y = frameHeight/2;
            mc1.rotationX = mc2.rotationX = 0;
            mc1.rotationY = mc2.rotationY = 0;
            //removeChild(mc2);
			var typ:String = currentUrl.substr(currentUrl.length-3);
			if((typ == "mp4" || typ == "flv") && autoPlay){
				this.playVid(currentUrl);
			}			
        }

        private function drawScale(bigBMD:BitmapData, scaleX:Number, scaleY:Number):Bitmap {
            var mat:Matrix = new Matrix();
            mat.scale(scaleX, scaleY);
            var smallBMD:BitmapData = new BitmapData(bigBMD.width * scaleX, bigBMD.height * scaleY, true, 0x000000);
            smallBMD.draw(bigBMD, mat, null, null, null, true);
            var result:Bitmap = new Bitmap(smallBMD, PixelSnapping.NEVER, true);
            return result;
        }
		
		public function playVid(mUrl:String) {

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
			vid.smoothing = true;
			var vscaleX, vscaleY :Number;
			switch(fillMode){
                case 0:
                    vscaleX = frameWidth/vid.width*pixelAspect;
                    vscaleY = frameHeight/vid.height;
                    break;
                case 1:
                    vscaleX = vscaleY = Math.min(frameWidth / vid.width * pixelAspect, frameHeight / vid.height);
                    break;
                case 2:
                    vscaleX = vscaleY = Math.max(frameWidth / vid.width * pixelAspect, frameHeight / vid.height);
                    break;
            }
            vid.width = vid.width * vscaleX/pixelAspect;
            vid.height = vid.height * vscaleY;
			vid.x = frameWidth/2 - vid.width/2;
			vid.y = frameHeight/2 - vid.height/2;
        }
		
		private function netStatusHandler(e:NetStatusEvent):void {
            if(e.info.code == "NetStream.Play.StreamNotFound")
                trace("[tweenCard] Movie load error: "+e);
        }

        private function asyncErrorHandler(e:AsyncErrorEvent):void {
            trace("[tweenCard] Movie load error: "+e);
        }

		private function onVidEnd(item:Object):void {
			if(isDiag) trace ("[detailCard] Video finished.");
            disableVid();
			//this.removeChild(vid);
		}
		
		public function disableVid():void {
            if(vid != null){
                removeChild(vid);
                vid = null;
                ns.close();
                ns = null;
            }
        }

    }

}
