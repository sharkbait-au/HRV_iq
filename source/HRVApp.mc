using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Time.Gregorian as Calendar;

enum {

	// Settings memory locations
	TIMESTAMP = 0,
	APP_NAME = 1,
	VERSION = 2,
	GREEN_TIME = 5,
	SOUND = 6,
	VIBE = 7,
	TEST_TYPE = 8,
	TIMER_TIME = 9,
	AUTO_START = 10,
	AUTO_TIME = 11,
	BG_COL = 12,
	LABEL_COL = 13,
	TEXT_COL = 14,

	HRV_COL = 15,		// Not applied yet
	AVG_HRV_COL = 16,	// Not applied yet
	PULSE_COL = 17,		// Not applied yet
	AVG_PULSE_COL = 18,	// Not applied yet

	INHALE_TIME = 20,
	EXHALE_TIME = 21,
	RELAX_TIME = 22,

	// Results memory locations. (X) <> (X + 29)
	RESULTS = 100,

	// Colors
	WHITE = 16777215,
	LT_GRAY = 11184810,
	DK_GRAY = 5592405,
	BLACK = 0,
	RED = 16711680,
	DK_RED = 11141120,
	ORANGE = 16733440,
	YELLOW = 16755200,
	GREEN = 65280,
	DK_GREEN = 43520,
	BLUE = 43775,
	DK_BLUE = 255,
	PURPLE = 11141375,
	PINK = 16711935,

	// Tones
	TONE_KEY = 0,
	TONE_START = 1,
	TONE_STOP = 2,
	TONE_RESET = 9,
	TONE_FAILURE = 14,
	TONE_SUCCESS = 15,
	TONE_ERROR = 18,

	// Test types
	TYPE_TIMER = 0,
	TYPE_MANUAL = 1,
	TYPE_AUTO = 2,

	// Device types
	EPIX = 0,
	FENIX = 1,
	FORERUNNER = 2,
	VIVOACTIVE = 3,

	// Views
	TEST_VIEW = 0,
	RESULT_VIEW = 1,
	GRAPH_VIEW = 2,
	WATCH_VIEW = 3,

	// Test minimum
	MIN_SAMPLES = 20

}

class HRVApp extends App.AppBase {

    // The device type
	var device;

	// Settings variables
    var timestampSet;
	var appNameSet;
	var versionSet;

	var greenTimeSet;
	var soundSet;
	var vibeSet;
	var testTypeSet;
	var timerTimeSet;
	var autoStartSet;
	var autoTimeSet;
	var bgColSet;
	var lblColSet;
    var txtColSet;
	var hrvColSet;
	var avgHrvColSet;
	var pulseColSet;
	var avgPulseColSet;

	var inhaleTimeSet;
	var exhaleTimeSet;
	var relaxTimeSet;

	// Results array variable
	var results;

	// View trackers
	var viewNum;
	var lastViewNum;

	// Ant channel & states
	var antCh;

	var isChOpen;
    var isAntRx;
    var isStrapRx;
    var isPulseRx;

	// App states
	var isWaiting;
	var isTesting;
	var isFinished;
	var isNotSaved;
	var isSaved;
	var isClosing;
	var isSeconds;
	var isMinutes;

	// Test variables
	var hrv;
	var avgPulse;
	var devSqSum;
	var pulseSum;
	var dataCount;

	var utcStart;
	var utcStop;

	var startMoment;
	//var stopMoment;

	var livePulse;
    var timeAutoStart;
    var timerTime;

	hidden var mNoPulseCount;
    hidden var mPrevIntMs;
    hidden var mPrevBeatCount;
    hidden var mPrevBeatEvent;

    hidden var greenTimer;
    hidden var viewTimer;
    hidden var testTimer;

