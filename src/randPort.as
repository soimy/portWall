package  {

	import flash.display.*;
    import flash.system.Security;
    import flash.events.*;
    import flash.net.*;

    import com.greensock.*;
    import com.greensock.easing.*;

	public class randPort extends port{

        public var tweenSpeed:Number = 0.5;

		public function randPort() {
			// constructor code
            Security.allowDomain("*");
		}

        override public function onPushLoaded(e:Event):void {
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            var tweenContainer:MovieClip = new MovieClip();
            addChild(tweenContainer);

            var tempMC:DisplayObject = e.target.content;
            tempMC.width = frameWidth;
            tempMC.height = frameHeight;

            // Apply mask with frame width/height
            var mask:Shape = new Shape();
            mask.graphics.lineStyle(1, 0x000000);
            mask.graphics.beginFill(0x000000);
            mask.graphics.drawRect(0, 0, frameWidth, frameHeight);
            mask.graphics.endFill();
            tweenContainer.addChild(mask);
            mask.x = mask.y = 0;
            tweenContainer.addChild(tempMC);
            tempMC.mask = mask;


            var direction:int = Math.random()*4;
            if(isDiag) trace("[randPort] direction: "+direction);
            if(direction == 0){
                tempMC.x = 0;
                tempMC.y = - frameHeight;
            }else if (direction == 1){
                tempMC.x = - frameWidth;
                tempMC.y = 0;
            }else if (direction == 2){
                tempMC.x = 0;
                tempMC.y = frameHeight;
            }else if (direction == 3){
                tempMC.x = frameWidth;
                tempMC.y = 0;
            }
            TweenLite.to(tempMC, tweenSpeed, { x:0, y:0,
                    onComplete:onPushComplete,
                    onCompleteParams:[e.target.content]});

        }

        private function onPushComplete(newImg:DisplayObject):void {
            this.removeChildAt(0);
            //this.addChild(newImg);
        }
	}

}
