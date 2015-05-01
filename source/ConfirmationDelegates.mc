using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class SaveDelegate extends Ui.ConfirmationDelegate {

    function onResponse(value) {

        if(value) {

            App.getApp().saveTest();
        }
        else {

        	App.getApp().discardTest();
        }
    }
}

class SettingsDelegate extends Ui.ConfirmationDelegate {

    function onResponse(value) {

        if(value) {

            App.getApp().resetSettings();
        }
    }
}

class ResultsDelegate extends Ui.ConfirmationDelegate {

    function onResponse(value) {

        if(value) {

            App.getApp().resetResults();
        }
    }
}