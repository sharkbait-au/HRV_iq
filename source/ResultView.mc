using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class ResultView extends Ui.View {

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {

    	var app = App.getApp();
    	app.updateSeconds();
    	app.resetGreenTimer();
    }

    //! Update the view
    function onUpdate(dc) {

    	var app = App.getApp();

    	// Default layout settings
	    var font = 3;		// Gfx.FONT_MEDIUM
	    var timeY = 14;
	    var pulseY = 44;
	    var hrvY = 74;
	    var samplesY = 104;
	    var expectedY = 134;
	    var line1Y = 60;
	    var line2Y = 90;
	    var col1 = 105;
	    var col2 = 111;

		if(FENIX == app.device) {
        	font = 1;		// Gfx.FONT_TINY
		    timeY = 48;
		    pulseY = 78;
		    hrvY = 108;
		    samplesY = 138;
		    expectedY = 168;
		    line1Y = 94;
		    line2Y = 124;
		    col1 = 111;
		    col2 = 115;
        }

		var justL = 6;		// Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER
		var justR = 4;		// Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER

		var time = 0;
		var pulse = 0;
		var expected = 0;

		if(app.isTesting) {
			time = app.timeNow() - app.utcStart;
		}
		else if(app.isFinished) {
			time = app.utcStop - app.utcStart;
		}
		expected = (((1 + time) / 60.0) * app.avgPulse).toNumber();

    	// Draw the view
        dc.setColor(-1, app.bgColSet);
        dc.clear();

        dc.setColor(app.lblColSet, -1);
        dc.drawLine(0, line1Y, dc.getWidth(), line1Y);
		dc.drawLine(0, line2Y, dc.getWidth(), line2Y);
		dc.drawText(col1, timeY, font, "Time :", justR);
		dc.drawText(col1, pulseY, font, "Avg pulse :", justR);
		dc.drawText(col1, hrvY, font, "HRV :", justR);
		dc.drawText(col1, samplesY, font, "Samples :", justR);
		dc.drawText(col1, expectedY, font, "Expected :", justR);

		dc.setColor(app.txtColSet, -1);
		dc.drawText(col2, timeY, font, app.timerFormat(time), justL);
		dc.drawText(col2, pulseY, font, app.avgPulse.toString(), justL);
		dc.drawText(col2, hrvY, font, app.hrv.toString(), justL);
		dc.drawText(col2, samplesY, font, app.dataCount.toString(), justL);
		dc.drawText(col2, expectedY, font, expected.toString(), justL);

		// Testing only. Draw used memory
		//var str = System.getSystemStats().usedMemory.toString();
		//dc.setColor(WHITE, BLACK);
		//dc.drawText(0, 100, font, str, Gfx.TEXT_JUSTIFY_LEFT);

    }

    function onHide() {
    }
}