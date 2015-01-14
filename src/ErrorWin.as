package  {
	
	import flash.display.MovieClip;
    import flash.events.*;
	
    import com.greensock.*;
    import com.greensock.easing.*;
	
	public class ErrorWin extends MovieClip {
		
		public var isDiag:Boolean = true;

		public function ErrorWin() {
			// constructor code
            this.addEventListener(Event.ADDED_TO_STAGE, start);
		}
        
        private function start(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, start);
            this.x = 960;
            this.y = -500;
            TweenLite.to(this, 0.5, {y:540});

            restartBtn.mouseChildren = false;
            restartBtn.addEventListener(MouseEvent.CLICK, onClick);
        }

        private function onClick(e:MouseEvent):void {
            restartBtn.removeEventListener(MouseEvent.CLICK, onClick);
            TweenLite.to(this, 0.5, {y:-500});
			MovieClip(root).gotoAndStop(1);
            MovieClip(root).initFp();
            MovieClip(root).queryInProgress = false;
        }

	}
	
}
