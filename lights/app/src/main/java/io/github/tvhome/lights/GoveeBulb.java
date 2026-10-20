package io.github.tvhome.lights;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import java.util.UUID;

/**
 * One Govee Bluetooth bulb, no pairing and no Wi-Fi. On first start it scans for 15 s and keeps the
 * strongest bulb whose name starts with "ihoment_H" (Govee's Bluetooth name). It then holds a standing
 * connection (autoConnect, so Android re-links on its own), which lets the scene start within about half
 * a second instead of waiting for a fresh connection.
 *
 * Protocol: 20-byte packets, the last byte the XOR of the first 19, written without response to the
 * 2b11 characteristic. Power is 33 01 01/00; colour is 33 05 0D R G B (the mode the H6008 accepts).
 */
final class GoveeBulb {

    private static final String TAG = "tvhome-lights";
    private static final String NAME_PREFIX = "ihoment_H";
    private static final UUID WRITE = UUID.fromString("00010203-0405-0607-0809-0a0b0c0d2b11");
    private static final long RED_MS = 3000;
    /** An idle link is dropped by the bulb after a while; a harmless state query keeps it up. */
    private static final long KEEPALIVE_MS = 2000;

    private final Context ctx;
    private final SharedPreferences prefs;
    private final HandlerThread thread = new HandlerThread("govee");
    private final Handler h;
    private final BluetoothAdapter adapter;
    private BluetoothGatt gatt;
    private BluetoothGattCharacteristic ch;

    GoveeBulb(Context ctx) {
        this.ctx = ctx.getApplicationContext();
        prefs = ctx.getSharedPreferences("bulb", Context.MODE_PRIVATE);
        thread.start();
        h = new Handler(thread.getLooper());
        BluetoothManager bm = (BluetoothManager) ctx.getSystemService(Context.BLUETOOTH_SERVICE);
        adapter = bm != null ? bm.getAdapter() : null;
    }

    private static byte[] packet(int... head) {
        byte[] p = new byte[20];
        for (int i = 0; i < head.length; i++) p[i] = (byte) head[i];
        byte x = 0;
        for (int i = 0; i < 19; i++) x ^= p[i];
        p[19] = x;
        return p;
    }

    private static final byte[] ON = packet(0x33, 0x01, 0x01);
    private static final byte[] OFF = packet(0x33, 0x01, 0x00);
    private static final byte[] NETFLIX_RED = packet(0x33, 0x05, 0x0D, 0xE5, 0x09, 0x14);
    private static final byte[] KEEPALIVE = packet(0xAA, 0x01);

    private final Runnable keepAlive = new Runnable() {
        @Override
        public void run() {
            send(KEEPALIVE);
            h.postDelayed(this, KEEPALIVE_MS);
        }
    };

    /** Finds the bulb on first run, then opens the standing link. */
    void start() {
        h.post(() -> {
            if (adapter == null || !adapter.isEnabled() || gatt != null) return;
            String mac = prefs.getString("mac", null);
            if (mac == null) {
                discover();
                return;
            }
            gatt = adapter.getRemoteDevice(mac).connectGatt(ctx, true, callback, BluetoothDevice.TRANSPORT_LE);
            h.removeCallbacks(keepAlive);
            h.post(keepAlive);
        });
    }

    private void discover() {
        BluetoothLeScanner scanner = adapter.getBluetoothLeScanner();
        if (scanner == null) return;
        final String[] best = {null};
        final int[] bestRssi = {Integer.MIN_VALUE};
        ScanCallback cb = new ScanCallback() {
            @Override
            public void onScanResult(int type, ScanResult r) {
                String name = r.getScanRecord() != null ? r.getScanRecord().getDeviceName() : null;
                if (name == null) name = r.getDevice().getName();
                if (name == null || !name.startsWith(NAME_PREFIX)) return;
                if (r.getRssi() > bestRssi[0]) {
                    bestRssi[0] = r.getRssi();
                    best[0] = r.getDevice().getAddress();
                }
            }
        };
        try {
            scanner.startScan(null, new ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build(), cb);
        } catch (RuntimeException e) {
            Log.w(TAG, "scan failed", e);
            return;
        }
        h.postDelayed(() -> {
            try { scanner.stopScan(cb); } catch (RuntimeException ignored) { }
            if (best[0] == null) {
                Log.w(TAG, "no Govee bulb found; retrying in 60 s");
                h.postDelayed(this::start, 60_000);
                return;
            }
            Log.i(TAG, "using bulb " + best[0] + " (rssi " + bestRssi[0] + ")");
            prefs.edit().putString("mac", best[0]).apply();
            start();
        }, 15_000);
    }

    private final BluetoothGattCallback callback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt g, int status, int state) {
            if (state == BluetoothProfile.STATE_CONNECTED) {
                g.discoverServices();
            } else if (state == BluetoothProfile.STATE_DISCONNECTED) {
                h.post(() -> ch = null);
                // autoConnect brings it back when it can; a failed link (often status 133) gets a fresh one.
                if (status != BluetoothGatt.GATT_SUCCESS) {
                    h.postDelayed(() -> {
                        if (gatt != null) gatt.close();
                        gatt = null;
                        start();
                    }, 3000);
                }
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt g, int status) {
            BluetoothGattCharacteristic c = null;
            for (BluetoothGattService s : g.getServices()) {
                if (c == null) c = s.getCharacteristic(WRITE);
            }
            if (c != null) c.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);
            BluetoothGattCharacteristic found = c;
            h.post(() -> ch = found);
            Log.i(TAG, "bulb linked: " + (c != null));
        }
    };

    private void send(byte[] value) {
        if (gatt == null || ch == null) return;
        ch.setValue(value);
        gatt.writeCharacteristic(ch);
    }

    /** Netflix opened: on, Netflix red, then off. */
    void netflixScene() {
        h.post(() -> {
            if (ch == null) {
                Log.w(TAG, "netflix opened, bulb not linked yet");
                start();
                return;
            }
            send(ON);
            h.postDelayed(() -> send(NETFLIX_RED), 150);
            h.postDelayed(() -> send(OFF), 150 + RED_MS);
        });
    }

    void shutdown() {
        h.post(() -> {
            h.removeCallbacksAndMessages(null);
            if (gatt != null) {
                gatt.disconnect();
                gatt.close();
                gatt = null;
            }
            thread.quitSafely();
        });
    }
}
