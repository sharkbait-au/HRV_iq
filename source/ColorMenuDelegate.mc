using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class ColorMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {

        if(item == :MiBackground) {

			Ui.pushView(new Rez.Menus.BackgroundMenu(), new ChoiceMenuDelegate(method(:setBackground)), Ui.SLIDE_IMMEDIATE);
        }
        else if(item == :MiLabel) {

            Ui.pushView(new Rez.Menus.ColorListMenu(), new ColorListMenuDelegate(method(:setLabel)), Ui.SLIDE_IMMEDIATE);
        }
        else if(item == :MiText) {

            Ui.pushView(new Rez.Menus.ColorListMenu(), new ColorListMenuDelegate(method(:setText)), Ui.SLIDE_IMMEDIATE);
        }
    }

    function setBackground(value) {

    	var app = App.getApp();

    	if(value) {

    		app.bgColSet = WHITE;

    		if(WHITE == app.txtColSet) {

	    		app.txtColSet = BLACK;
	    	}
    	}
    	else {

    		app.bgColSet = BLACK;

    		if(BLACK == app.txtColSet) {

	    		app.txtColSet = WHITE;
	    	}
    	}
    }

    function setLabel(value) {

    	var app = App.getApp();
		app.lblColSet = value;
    }

    function setText(value) {

    	var app = App.getApp();
		app.txtColSet = value;
    }
}