	function resetSettings() {

		// Retrieve default settings from file
		timestampSet = Ui.loadResource(Rez.Strings.Timestamp);
		appNameSet = Ui.loadResource(Rez.Strings.AppName);
		versionSet = Ui.loadResource(Rez.Strings.Version);

		greenTimeSet = Ui.loadResource(Rez.Strings.GreenTime).toNumber();
		soundSet = Ui.loadResource(Rez.Strings.Sound).toNumber();
		vibeSet = Ui.loadResource(Rez.Strings.Vibe).toNumber();
		testTypeSet = Ui.loadResource(Rez.Strings.TestType).toNumber();
		timerTimeSet = Ui.loadResource(Rez.Strings.TimerTime).toNumber();
		autoStartSet = Ui.loadResource(Rez.Strings.AutoStart).toNumber();
		autoTimeSet = Ui.loadResource(Rez.Strings.AutoTime).toNumber();
		bgColSet = Ui.loadResource(Rez.Strings.BgCol).toNumber();
		lblColSet = Ui.loadResource(Rez.Strings.LblCol).toNumber();
		txtColSet = Ui.loadResource(Rez.Strings.TxtCol).toNumber();
		hrvColSet = Ui.loadResource(Rez.Strings.HrvCol).toNumber();
		avgHrvColSet = Ui.loadResource(Rez.Strings.AvgHrvCol).toNumber();
		pulseColSet = Ui.loadResource(Rez.Strings.PulseCol).toNumber();
		avgPulseColSet = Ui.loadResource(Rez.Strings.AvgPulseCol).toNumber();

		inhaleTimeSet = Ui.loadResource(Rez.Strings.inhaleTime).toNumber();
		exhaleTimeSet = Ui.loadResource(Rez.Strings.exhaleTime).toNumber();
		relaxTimeSet = Ui.loadResource(Rez.Strings.relaxTime).toNumber();
	}

	function resetResults() {

		results = new [150];

		for(var i = 0; i < 150; i++) {
			results[i] = 0;
		}
	}

    //! onStart() is called on application start up
    function onStart() {

		// Retrieve device type
		device = Ui.loadResource(Rez.Strings.Device).toNumber();

		if(VIVOACTIVE == device) {
		 	return;
		}

		// Retrieve saved settings from memory
		resetSettings();
    	var value;

    	value = getProperty(GREEN_TIME);
		if(null != value) {
			// ensure a reasonable minimum
			if(10 > value){
				value = 10;
			}
    		greenTimeSet = value;
    	}
    	value = getProperty(SOUND);
		if(null != value) {
    		soundSet = value;
    	}
    	value = getProperty(VIBE);
		if(null != value) {
    		vibeSet = value;
    	}
    	value = getProperty(TEST_TYPE);
		if(null != value) {
    		testTypeSet = value;
    	}
    	value = getProperty(TIMER_TIME);
		if(null != value) {
    		timerTimeSet = value;
    	}
    	value = getProperty(AUTO_START);
		if(null != value) {
    		autoStartSet = value;
    	}
    	value = getProperty(AUTO_TIME);
		if(null != value) {
    		autoTimeSet = value;
    	}
    	value = getProperty(BG_COL);
		if(null != value) {
    		bgColSet = value;
    	}
    	value = getProperty(LABEL_COL);
		if(null != value) {
    		lblColSet = value;
    	}
    	value = getProperty(TEXT_COL);
		if(null != value) {
    		txtColSet = value;
    	}
    	//value = getProperty(HRV_COL);
		//if(null != value) {
    	//	hrvColSet = value;
    	//}
    	//value = getProperty(AVG_HRV_COL);
		//if(null != value) {
    	//	avgHrvColSet = value;
    	//}
    	//value = getProperty(PULSE_COL);
		//if(null != value) {
    	//	pulseColSet = value;
    	//}
    	//value = getProperty(AVG_PULSE_COL);
		//if(null != value) {
    	//	avgPulseColSet = value;
    	//}

    	value = getProperty(INHALE_TIME);
		if(null != value) {
    		inhaleTimeSet = value;
    	}
    	value = getProperty(EXHALE_TIME);
		if(null != value) {
    		exhaleTimeSet = value;
    	}
    	value = getProperty(RELAX_TIME);
		if(null != value) {
    		relaxTimeSet = value;
    	}

    	 if(VIVOACTIVE == device) {
    	 	soundSet = 0;
    	 }

		// Retrieve saved results from memory
		resetResults();

		for(var i = 0; i < 30; i++) {
			var ii = i * 5;
			var result = getProperty(RESULTS + i);
			if(null != result) {
				results[ii + 0] = result[0];
				results[ii + 1] = result[1];
				results[ii + 2] = result[2];
				results[ii + 3] = result[3];
				results[ii + 4] = result[4];
			}
		}

		// Init ant variables
		closeCh();
		mNoPulseCount = 0;
	    mPrevIntMs = 0;
	    mPrevBeatCount = 0;
	    mPrevBeatEvent = 0;

		// Init test variables
		resetTest();
		startMoment = 0;
		livePulse = 0;
    	timeAutoStart = 0;
    	timerTime = 0;

    	// Init view variables
		viewNum = 0;
		lastViewNum = 0;

		isClosing = false;
		isSeconds = false;
		isMinutes = false;

		// Init timers
    	greenTimer = new Timer.Timer();
		viewTimer = new Timer.Timer();
		testTimer = new Timer.Timer();
    }

