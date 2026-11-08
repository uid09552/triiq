package com.triiq.triiq

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var oauthChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        oauthChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "triiq/oauth")
    }

    // "Log in with Intervals.icu": the browser comes back to
    // triiq://oauth/callback?code=...&state=... while the app is running
    // (launchMode singleTop), so the address arrives here and goes to Dart.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val data = intent.data
        if (data != null && data.scheme == "triiq" && data.host == "oauth") {
            oauthChannel?.invokeMethod("callback", data.toString())
        }
    }
}
