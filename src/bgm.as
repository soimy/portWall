package {

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer; 
    import flash.media.SoundTransform;
    import flash.net.URLRequest;

    public class bgm extends MovieClip {

        private var sndFileXML: XMLList;
        private var sounds : Array;
        private var count : int = 0;
        private var channel : SoundChannel;
        private var trans:SoundTransform; 

        public function bgm() {
            sounds = new Array();
            trans = new SoundTransform(1,0);
        }

        public function pushBgm(xml:XMLList):void {
            sndFileXML = xml;
            trace(sndFileXML.toString());
            musicOn();
        }

        public function volume(vol:Number):void {
            trans.volume = vol;
            channel.soundTransform = trans;
        }

        public function musicOff () : void {
            if (channel != null) 
            {
                channel.removeEventListener( Event.SOUND_COMPLETE, onSoundComplete );
                channel.stop( );
                channel = null;
            }
        }

        public function musicOn () : void {
            if (sounds[count] == null) loadSound( );
            else playLoadedSound( );
        }

        private function loadSound () : void {
            var sound : Sound = new Sound( );
            sound.addEventListener( Event.COMPLETE, onSoundLoaded );
            sound.load( new URLRequest( sndFileXML[count].toString() ) );
        }

        private function playLoadedSound () : void {
            channel = sounds[count].play( );
            channel.addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
            channel.soundTransform = trans;
        }

        private function onSoundComplete (ev : Event) : void {
            channel = null;
            count++;
            if (count >= sndFileXML.length()) count = 0;
            musicOn( );
        }

        private function onSoundLoaded (ev : Event) : void {
            var snd : Sound = ev.target as Sound;
            sounds.push( snd );
            channel = snd.play( );
            channel.addEventListener( Event.SOUND_COMPLETE, onSoundComplete );
            channel.soundTransform = trans;
        }


    }
}