    function startTest() {

    	alert(TONE_START);
    	start();
    }

    function stopTest() {

    	endTest();
		alert(TONE_STOP);
    }

    function finishTest() {

    	endTest();
    	alert(TONE_SUCCESS);
    }

    function autoFinish() {

    	endTest();
    	saveTest();
    	resetGreenTimer();
    }

    function endTest() {

    	testTimer.stop();
    	if(isWaiting) {

			isWaiting = false;
			if(!isChOpen) {

				openCh();
			}
		}
		else {

			isTesting = false;
			isFinished = true;
			isNotSaved = true;
			utcStop = timeNow();
		}
    }

    function discardTest() {

    	isNotSaved = false;
    }

    function resetTest() {

		hrv = 0;
		avgPulse = 0;
		devSqSum = 0;
		pulseSum = 0;
		dataCount = 0;
		utcStart = 0;
		utcStop = 0;
		isWaiting = false;
		isTesting = false;
		isFinished = false;
		isNotSaved = false;
		isSaved = false;
    }

    function start() {

		testTimer.stop();	// This is in case user has changed test type while waiting
    	var testType = testTypeSet;
    	if(TYPE_MANUAL != testType){
			if(TYPE_AUTO == testType) {
				// Auto wait
				if(!isWaiting) {
					timeAutoStart = timeToday() + autoStartSet;
					timerTime = autoTimeSet;
					if(timeAutoStart < timeNow()) {
						timeAutoStart += 86400;
					}
					isWaiting = true;
					if(isChOpen) {
						closeCh();
					}
					testTimer.start(method(:start),(timeAutoStart - timeNow())*1000,false); // false
					return;
				}
				else {
					isWaiting = false;
					if(!isChOpen) {
						openCh();
					}
					testTimer.start(method(:autoFinish),timerTime*1000,true); // true
				}
			}
			// Timer start
			else {
				timerTime = timerTimeSet;
				testTimer.start(method(:finishTest),timerTime*1000,false); // false
			}
		}
		// Common start
		startMoment = Time.now();
		//utcStart = timeNow();
		utcStart = startMoment.value() + System.getClockTime().timeZoneOffset;
		isTesting = true;
    }

