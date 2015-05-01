using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class ChoiceMenuDelegate extends Ui.MenuInputDelegate {

    hidden var mFunc;

    function initialize(func) {

		mFunc = func;
    }

    function onMenuItem(item) {

        if(item == :MiZero) {

            mFunc.invoke(0);
        }
        else if(item == :MiOne) {

            mFunc.invoke(1);
        }
    }
}