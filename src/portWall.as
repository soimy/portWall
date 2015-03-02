package {

    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.system.Security;
    import flash.system.System;
    import flash.events.*;
    import flash.net.*;
    import flash.ui.Mouse;
    import flash.geom.Point;

    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DropShadowFilter;

    import com.greensock.*;
    import com.greensock.easing.*;
    import com.greensock.TimelineLite;

    public class portWall extends MovieClip {

        // variables for global display control
        public var row:uint = 3;
        public var col:uint = 2;
        public var frameWidth:uint = 1920;
        public var frameHeight:uint = 1080;
        public var slideDistance:uint = 948;
        public var preloadIncrement:uint = 20;

        // variables for card display control
        public var gpMargin:uint = 0;
        public var baseHeight:uint = 70;
        public var baseMargin:uint = 24;
        public var marginX:uint = 316; // 292 + 20px Margin
        public var marginY:uint = 436; // 316 + 30px Margin
        public var cardRow:uint = 2;
        public var labelMarginX:uint = 20;
        public var labelMarginY:uint = 30;
        public var cellWidth:uint;
		public var btnMargin:uint = 10;

        // variables for network connections
        public var siteUrl:String = "http://shader.jios.org:8080";
        public var queryUrl:String = "/xml/Default.aspx?";
        private var randPortInterval:uint = 5;
        private var signAutoShow:uint = 1;

        // variables for internal data exchange
        private var group:Array;
        private var gpList:XMLList;
        private var gpPos:uint;
        private var currentGpId:uint = 0;
        private var currentCardId:uint = 0;
        private var preloadCount:uint = 0;

        // Internal accessing DO
        //private var cardLayer:MovieClip;
        private var arrowL:Slider;
		private var arrowR:Slider;
        private var detailCardMC:detailCard;
        private var signDetailMC:signDetail;
        private var shadowFilters:Array;
        private var errWin:ErrorWin;
        private var configWin:cfgWin;
        private var wallScreen:bigScreen;
		private var navbtns:Vector.<nav_btn>;
        private var dbg:darkBG;
        public var bgMusic:bgm;

        // internal status tags
        public var currentQueryType:String = "";
        public var queryType:String = 'all';
        public var sortType:String = 'py';
        private var currentKeyword:String = '';
		private var currentUserClass:uint;
        private var loadedCard:uint = 0;
        public var queryInProgress:Boolean = false;
        public var isDiag:Boolean = true;

        private var bhTable:Array = new Array(
            "一划","二划","三划","四划","五划",
            "六划","七划","八划","九划","十划",
            "十一划","十二划","十三划","十四划","十五划",
            "十六划","十七划","十八划","十九划","二十划"
            );



        public function portWall() {

            Security.allowDomain("*");
            this.addEventListener(Event.ADDED_TO_STAGE, start);

            arrowL = new Slider();
            arrowR = new Slider();
            var shadowFilter:BitmapFilter = new DropShadowFilter(
                    6, 90, 0x000000, 0.5, 4, 4, 0.5,
                    BitmapFilterQuality.HIGH, false, false);
            shadowFilters = new Array();
            shadowFilters.push(shadowFilter);

            detailCardMC = new detailCard();
            signDetailMC = new signDetail();
            errWin = new ErrorWin();
            configWin = new cfgWin();
            wallScreen = new bigScreen();
            dbg = new darkBG();
            bgMusic = new bgm();

            // Nav setup section
            arrowL.rotation = 0;
            arrowR.rotation = 180;
            arrowL.mouseChildren = arrowR.mouseChildren = false;

            arrowL.filters = shadowFilters;
            arrowR.filters = shadowFilters;


            //prelog.btn_back.addEventListener(MouseEvent.CLICK, onPrelogBack);
        }

        //private function onPrelogBack(e:MouseEvent){
            //TweenLite.to(prelog, 0.5, {y:-1081});
            //testSlide();
        //}

        private function start(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, start);
            var cfgLoader:URLLoader = new URLLoader();
            cfgLoader.load(new URLRequest("config.xml"));
            cfgLoader.addEventListener(Event.COMPLETE, onCfgLoaded);
            cfgLoader.addEventListener(IOErrorEvent.IO_ERROR, onCfgError);
        }

        private function onCfgError(err:IOErrorEvent):void {
            EventDispatcher(err.target).removeEventListener(err.type, arguments.callee);
            if(isDiag) trace("[portWall] Config file not found, using default settings.");
            initFp();
        }

        private function onCfgLoaded(e:Event):void {
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            try{
                var cfgXML:XML = new XML(e.target.data);
            }catch(err:Error){
                if(isDiag) trace("[portWall] Config Error, using default settings.");
                initFp();
				return;
            }
            siteUrl = cfgXML.siteUrl;
            randPortInterval = cfgXML.delay;
            signAutoShow = cfgXML.signAutoShow;
            isDiag = cfgXML.isDiag;
            configWin.pwd = cfgXML.pwd;
            configWin.mute = (cfgXML.mute=="0")?false:true;
            bgMusic.pushBgm(cfgXML.bgmList.bgm);
            //trace(configWin.mute);
            if(isDiag) trace("[portWall] Config loaded successfully.");
			//init();
            if(isDiag){
                trace("Stage inited.");
                trace("[portWall] size: "+ frameWidth + "x"+ frameHeight);
            }else{
                Mouse.hide();
            }

            initFp();

        }

        public function initFp():void {

            this.gotoAndStop(1);

            titlebar.x = -14;
            titlebar.y = 64;
            prelog.x = 94;
            prelog.y = 235;
            fpBtn1.x = fpBtn2.x = fpBtn3.x = fpBtn4.x = fpBtn5.x = 1463;

            var tl: TimelineLite = new TimelineLite();
            tl.staggerFrom([titlebar, prelog], 0.5, {
                alpha: 0,
                x: "-150",
                ease: Linear.easeOut
            }, 0.3);
            tl.staggerFrom([fpBtn1, fpBtn2, fpBtn3, fpBtn4, fpBtn5, fpBtn6], 0.5, {
                alpha: 0,
                x: "150",
                ease: Linear.easeOut
            }, 0.2, "-=0.1");

            fpBtn1.addEventListener(MouseEvent.CLICK, fpBtnClick);
            fpBtn2.addEventListener(MouseEvent.CLICK, fpBtnClick);
            fpBtn3.addEventListener(MouseEvent.CLICK, fpBtnClick);
            fpBtn4.addEventListener(MouseEvent.CLICK, fpBtnClick);
            fpBtn5.addEventListener(MouseEvent.CLICK, fpBtnClick);
            //fpBtn6.addEventListener(MouseEvent.CLICK, fpBtnClick);
            btn_config.addEventListener(MouseEvent.CLICK, fpBtnClick);

			// Initialize randport screen
            wallScreen.siteUrl = siteUrl;
            wallScreen.interval = randPortInterval;
            wallScreen.isDiag = false;
            wallScreen.row = 5;
            wallScreen.col = 3;
            wallScreen.frameWidth = 2560;
            wallScreen.frameHeight = 1080;
            wallScreen.pixelAspect = 1.25;
            addChild(wallScreen);
			wallScreen.x = frameWidth;
			wallScreen.y = 0;

            // Apply mask for wallScreen
            var bigMask = new Shape();
            bigMask.graphics.lineStyle(1, 0x000000);
            bigMask.graphics.beginFill(0x000000);
            bigMask.graphics.drawRect(0, 0, 2560, frameHeight);
            bigMask.graphics.endFill();
            addChild(bigMask);
            bigMask.x = 1920;
            wallScreen.mask = bigMask;


        }

        public function fpBtnClick(e:MouseEvent):void {
            if(e.currentTarget.name == "btn_config"){
                this.dim(true);
                this.addChild(configWin);
                //configWin.x = 960;
                //configWin.y = 540;
                //configWin.gotoAndStop(1);
                return;
            }
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            var id:uint = int(e.currentTarget.name.substr(5,1));
            var tl: TimelineLite = new TimelineLite();
            tl.staggerTo([fpBtn1, fpBtn2, fpBtn3, fpBtn4, fpBtn5, fpBtn6], 0.5, {
                alpha: 0,
                x: "150",
                ease: Linear.easeIn
            }, 0.1);
            tl.staggerTo([prelog, titlebar], 0.5, {
                alpha: 0,
                x: "-150",
                ease: Linear.easeOut
            }, 0.2, "-=0.2" ,init, [id]);
        }


        public function init(userClass:uint):void {

            this.gotoAndStop(2);

            addChild(arrowL);
            addChild(arrowR);
            addChild(detailCardMC);
            addChild(signDetailMC);

            arrowL.y = arrowR.y = -500;
            arrowL.x = 58; arrowR.x = 1862;
            detailCardMC.y = -1083;
            detailCardMC.x = 2;
            signDetailMC.y = -1083;

            signDetailMC.x = 0;
            // Detail UI setup section
            detailCardMC.siteUrl = siteUrl;
            detailCardMC.isDiag = isDiag;
            detailCardMC.mute = configWin.mute;

            // signDetail UI setup section
            signDetailMC.siteUrl = siteUrl;
            signDetailMC.editable = false;

			TweenLite.from(arrowL, 0.5, { x:"-80" } );
			TweenLite.from(arrowR, 0.5, { x:"80" } );

            // Button setup section
			navbtns = new Vector.<nav_btn>;
            navbtnLayer.removeChildren();

			if (userClass == 5) {
				var btn_back:nav_btn = new nav_btn();
				btn_back.name = "btn5";
				navbtns.push(btn_back);
				btn_back.btnWidth = 382;
				navbtnLayer.addChild(btn_back);
				btn_back.x = frameWidth - btn_back.btnWidth - btnMargin;
				//btn_back.y = 1030;
				TweenLite.from(btn_back, 0.3, { y:"50", ease:Linear.easeOut } );
				initCard(userClass, "sign");
				return;
			}

            wallScreen.refreshPage(userClass);

			for (var i:uint = 1; i <= 5; i++) {
				var btn:nav_btn = new nav_btn();
				btn.name = "btn" + i;
				// Ignore the research division button for userClass 3/4
				if ((userClass == 3 || userClass == 4) && i == 4) continue;
				navbtns.push(btn);
			}

			for (var i:uint = 0; i < navbtns.length; i++) {
				var btnNum = navbtns.length;
				var btnWidth = (frameWidth - btnMargin) / btnNum - btnMargin;
				navbtns[i].btnWidth = btnWidth;
				navbtnLayer.addChild(navbtns[i]);
				navbtns[i].x = (btnMargin + btnWidth) * i + btnMargin;
				//navbtns[i].y = frameHeight - 135;
				TweenLite.from(navbtns[i], 0.3, { y:"140", ease:Linear.easeOut, delay:i*0.15 } );
			}


            initCard(userClass, "all","py");
            navbtns[1].setActive(true);

        }

        public function initCard(userClass:uint ,searchType:String, sort:String = 'py', keyword:String = ''):void {
            // initialize internal exchage datas

            queryInProgress = true;


            group = new Array();
            gpList = new XMLList();
            gpPos = baseMargin; // Margin to left screen edge is 24ps
            preloadCount = preloadIncrement;
            currentGpId = 0;
            currentCardId = 0;
            loadedCard = 0;

            if(labelLayer.y < frameHeight)
                TweenLite.to(labelLayer, 0.5, {y: frameHeight});

            //var tl = new TimelineLite();
            TweenLite.to(cardLayer, 0.5, {y: -frameHeight,
                    onComplete: function(){
                        cardLayer.removeChildren();
                        cardLayer.x = 0;
                        query(userClass, searchType, sort, keyword);
                    }} );
            //TweenLite.to(cardLayer, 0.5, {y: 0},"+=1");
        }

        public function query(userClass:uint, searchType:String, sort:String = 'py', keyword:String = ''):void {

            queryType = searchType;
            sortType = sort;
            currentKeyword = keyword;
            if(searchType == "all")
                queryImpl(userClass, "vip");
            else
                queryImpl(userClass, searchType, sort, keyword);

        }

        public function queryImpl(userClass:uint, searchType:String, sort:String = 'py', keyword:String = "" ):void {

            var finalQueryCmd:String = siteUrl + queryUrl;
            switch(searchType){
                case "all":
					  finalQueryCmd += "ut=" + userClass +"&";
                      finalQueryCmd += "sort=" + sort;
                      break;
                case "sign":
                      finalQueryCmd += "searchType=" + searchType;
                      break;
                case "vip":
                case "wall":
                      finalQueryCmd += "searchType=" + searchType ;
                      //finalQueryCmd += "sort=" + sort;
                      break;
                case "detail":
                      finalQueryCmd += "searchType=" + searchType + "&";
                      finalQueryCmd += "keyword=" + keyword ;
                      break;

                default:
					  finalQueryCmd += "ut=" + userClass;
                      finalQueryCmd += "&searchType=" + searchType;
                      finalQueryCmd += "&keyword=" + keyword ;
                      finalQueryCmd += "&sort=" + sort;
            }
            finalQueryCmd += "&nocache="+ new Date().getTime();

            currentQueryType = searchType;
			currentUserClass = userClass;

            if(isDiag) trace("[portWall] Query: " + finalQueryCmd);

                var xmlLoader:URLLoader = new URLLoader();
                xmlLoader.load(new URLRequest(finalQueryCmd));
                xmlLoader.addEventListener(Event.COMPLETE, onXmlLoad);
                //queryInProgress = true;

        }

        private function onRestart(e:MouseEvent):void {
            initFp();
        }

        private function onXmlLoad(e:Event):void {
            if(isDiag) trace("[portWall] XML Loaded.")


            var xmlData:XML = new XML(e.target.data);
            //trace(xmlData);
            if(xmlData.group == undefined && xmlData.user == undefined && currentQueryType != "sign"){
                trace("[portWall] XML data error!");
                trace(xmlData);
                //addChild(errWin);
                //errWin.restartBtn.addEventListener(MouseEvent.CLICK, onRestart);
                queryInProgress = false;
                //return;
            }

            if(xmlData.group != undefined)
            { // Normal portcard list
				for each(var gp:XML in xmlData.group){
					if(gp.user.length()>0)
						gpList += gp;
				}
                //trace(gpList);
                if(isDiag) trace("[portWall] "+sortType +" data loaded, count : " + gpList.length());
            }
            //else if(xmlData.user[0].content != undefined)
            else if(currentQueryType == "sign")
            { // If get sign xml, add group "sign" node as parent
                var signXML:XML =
                    <xml>
                        <group id="sign"/>
                    </xml>;
                if(xmlData.user[0] != undefined)
                    signXML.group.appendChild(xmlData.user);
                gpList = signXML.group;
                //gpList = xmlData.user;
                if(isDiag) trace("[portWall] Sign data loaded, count : " + gpList.length());
            }
            else
            { // If get vip info, add vip group info on top of gplist
                var vipXML:XML =
                    <xml>
                        <group id="vip"/>
                    </xml>;
                vipXML.group.appendChild(xmlData.user);
                //trace(vipXML);
                gpList = vipXML.group;
                //trace("[portWall] vip data loaded, count : "+ gpList.group[0].length());
            }


            if(currentQueryType == "vip")
                queryImpl(currentUserClass, queryType, sortType, currentKeyword);
            else if(currentQueryType == "sign"){
                drawSign();

            }else if(currentQueryType == queryType){
                drawCard();
				queryInProgress = false;
            }
        } // End of onXmlLoad

        private function drawSign():void {

            var signCol:uint = 3;
            cellWidth = (frameWidth - baseMargin) / signCol;
            var cellHeight:uint = 398;

            while(currentGpId < gpList.length()){
                var gp:XML = gpList[currentGpId];
                var usrCount:uint = gp.user.length();
                var cardCol:uint = Math.ceil(usrCount / cardRow);
				var gpMC:MovieClip;

                // if gpMC not created
                if(currentCardId == 0){
                    gpMC = new MovieClip();
                    var gpLabel:groupLabel = new groupLabel();
                    var gpName = gp.@id;

                    if (gpName == "vip" || gpName == "sign")
                        gpLabel.label_txt.text = gpName.toUpperCase();
                    else if (sortType == "bh")
                        gpLabel.label_txt.text = bhTable[int(gpName)-1];
                    else if (sortType == "xb")
                        gpLabel.label_txt.text = gp.user[0].researchpart.toString();
                    else
                        gpLabel.label_txt.text = gpName.toUpperCase();

                    gpLabel.keyword = gpName;

                    gpMC.addChild(gpLabel);
                    gpLabel.x = gpLabel.y = 0;

                    group.push(gpMC);
                    cardLayer.addChild(gpMC);

                    gpMC.y = 0;
                    gpMC.x = gpPos;

                    var gpWidth = marginX * cardCol + gpMargin;
                    gpPos += gpWidth;

                } else {
					gpMC = group[currentGpId];
				}

                //if(isDiag) trace ("[portWall] Adding Group [col:"+cardCol+" row:"+cardRow+" userCount:"+usrCount+" groupPos:"+gpPos+" ]");

                while(currentCardId < usrCount + 1){
                    var user:XML;
                    var signCard:port = new port();
                    signCard.frameWidth = cellWidth - 25;
                    signCard.frameHeight = cellHeight;
                    if(currentGpId == 0 && currentCardId == 0){
                        signCard.preloadMC = new signAdd();
                        signCard.mouseChildren = true; // important for mouseEvent.target
                    } else {
                        user = gp.user[currentCardId - 1];
                        signCard.preloadMC = new signLoad();
                        signCard.imgUrl = siteUrl + user.content;
                        signCard.mouseChildren = false; // important for mouseEvent.target
                    }
                    //signCard.portShiftX = -50;
                    cardLayer.addChild(signCard);
                    signCard.filters = shadowFilters;

                    signCard.isDiag = false;

                    // Defining position in wall
                    var col:uint = Math.floor(currentCardId / cardRow);
                    var row:uint = currentCardId % cardRow;
                    //signCard.x = marginX * col;
                    signCard.x = cellWidth * col + baseMargin;
                    signCard.y = baseHeight + marginY * row;

                    //if(isDiag) trace("[portWall] Adding Card ["+col+","+row+"] @"+pCard.x+","+pCard.y);

                    loadedCard ++;
                    currentCardId ++;

                    if(loadedCard >= preloadCount){
                        break;
                    }

                }

                if(currentCardId >= usrCount - 1){
                    currentCardId = 0;
                    currentGpId ++;
                }

				//if(currentGpId >= gpList.length())
					//currentGpId = 0;

                if(loadedCard >= preloadCount){
                    preloadCount += preloadIncrement;
                    trace("[portWall] Preloaded : " + loadedCard);
                    break;
                }


            }
			//queryInProgress = false;
            //testSlide();
            if(cardLayer.y < 0)
                TweenLite.to(cardLayer, 0.5, {y: 0, onComplete: testSlide});
            else
                queryInProgress = false;

        }

        private function drawCard():void {

            //var gpId:uint = 0;

            while(currentGpId < gpList.length()){
                var gp:XML = gpList[currentGpId];
                var usrCount:uint = gp.user.length();
                var cardCol:uint = Math.ceil(usrCount / cardRow);
				var gpMC:MovieClip;

                // if gpMC not created
                if(currentCardId == 0){
                    gpMC = new MovieClip();
                    var gpLabel:groupLabel = new groupLabel();
                    var gpName = gp.@id;

                    if (gpName == "vip")
                        gpLabel.label_txt.text = gpName.toUpperCase();
                    else if (sortType == "bh")
                        gpLabel.label_txt.text = bhTable[int(gpName)-1];
                    else if (sortType == "xb")
                        gpLabel.label_txt.text = gp.user[0].researchpart.toString();
                    else
                        gpLabel.label_txt.text = gpName.toUpperCase();

                    gpLabel.keyword = gpName;

					if(usrCount)gpMC.addChild(gpLabel);
                    gpLabel.x = gpLabel.y = 0;

                    group.push(gpMC);
                    cardLayer.addChild(gpMC);

                    gpMC.y = 0;
                    gpMC.x = gpPos;

                    var gpWidth = marginX * cardCol + gpMargin;
                    gpPos += gpWidth;

                } else {
					gpMC = group[currentGpId];
				}




                //if(isDiag) trace ("[portWall] Adding Group [col:"+cardCol+" row:"+cardRow+" userCount:"+usrCount+" groupPos:"+gpPos+" ]");

                while(currentCardId < usrCount){
                    var user:XML = gp.user[currentCardId];
                    var pCard:portCard = new portCard();
                    pCard.mouseChildren = false; // important for mouseEvent.target
                    pCard.siteUrl = siteUrl;
                    pCard.cardXML = user;
                    pCard.isDiag = false;
                    gpMC.addChild(pCard);

                    // Defining position in wall
                    var col:uint = Math.floor(currentCardId / cardRow);
                    var row:uint = currentCardId % cardRow;
                    pCard.x = marginX * col;
                    pCard.y = baseHeight + marginY * row;

                    //if(isDiag) trace("[portWall] Adding Card ["+col+","+row+"] @"+pCard.x+","+pCard.y);

                    loadedCard ++;
                    currentCardId ++;

                    if(loadedCard >= preloadCount){
                        break;
                    }

                }

                if(currentCardId > usrCount - 1){
                    currentCardId = 0;
                    currentGpId ++;
                }

				//if(currentGpId >= gpList.length())
					//currentGpId = 0;

                if(loadedCard >= preloadCount){
                    preloadCount += preloadIncrement;
                    trace("[portWall] Preloaded : " + loadedCard);
                    break;
                }


            }
			//queryInProgress = false;
            //testSlide();
            if(cardLayer.y < 0)
                TweenLite.to(cardLayer, 0.5, {y: 0, onComplete: testSlide});
            else{
                queryInProgress = false;
            }


        } // End of drawCard

        public function drawLabel():void {
            var rowCount:uint = 3;
            //var baseMargin:uint = 50;
            var labelId:uint = 0;
            var currentPosX:Array = new Array(rowCount);
            //initialize row posx
            for(var i=0; i<rowCount; i++)
                currentPosX[i] = baseMargin;
            //var currentPosY:uint = 0;
            labelLayer.removeChildren();

            // Add a cancel label first add ++labelId
            var allLabel:groupLabel = new groupLabel();
            allLabel.label_txt.text = "取消过滤";
            allLabel.keyword = "all";
            labelLayer.addChild(allLabel);
            allLabel.x = currentPosX[0];
            allLabel.y = 0;
            labelId ++;
            currentPosX[0] += allLabel.width + labelMarginX;

            for each(var gp:XML in gpList){
                if(gp.user.length() == 0) continue;
                var gpName:String = gp.@id;
                if(gpName == "vip") continue;

                var gpLabel:groupLabel = new groupLabel();

                if (sortType == "bh")
                    gpLabel.label_txt.text = bhTable[int(gpName)-1];
                else if (sortType == "xb")
                    gpLabel.label_txt.text = gp.user[0].researchpart.toString();
                else
                    gpLabel.label_txt.text = gpName.toUpperCase();

                gpLabel.keyword = gpName;
                labelLayer.addChild(gpLabel);

                var row:uint = labelId % rowCount;
                var col:uint = Math.floor(labelId / rowCount);
                gpLabel.x = currentPosX[row];
                gpLabel.y = (gpLabel.height + labelMarginY) * row;

                labelId ++;
                currentPosX[row] += gpLabel.width + labelMarginX;

                if(isDiag) trace("[portWall] Label Menu item added : " + gpName);

            }
        }

        private function onClick(e:MouseEvent):void {

            if(isDiag){
                //trace("[portWall] Clicked at : " + e.target );
                var mem:String = (System.totalMemory / 1024 / 1024).toFixed(2) + " MB";
                trace("[portWall] Memory usage : " + mem);
            }

            if(queryInProgress){
                if(isDiag) trace("[portWall] Querying, ignore click.");
                return;
            }

            if(e.target is portCard){
                //trace(e.target);

                var pid:String = e.target.portId;
                trace("[portWall] Selected PortId: " + pid);
                var detailQueryCmd:String = "/xml/Default.aspx?searchtype=detail&keyword="+pid;
                detailQueryCmd += "&nocache="+ new Date().getTime();
                var xmlLoader:URLLoader = new URLLoader();
                xmlLoader.load(new URLRequest(siteUrl+detailQueryCmd));
                xmlLoader.addEventListener(Event.COMPLETE, onDetailXmlLoad);
                queryInProgress = true;
            }
            else if(e.target is port){
                //var url:String = e.target.imgUrl;
                signDetailMC.uploadAutoShow = signAutoShow;
                signDetailMC.pushSign(e.target.imgUrl);
                TweenLite.to(signDetailMC, 0.5, {y:0});
                queryInProgress = true;
            }
            else if(e.target is signAdd){
                signDetailMC.addSign();
                TweenLite.to(signDetailMC, 0.5, {y:0});
                queryInProgress = true;

            }

            else if(e.target is Slider){
                removeEventListener(MouseEvent.CLICK, onClick);
                e.target.gotoAndPlay(1);
                var direction:Number = e.target.rotation;
                var newx = Math.cos(direction / 180 * Math.PI) * slideDistance;
                //if(isDiag) trace("[portWall] Sliding to : " + (cardLayer.x + newx));
                TweenLite.to(cardLayer, 0.5, { x:String(newx), onComplete:testSlide });

            }

            //else if(e.target.name == "btn_info"){
                //TweenLite.to(prelog, 0.5, {y:0});
                //arrowR.y = arrowL.y = -500;
            //}

            else if(e.target is nav_btn){

                removeEventListener(MouseEvent.CLICK, onClick);

                if (e.target.name == "btn5") {
					// return to frontpage
                    wallScreen.refreshPage(0);
                    TweenLite.to(cardLayer, 0.5, {y: -frameHeight,
                        onComplete: function(){
                            cardLayer.removeChildren();
                            cardLayer.x = 0;
                        }} );
                    if(labelLayer.y < frameHeight)
                        TweenLite.to(labelLayer, 0.5, {y: frameHeight});

                    for(var i:uint = 0; i < navbtns.length-1; i++){
                        TweenLite.to(navbtns[i], 0.3, {y:"140", ease:Linear.easeIn, delay:0.15*i})
                    }
                    TweenLite.to(
                        navbtns[navbtns.length-1],
                        0.3,
                        {
                            y:"140",
                            ease:Linear.easeIn,
                            delay:0.15*navbtns.length,
                            onComplete: function(){
                                queryInProgress = false;
                                gotoAndStop(1);
                                initFp();
                            }
                        });

                    TweenLite.to(arrowL, 0.5, { x:"-80" } );
                    TweenLite.to(arrowR, 0.5, { x:"80",
                        onComplete: function(){
                            removeChild(arrowL);
                            removeChild(arrowR);
                            removeChild(detailCardMC);
                            removeChild(signDetailMC);
                        } } );

                    return;
                }

                if(e.target.isActive){
                    if(cardLayer.y >= 0){
                        TweenLite.to(cardLayer, 0.5, {y: -frameHeight*0.25 });
                        TweenLite.to(labelLayer, 0.5, {y: frameHeight*0.65, onComplete:testSlide});
                        if(currentQueryType == "all")
                            drawLabel();
                    }else{
                        TweenLite.to(cardLayer, 0.5, {y: 0});
                        TweenLite.to(labelLayer, 0.5, {y: frameHeight, onComplete:testSlide});
                    }
                    return;
                }

                //removeEventListener(MouseEvent.CLICK, onClick);

                var searchType:String = e.target.queryType;
                var sort:String = e.target.sortType;
                var keyword:String = e.target.keyword;
                if(isDiag) trace("[portWall] Switch Querytype to :" + sort);

				for each (var navbtn:nav_btn in navbtns) {
					if (navbtn.name != "btn5")
						navbtn.setActive(false);
				}

				e.target.setActive(true);
                initCard(currentUserClass, searchType, sort);
            }

            else if(e.target is groupLabel && e.target.localToGlobal(new Point(0,0)).y > 200){
                removeEventListener(MouseEvent.CLICK, onClick);
                if(e.target.keyword == "all")
                    initCard(currentUserClass, "all", sortType);
                else
                    initCard(currentUserClass, sortType, sortType, e.target.keyword);
            }
        }

        private function testSlide():void {
            queryInProgress = false;
            if(cardLayer.x >=0)
                arrowL.y = -500;
            else
                arrowL.y = 485;

            if(cardLayer.x < - cardLayer.width + frameWidth)
                arrowR.y = -500;
            else
                arrowR.y = 485;

            if((arrowL.y>0 || arrowR.y>0) && labelLayer.y < frameHeight - 10)
                arrowR.y = arrowL.y = -500;

            if(cardLayer.x < - marginX * Math.ceil(loadedCard / 2) + 2 * frameWidth
                    && currentGpId < gpList.length()
                    && currentQueryType != "sign"){
                drawCard();
            }

            if(currentQueryType == "sign"
                    && cardLayer.x < - cellWidth * Math.ceil(loadedCard  / 2) + 2 * frameWidth){
                drawSign();
            }

            addEventListener(MouseEvent.CLICK, onClick);
        }

        private function onDetailXmlLoad(e:Event):void {
            EventDispatcher(e.target).removeEventListener(e.type, arguments.callee);
            var detailXML:XML = new XML(e.target.data);
            if(detailXML.user == undefined){
                if(isDiag) trace("[portWall] Detail XML Data Error!");
                addChild(new ErrorWin());
                return;
            }

            //trace(detailXML);
            //queryInProgress = false;

            detailCardMC.mute = configWin.mute;
            detailCardMC.pushPort(detailXML.user[0]);
            TweenLite.to(detailCardMC, 0.5, {y:0});

        }

        public function dim(stat:Boolean):void {
            if(stat){
                dbg.width = 1920;
                dbg.height = 1080;
                addChild(dbg);
                dbg.alpha = 0.5;
                TweenLite.from(dbg, 0.5, {alpha:0});
            }else{
                if(contains(dbg)){
                    TweenLite.to(dbg, 0.5, {alpha:0, onComplete:onDimRemove});
                }
            }
        }

        private function onDimRemove():void {
            removeChild(dbg);
        }
    }

}