    function saveTest()
    {
		var testDay = utcStart - (utcStart % 86400);
		var epoch = testDay - (86400 * 29);
		var index = ((testDay / 86400) % 30) * 5;
		var sumHrv = 0;
		var sumPulse = 0;
		var count = 0;

		// REMOVE FOR PUBLISH
		//index = ((timeNow() / 3600) % 30) * 5;
		// REMOVE FOR PUBLISH
		//index = ((timeNow() / 60) % 30) * 5;

		results[index + 0] = utcStart;
		results[index + 1] = hrv;
		results[index + 2] = avgPulse;

		// Calculate averages
		for(var i = 0; i < 30; i++) {

			var ii = i * 5;

			if(epoch <= results[ii]) {

				sumHrv += results[ii + 1];
				sumPulse += results[ii + 2];
				count++;
			}
		}
		results[index + 3] = sumHrv / count;
		results[index + 4] = sumPulse / count;

		// Print values to file in csv format with ISO 8601 date & time
		var date = Calendar.info(startMoment, 0);
    	System.println(format("$1$-$2$-$3$T$4$:$5$:$6$,$7$,$8$,$9$,$10$",[
    		date.year,
    		date.month,
    		date.day,
    		date.hour,
    		date.min.format("%02d"),
    		date.sec.format("%02d"),
    		hrv,
    		avgPulse,
    		sumHrv / count,
    		sumPulse / count]));

		isNotSaved = false;
    	isSaved = true;
    }

    //! onStop() is called when your application is exiting
    function onStop() {

    	if(VIVOACTIVE == device) {
		 	return;
		}

    	// Cloase ant channel
		closeCh();

    	// Save settings to memory
    	if(timestampSet != getProperty(TIMESTAMP)) {
    		setProperty(TIMESTAMP, timestampSet);
    	}
    	if(appNameSet != getProperty(APP_NAME)) {
    		setProperty(APP_NAME, appNameSet);
    	}
		if(versionSet != getProperty(VERSION)) {
    		setProperty(VERSION, versionSet);
    	}

		if(greenTimeSet != getProperty(GREEN_TIME)) {
    		setProperty(GREEN_TIME, greenTimeSet);
    	}
		if(soundSet != getProperty(SOUND)) {
    		setProperty(SOUND, soundSet);
    	}
		if(vibeSet != getProperty(VIBE)) {
    		setProperty(VIBE, vibeSet);
    	}
		if(testTypeSet != getProperty(TEST_TYPE)) {
    		setProperty(TEST_TYPE, testTypeSet);
    	}
		if(timerTimeSet != getProperty(TIMER_TIME)) {
    		setProperty(TIMER_TIME, timerTimeSet);
    	}
		if(autoStartSet != getProperty(AUTO_START)) {
    		setProperty(AUTO_START, autoStartSet);
    	}
		if(autoTimeSet != getProperty(AUTO_TIME)) {
    		setProperty(AUTO_TIME, autoTimeSet);
    	}
		if(bgColSet != getProperty(BG_COL)) {
    		setProperty(BG_COL, bgColSet);
    	}
		if(lblColSet != getProperty(LABEL_COL)) {
    		setProperty(LABEL_COL, lblColSet);
    	}
		if(txtColSet != getProperty(TEXT_COL)) {
    		setProperty(TEXT_COL, txtColSet);
    	}
		if(hrvColSet != getProperty(HRV_COL)) {
    		setProperty(HRV_COL, hrvColSet);
    	}
		if(avgHrvColSet != getProperty(AVG_HRV_COL)) {
    		 setProperty(AVG_HRV_COL, avgHrvColSet);
    	}
		if(pulseColSet != getProperty(PULSE_COL)) {
    		setProperty(PULSE_COL, pulseColSet);
    	}
		if(avgPulseColSet != getProperty(AVG_PULSE_COL)) {
    		setProperty(AVG_PULSE_COL, avgPulseColSet);
    	}

    	if(inhaleTimeSet != getProperty(INHALE_TIME)) {
    		setProperty(INHALE_TIME, inhaleTimeSet);
    	}
    	if(exhaleTimeSet != getProperty(EXHALE_TIME)) {
    		setProperty(EXHALE_TIME, exhaleTimeSet);
    	}
    	if(relaxTimeSet != getProperty(RELAX_TIME)) {
    		setProperty(RELAX_TIME, relaxTimeSet);
    	}

    	// Save results to memory
    	for(var i = 0; i < 30; i++) {
			var ii = i * 5;
			var result = getProperty(RESULTS + i);
			if(null == result || results[ii] != result[0]) {
				setProperty(RESULTS + i, [
					results[ii + 0],
					results[ii + 1],
					results[ii + 2],
					results[ii + 3],
					results[ii + 4]]);
			}
		}

		greenTimer.stop();
		viewTimer.stop();
		testTimer.stop();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        if(VIVOACTIVE == device) {
		 	return [ new VivoView(), new VivoDelegate() ];
		}
		return [ new TestView(), new HRVInputDelegate() ];
    }

