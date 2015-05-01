using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class GraphView extends Ui.View {

	hidden var floorVar;
	hidden var scaleVar;

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {

    	var app = App.getApp();
    	app.resetGreenTimer();
		app.updateMinutes();
    }

    function scale(num) {

		return (((num - floorVar) * scaleVar) + 0.5).toNumber();
	}

    //! Update the view
    function onUpdate(dc) {

		var app = App.getApp();

		var today = (app.timeToday() / 86400) % 30;	// Todays index
		var epoch = app.timeToday() - (86400 * 29);	// Index 29 days ago

		// REMOVE FOR PUBLISH
		//today = (app.timeNow() / 3600) % 30;	// Todays index
		//epoch = app.timeNow() - (3600 * 29);	// Index 29 days ago
		// REMOVE FOR PUBLISH
		//today = (app.timeNow() / 60) % 30;	// Todays index
		//epoch = app.timeNow() - (60 * 29);	// Index 29 days ago

		var dataCount = 0;
		var max = 0;
		var min = 310;

		// Find result limits
		for(var i = 0; i < 30; i++) {

			var ii = i * 5;

			// Only process if newer than epoch
			if(epoch <= app.results[ii]) {

				// Get range
				for(var iii = 1; iii <= 4; iii++) {

					var value = app.results[ii + iii];

					if(min > value) {
						min = value;
					}
					if(max < value) {
						max = value;
					}
				}

				dataCount++;
			}
		}

		// If no results then set min & max to create a nice graph scale
		if(0 == dataCount){
			min = -5;
			max = 5;
		}

		// Create the range
		var ceil = (max + 5) - (max % 5);
		var floor = min - (min % 5);

		var range = ceil - floor;
		var toggle = 0;
		while(0 != range % 15) {
			if(1 == toggle % 2) {
				ceil += 5;
			}
			else {
				floor -= 5;
			}
			range = ceil - floor;
			toggle++;
		}
		var scaleY = 90 / range.toFloat();

		floorVar = floor;
		scaleVar = scaleY;

		var font = 0; 	// Gfx.FONT_XTINY;
		var just = 5;	// Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER;
		var ctrX = dc.getWidth() / 2;
		var ctrY = dc.getHeight() / 2;
		var leftX = ctrX - 90;
		var rightX = ctrX + 90;
		var ceilY = ctrY - 45;
		var floorY = ctrY + 45;
		var textX = leftX + 20;
		var gap = (ceil - floor) / 3;
	    var line1Y = 60;
	    var line2Y = 90;

	    if(FENIX == app.device) {
			line1Y = 94;
			line2Y = 124;
		}

		// Prepare te screen
		dc.setColor(-1, app.bgColSet);
		dc.clear();

		// Draw the lines
		dc.setColor(DK_GRAY, app.bgColSet);
		for(var i = 0; i < 7; i++) {

			var y = line1Y - 30 + i * 15;
			dc.drawLine(leftX, y, rightX, y);
		}
		dc.setColor(app.lblColSet, -1);
        dc.drawLine(0, line1Y, dc.getWidth(), line1Y);
		dc.drawLine(0, line2Y, dc.getWidth(), line2Y);


		// Draw the numbers
		dc.setColor(DK_GRAY, app.bgColSet);
		for(var i = 1; i < 6; i += 2) {

			var y = ceilY + (((i * gap) * scaleY) / 2);
			var num = ceil - ((i * gap) / 2.0);
			if(num != num.toNumber()) {
				dc.drawText(textX + 35, y, font, format(" $1$ ",[num.format("%-0.1f")]), just);
			}
			else {
				dc.drawText(textX + 35, y, font, format(" $1$ ",[num.format("%-d")]), just);
			}
		}
		for(var i = 0; i < 7; i += 2) {

			var y = ceilY + (((i * gap) * scaleY) / 2);
			var str = format(" $1$ ",[(ceil - ((i * gap)/2)).format("%-d")]);
			dc.drawText(textX, y, font, str, just);
		}

		// Draw the data
		var drawDots = 0;

		for(var i = 0; i < 30; i++) {

			// Start 30 days ago and work forwards
 			var ii = ((today + 1 + i) % 30) * 5;

			if(epoch < app.results[ii]) {

				var index1 = i * 6 + 3;
	 			var hrv1 = scale(app.results[ii + 1]);
	 			var pulse1 = scale(app.results[ii + 2]);
	 			var avgHrv1 = scale(app.results[ii + 3]);
	 			var avgPulse1 = scale(app.results[ii + 4]);
	 			drawDots++;

	 			for(var iii = i + 1; iii < 30; iii++) {

					var iiii = ((today + 1 + iii) % 30) * 5;

		 			if(epoch < app.results[iiii]) {

			 			var index2 = iii * 6 + 3;
			 			var hrv2 = scale(app.results[iiii + 1]);
			 			var pulse2 = scale(app.results[iiii + 2]);
			 			var avgHrv2 = scale(app.results[iiii + 3]);
			 			var avgPulse2 = scale(app.results[iiii + 4]);

						dc.setPenWidth(2);
						dc.setColor(DK_RED, app.bgColSet);
						dc.drawLine(leftX + index1, floorY - avgPulse1, leftX + index2, floorY - avgPulse2);

						dc.setColor(DK_BLUE, app.bgColSet);
						dc.drawLine(leftX + index1, floorY - avgHrv1, leftX + index2, floorY - avgHrv2);

						dc.setPenWidth(3);
						dc.setColor(ORANGE, app.bgColSet);
						dc.drawLine(leftX + index1, floorY - pulse1, leftX + index2, floorY - pulse2);

						dc.setColor(BLUE, app.bgColSet);
						dc.drawLine(leftX + index1, floorY - hrv1, leftX + index2, floorY - hrv2);

						// Change the value of i. So that it starts back at this point. Break loop
						i = iii - 1;
						iii = 30;
						drawDots++;
					}
				}
				// If only one reading then draw dots. There are no averages
				if(1 == drawDots) {

					dc.setColor(ORANGE, app.bgColSet);
					dc.fillCircle(leftX + index1, floorY - pulse1, 2);

					dc.setColor(BLUE, app.bgColSet);
					dc.fillCircle(leftX + index1, floorY - hrv1, 2);
				}
			}
		}

		// Draw the labels
		dc.setPenWidth(1);

		dc.setColor(DK_RED, app.bgColSet);
		dc.drawText(ctrX, floorY + 20, font, " AVG PULSE", 6);

		dc.setColor(ORANGE, app.bgColSet);
		dc.drawText(ctrX, ceilY - 20, font, " PULSE", 6);

		dc.setColor(DK_BLUE, app.bgColSet);
		dc.drawText(ctrX, floorY + 20, font, "AVG HRV ", 4);

		dc.setColor(BLUE, app.bgColSet);
		dc.drawText(ctrX, ceilY - 20, font, "HRV ", 4);

		// Testing only. Draw used memory
		//var str = System.getSystemStats().usedMemory.toString();
		//dc.setColor(WHITE, BLACK);
		//dc.drawText(dc.getWidth() / 2, 0, font, str, Gfx.TEXT_JUSTIFY_CENTER);

    }
}