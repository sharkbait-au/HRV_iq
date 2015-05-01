using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class ColorListMenuDelegate extends Ui.MenuInputDelegate {

    hidden var mFunc;

    function initialize(func) {

		mFunc = func;
    }

    function onMenuItem(item) {

        if(item == :MiBlack) {

            mFunc.invoke(BLACK);
        }
        else if(item == :MiWhite) {

			mFunc.invoke(WHITE);
        }
        else if(item == :MiBlue) {

            mFunc.invoke(BLUE);
        }
        else if(item == :MiDkBlue) {

            mFunc.invoke(DK_BLUE);
        }
        else if(item == :MiRed) {

            mFunc.invoke(RED);
        }
        else if(item == :MiDkRed) {

            mFunc.invoke(DK_RED);
        }
        else if(item == :MiLtGray) {

            mFunc.invoke(LT_GRAY);
        }
        else if(item == :MiDkGray) {

            mFunc.invoke(DK_GRAY);
        }
        else if(item == :MiGreen) {

            mFunc.invoke(GREEN);
        }
        else if(item == :MiDkGreen) {

            mFunc.invoke(DK_GREEN);
        }
        else if(item == :MiOrange) {

            mFunc.invoke(ORANGE);
        }
        else if(item == :MiYellow) {

            mFunc.invoke(YELLOW);
        }
        else if(item == :MiPink) {

            mFunc.invoke(PINK);
        }
        else if(item == :MiPurple) {

            mFunc.invoke(PURPLE);
        }
    }
}