    function onAntMsg(msg)
    {
		var payload = msg.getPayload();

        if( Ant.MSG_ID_BROADCAST_DATA == msg.messageId ) {

            isAntRx = true;
            isStrapRx = true;
            livePulse = payload[7].toNumber();
			var beatEvent = ((payload[4] | (payload[5] << 8)).toNumber() * 1000) / 1024;
			var beatCount = payload[6].toNumber();

			if(mPrevBeatCount != beatCount && 0 < livePulse) {

				isPulseRx = true;
				mNoPulseCount = 0;

				// Calculate estimated ranges for reliable data
				var maxMs = 60000 / (livePulse * 0.7);
				var minMs = 60000 / (livePulse * 1.4);

				// Get interval
				var intMs = 0;
				if(mPrevBeatEvent > beatEvent) {
					intMs = 64000 - mPrevBeatEvent + beatEvent;
				}
				else {
					intMs = beatEvent - mPrevBeatEvent;
				}
				// Only update hrv data if testing started, & values look to be error free
				if(isTesting && maxMs > intMs && minMs < intMs && maxMs > mPrevIntMs && minMs < mPrevIntMs) {

					var devMs = 0;
					if(intMs > mPrevIntMs) {
						devMs = intMs - mPrevIntMs;
					}
					else {
						devMs = mPrevIntMs - intMs;
					}
					devSqSum += devMs * devMs;
					pulseSum += livePulse;
					dataCount++;

					if(1 < dataCount) {
						var rmssd = Math.sqrt(devSqSum.toFloat() / (dataCount - 1));
						hrv = ((Math.log(rmssd, 1.0512712)) + 0.5).toNumber();
						avgPulse = ((pulseSum.toFloat() / dataCount) + 0.5).toNumber();
					}
				}
				mPrevIntMs = intMs;
			}
			else {
				mNoPulseCount += 1;
				if(0 < livePulse) {
					var limit = 1 + 60000 / livePulse / 246; // 246 = 4.06 KHz
					if(limit < mNoPulseCount) {
						isPulseRx = false;
					}
				}
			}
			mPrevBeatCount = beatCount;
			mPrevBeatEvent = beatEvent;
        }
        else if( Ant.MSG_ID_CHANNEL_RESPONSE_EVENT == msg.messageId ) {
            var event = payload[1].toNumber();
            if( Ant.MSG_CODE_EVENT_RX_FAIL == event ) {
				isStrapRx = false;
				isPulseRx = false;
            }
            else if( Ant.MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH == event ) {
				isAntRx = false;
            }
            else if( Ant.MSG_CODE_EVENT_RX_SEARCH_TIMEOUT == event ) {
				closeCh();
				openCh();
            }
        }
    }

    function openCh() {
        // Get the channel
        var chanAssign = new Ant.ChannelAssignment(
            Ant.CHANNEL_TYPE_RX_NOT_TX,
            Ant.NETWORK_PLUS);

        // Set the configuration
        var deviceCfg = new Ant.DeviceConfig( {
            :deviceNumber => 0,
            :deviceType => 120,
            :transmissionType => 0,
            :messagePeriod => 8070,
            :radioFrequency => 57,
            :searchTimeoutLowPriority => 2,
            :searchTimeoutHighPriority => 2,
            :searchThreshold => 0} );

        antCh = new Ant.GenericChannel(method(:onAntMsg), chanAssign);
        antCh.setDeviceConfig(deviceCfg);
		isChOpen = antCh.open();
    }

