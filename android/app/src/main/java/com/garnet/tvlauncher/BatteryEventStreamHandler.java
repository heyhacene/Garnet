package com.garnet.tvlauncher;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class BatteryEventStreamHandler implements EventChannel.StreamHandler {
    private final Context _context;
    private final Handler _handler;
    private BroadcastReceiver _batteryReceiver;

    public BatteryEventStreamHandler(Context context) {
        _context = context.getApplicationContext();
        _handler = new Handler(Looper.getMainLooper());
    }

    public static Map<String, Object> extractBatteryInfo(Intent intent) {
        Map<String, Object> info = new HashMap<>();
        if (intent == null) {
            info.put("present", false);
            info.put("level", -1);
            info.put("charging", false);
            return info;
        }

        boolean present = intent.getBooleanExtra(BatteryManager.EXTRA_PRESENT, false);
        int rawLevel = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        int scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        int level = (rawLevel >= 0 && scale > 0) ? Math.round((rawLevel * 100f) / scale) : -1;

        int status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
        boolean charging = status == BatteryManager.BATTERY_STATUS_CHARGING
                || status == BatteryManager.BATTERY_STATUS_FULL;

        info.put("present", present);
        info.put("level", level);
        info.put("charging", charging);
        return info;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        _batteryReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                Map<String, Object> info = extractBatteryInfo(intent);
                _handler.post(() -> events.success(info));
            }
        };

        IntentFilter filter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent sticky;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            sticky = _context.registerReceiver(_batteryReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
        } else {
            sticky = _context.registerReceiver(_batteryReceiver, filter);
        }

        if (sticky != null) {
            Map<String, Object> info = extractBatteryInfo(sticky);
            _handler.post(() -> events.success(info));
        }
    }

    @Override
    public void onCancel(Object arguments) {
        if (_batteryReceiver != null) {
            try {
                _context.unregisterReceiver(_batteryReceiver);
            } catch (IllegalArgumentException ignored) {
            }
            _batteryReceiver = null;
        }
    }
}
