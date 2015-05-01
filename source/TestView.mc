using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class TestView extends Ui.View {

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {

    	var app = Application.getApp();

    	app.updateSeconds();
    	app.resetGreenTimer();

    	if(app.isClosing) {
			app.onStop();
			//popView(SLIDE_IMMEDIATE);
			popView(SLIDE_RIGHT);
		}

		if(!app.isChOpen && !app.isWaiting) {
			app.openCh();
		}
    }

    //! Update the view
    function onUpdate(dc) {

    	var app = Application.getApp();

    	// Default layout settings
	    var titleFont = 4;		// Gfx.FONT_LARGE
	    var numFont = 5;		// Gfx.FONT_NUMBER_MILD
	    var titleY = 14;
	    var strapY = 33;
	    var pulseY = 49;
	    var pulseLblY = 13;
	    var pulseTxtY = 41;
	    var msgTxtY = 74;
	    var resLblY = 99;
	    var resTxtY = 127;
	    var line1Y = 60;
	    var line2Y = 90;
	    var col1 = 65;
	    var col2 = 102;
	    var col3 = 164;

		if(FORERUNNER == app.device) {
        	numFont = 6;		// Gfx.FONT_NUMBER_MEDIUM
			resLblY = 100;
			pulseLblY = 12;
	    	pulseTxtY = 40;
        }
        else if(FENIX == app.device) {
        	titleFont = 3;		// Gfx.FONT_MEDIUM
			titleY = 47;
			strapY = 67;
			pulseY = 83;
			pulseLblY = 50;
			pulseTxtY = 73;
			msgTxtY = 108;
			resLblY = 134;
			resTxtY = 157;
			line1Y = 94;
			line2Y = 124;
			col1 = 80;
			col2 = 109;
			col3 = 154;
        }

        var font = 1;		// Gfx.FONT_TINY
		var msgFont = 3;	// Gfx.FONT_MEDIUM
		var just = 5;		// Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER

    	// HRV
		var hrv = app.hrv;

		// Timer
		var timerTime = app.utcStop - app.utcStart;
		var testType = app.testTypeSet;

		if(TYPE_TIMER == testType) {

			timerTime = app.timerTimeSet;
		}
		else if(TYPE_AUTO == testType) {

			timerTime = app.autoTimeSet;
		}

		// Pulse
		var pulse = app.livePulse;

		// Message
    	var msgTxt;
    	var testTime = app.timeNow() - app.utcStart;

		if(app.isFinished) {

			pulse = app.avgPulse;

			testTime = app.utcStop - app.utcStart;

			if(MIN_SAMPLES > app.dataCount) {

				msgTxt = "Not enough data";
			}
			else if(app.isSaved) {

				msgTxt = "Result saved";
			}
			else {

				msgTxt = "Finished";
			}
    	}
    	else if(app.isTesting) {

    		//var cycleTime = (app.inhaleTimeSet + app.exhaleTimeSet + app.relaxTimeSet);
			var cycle = 1 + testTime % (app.inhaleTimeSet + app.exhaleTimeSet + app.relaxTimeSet);
			if(cycle <= app.inhaleTimeSet) {

				msgTxt = "Inhale through nose " + cycle;
			}
			else if(cycle <= app.inhaleTimeSet + app.exhaleTimeSet) {

				msgTxt = "Exhale out mouth " + (cycle - app.inhaleTimeSet);
			}
			else {

				msgTxt = "Relax " + (cycle - (app.inhaleTimeSet + app.exhaleTimeSet));
			}

			if(TYPE_MANUAL != testType) {

				timerTime -= testTime;
			}
			else {

				timerTime = testTime;
			}
    	}
    	else if(app.isWaiting) {

    		msgTxt = "Autostart in " + app.timerFormat(app.timeAutoStart - app.timeNow());
    	}
    	else if(app.isStrapRx) {

			if(TYPE_TIMER == testType) {

				msgTxt = "Timer test ready";
			}
			else if(TYPE_MANUAL == testType) {

				msgTxt = "Manual test ready";

			}
			else {

				msgTxt = "Schedule " + app.clockFormat(app.autoStartSet);
			}
    	}
    	else {
    		msgTxt = "Searching for HRM";
    	}

    	// Strap & pulse indicators
    	var strapCol = app.txtColSet;
    	var pulseCol = app.txtColSet;
    	var strapTxt = "STRAP";
    	var pulseTxt = "PULSE";

    	if(!app.isChOpen) {

			pulse = 0;
			strapTxt = "SAVING";
			pulseTxt = "BATTERY";
		}
		else if(!app.isStrapRx) {

	    		strapCol = RED;
	    		pulseCol = RED;
    	}
    	else {

    		strapCol = GREEN;
    		if(!app.isPulseRx) {

	    		pulseCol = RED;
	    	}
	    	else {

	    		pulseCol = GREEN;
	    	}
    	}

		// Draw the view
        dc.setColor(-1, app.bgColSet);
        dc.clear();

        dc.setColor(app.lblColSet, -1);
        dc.drawLine(0, line1Y, dc.getWidth(), line1Y);
		dc.drawLine(0, line2Y, dc.getWidth(), line2Y);
		dc.drawText(col1, titleY, titleFont, "HRV TEST", just);
		dc.drawText(col3, pulseLblY, font, "BPM", just);
		dc.drawText(col1, resLblY, font, "TIMER", just);
		dc.drawText(col3, resLblY, font, "HRV", just);

		dc.setColor(app.txtColSet, -1);
		dc.drawText(col3, pulseTxtY, numFont, pulse.toString(), just);
		dc.drawText(col2, msgTxtY, msgFont, msgTxt, just);
		dc.drawText(col1, resTxtY, numFont, app.timerFormat(timerTime), just);
		dc.drawText(col3, resTxtY, numFont, hrv.toString(), just);

		dc.setColor(strapCol, -1);
		dc.drawText(col1, strapY, font, strapTxt, just);

		dc.setColor(pulseCol, -1);
		dc.drawText(col1, pulseY, font, pulseTxt, just);

		// Testing only. Draw used memory
		//var str = System.getSystemStats().usedMemory.toString();
		//dc.setColor(WHITE, BLACK);
		//dc.drawText(dc.getWidth() / 2, 0, font, str, Gfx.TEXT_JUSTIFY_CENTER);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
    }

}