	// Close Ant channel.
    function closeCh() {
    	if(isChOpen) {
    		antCh.release();
    	}
    	isChOpen = false;
    	isAntRx = false;
		isStrapRx = false;
		isPulseRx = false;
    }

    function resetGreenTimer() {

		greenTimer.stop();
		greenTimer.start(method(:startGreenMode),greenTimeSet*1000,true);
    }

    function stopGreenTimer() {

    	greenTimer.stop();
    }

    function startGreenMode() {

    	if(!isTesting && isChOpen) {
    		closeCh();
    	}
    	if(WATCH_VIEW != viewNum) {
    		Ui.switchToView(getView(WATCH_VIEW), new HRVInputDelegate(), Ui.SLIDE_LEFT);
    	}
    }

    function timerFormat(time) {
    	var hour = time / 3600;
		var min = (time / 60) % 60;
		var sec = time % 60;
		if(0 < hour) {
			return format("$1$:$2$:$3$",[hour.format("%01d"),min.format("%02d"),sec.format("%02d")]);
		}
		else {
			return format("$1$:$2$",[min.format("%01d"),sec.format("%02d")]);
		}
    }

	function clockFormat(time)
	{
		var hour = (time / 3600) % 24;
		var min = (time / 60) % 60;
		var sec = time % 60;
		var meridiem = "";
		if(System.getDeviceSettings().is24Hour) {
			if(0 == time) {
				hour = 24;
			}
			else {
				hour = hour % 24;
			}
			return format("$1$$2$",[hour.format("%02d"),min.format("%02d")]);
		}
		else {
			if(12 > hour) {
				meridiem = "AM";
			}
			else {
				meridiem = "PM";
			}
			hour = 1 + (hour + 11) % 12;
			return format("$1$:$2$:$3$ $4$",[hour.format("%01d"),
				min.format("%02d"),sec.format("%02d"),meridiem]);
		}
	}

	function alert(type)
	{
    	if(soundSet) {
    		Attention.playTone(type);
    	}
    	if(vibeSet) {
    		Attention.vibrate([new Attention.VibeProfile(100,400)]);
    	}
    }

    function stopViewTimer() {

    	viewTimer.stop();
    	isMinutes = false;
	    isSeconds = false;
    }

    function updateMinutes() {

    	if(!isMinutes) {
	    	viewTimer.stop();
	    	var sec = System.getClockTime().sec;
			var ms;
			if(0 == sec) {
	    		ms = 60000;
	    	}
	    	else {
	    		ms = 60000 - sec * 1000;
	    	}
	    	viewTimer.start(method(:updateSynced),ms,false);
	    	isMinutes = true;
	    	isSeconds = false;
    	}
    	Ui.requestUpdate();
    }

    function updateSeconds() {

    	if(!isSeconds) {
    		viewTimer.stop();
    		viewTimer.start(method(:onViewTimer),1000,true);
    		isSeconds = true;
    		isMinutes = false;
    	}
    	Ui.requestUpdate();
    }

    function updateSynced() {

    	viewTimer.stop();
    	viewTimer.start(method(:onViewTimer),60000,true);
    	Ui.requestUpdate();
    }

    function onViewTimer() {

    	Ui.requestUpdate();
    }

    function timeNow() {

    	return (Time.now().value() + System.getClockTime().timeZoneOffset);
    }

    function timeToday() {

    	return (timeNow() - (timeNow() % 86400));
    }

    function plusView() {

    	var plusView = (viewNum + 1) % 4;
    	return getView(plusView);
    }

    function lastView() {

    	return getView(lastViewNum);
    }

    function subView() {

    	var subView = (viewNum + 7) % 4;
    	return getView(subView);
    }

    function getView(newViewNum) {

    	lastViewNum = viewNum;
		viewNum = newViewNum;

		if(RESULT_VIEW == viewNum) {
			return new ResultView();
		}
		else if(GRAPH_VIEW == viewNum) {
			return new GraphView();
		}
		else if(WATCH_VIEW == viewNum) {
			return new WatchView();
		}
		else {
			return new TestView();
		}
	}

}


