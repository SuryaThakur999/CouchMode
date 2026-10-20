package io.github.tvhome.lights;

import android.accessibilityservice.AccessibilityService;
import android.os.SystemClock;
import android.view.accessibility.AccessibilityEvent;

/**
 * Watches which app comes to the front and runs the bulb scene once when Netflix opens.
 * Event driven: nothing runs until a window changes, so it costs no CPU while idle.
 */
public class LightsService extends AccessibilityService {

    private static final long COOLDOWN_MS = 15_000;

    private boolean inNetflix;
    private long lastRun = -COOLDOWN_MS;
    private GoveeBulb bulb;

    /** Netflix's TV build and its phone build (found on projectors with a tablet Android). */
    private static boolean isNetflix(String pkg) {
        return "com.netflix.ninja".equals(pkg) || "com.netflix.mediaclient".equals(pkg);
    }

    /** Overlays that sit on top of the current app without leaving it. */
    private static boolean isOverlay(String pkg) {
        return pkg.equals("com.android.systemui") || pkg.equals("android")
                || pkg.startsWith("com.google.android.inputmethod") || pkg.equals("com.google.android.katniss");
    }

    @Override
    protected void onServiceConnected() {
        bulb = new GoveeBulb(this);
        bulb.start();
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getEventType() != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED || event.getPackageName() == null) return;
        String pkg = event.getPackageName().toString();
        if (isOverlay(pkg)) return;
        boolean netflix = isNetflix(pkg);
        long now = SystemClock.elapsedRealtime();
        if (netflix && !inNetflix && now - lastRun > COOLDOWN_MS) {
            lastRun = now;
            bulb.netflixScene();
        }
        inNetflix = netflix;
    }

    @Override
    public void onInterrupt() {
    }

    @Override
    public void onDestroy() {
        if (bulb != null) bulb.shutdown();
        super.onDestroy();
    }
}
