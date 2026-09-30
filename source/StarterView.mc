import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// -----------------------------------------------------------------------------
// StarterView: everything you see on the watch face is drawn here.
//
// The watch calls onUpdate() about once a minute (every second for a moment
// after you raise your wrist). Each time, we wipe the screen and draw:
//
//        DATE              <- top
//        12:34             <- the big time
//        -- accent line --
//   steps   battery   heart rate   <- bottom row
//
// Want something different? Tell Claude what you want to see and where.
// Positions are fractions of the screen (0.5 = middle), so it fits any size.
// -----------------------------------------------------------------------------
class StarterView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var accent = accentColour();

        // 1. Background: black is best for battery on AMOLED screens.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // 2. The date, e.g. "WED 30 SEP".
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var date = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.day, info.month]).toUpper();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.20, Graphics.FONT_SMALL, date, Graphics.TEXT_JUSTIFY_CENTER);

        // 3. The time, big and white. Respects the watch's 12/24-hour setting.
        var clock = System.getClockTime();
        var hour = clock.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var time = Lang.format("$1$:$2$", [hour, clock.min.format("%02d")]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.47, Graphics.FONT_NUMBER_THAI_HOT, time,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 4. A thin accent line under the time.
        dc.setColor(accent, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(w * 0.30, h * 0.64, w * 0.70, h * 0.64);

        // 5. Bottom row: steps, battery, heart rate.
        drawStat(dc, w * 0.25, h * 0.70, "STEPS", stepsText(), accent);
        drawStat(dc, w * 0.50, h * 0.70, "BATT", batteryText(), accent);
        drawStat(dc, w * 0.75, h * 0.70, "HR", heartRateText(), accent);
    }

    // A small label with a value underneath it.
    function drawStat(dc as Dc, x as Numeric, y as Numeric, label as String, value as String, accent as Number) as Void {
        dc.setColor(accent, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + dc.getFontHeight(Graphics.FONT_XTINY), Graphics.FONT_TINY, value, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Steps so far today.
    function stepsText() as String {
        var steps = ActivityMonitor.getInfo().steps;
        return steps == null ? "--" : steps.toString();
    }

    // Battery percentage.
    function batteryText() as String {
        return System.getSystemStats().battery.format("%d") + "%";
    }

    // Latest heart rate the watch has, or "--" if it hasn't got one.
    function heartRateText() as String {
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr == null) {
            var sample = ActivityMonitor.getHeartRateHistory(1, true).next();
            if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                hr = sample.heartRate;
            }
        }
        return hr == null ? "--" : hr.toString();
    }

    // The accent colour, chosen by the user in the Connect IQ app settings.
    function accentColour() as Number {
        var choice = Application.Properties.getValue("accentColour");
        if (choice == 1) { return Graphics.COLOR_BLUE; }
        if (choice == 2) { return Graphics.COLOR_GREEN; }
        if (choice == 3) { return Graphics.COLOR_ORANGE; }
        return Graphics.COLOR_RED;
    }
}
