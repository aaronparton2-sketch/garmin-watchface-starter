import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// -----------------------------------------------------------------------------
// StarterApp: the entry point. Garmin starts here.
//
// You rarely need to touch this file. All the drawing happens in
// StarterView.mc, which is the file to change (or ask Claude to change).
// -----------------------------------------------------------------------------
class StarterApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    // The first (and only) screen of the watch face.
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [new StarterView()];
    }

    // Runs when you change a setting in the Connect IQ phone app.
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }
}
