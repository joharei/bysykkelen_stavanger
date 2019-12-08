package no.johanreitan.bysykkelen_stavanger

import android.os.Build
import android.os.Bundle
import android.view.View
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        drawUnderSystemUi()
    }

    override fun onPostResume() {
        super.onPostResume()
        drawUnderSystemUi()
    }

    private fun drawUnderSystemUi() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = 0x00000000
            val baseFlags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                    View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            window.decorView.systemUiVisibility = baseFlags

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                window.decorView.systemUiVisibility = baseFlags or
                        View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR or
                        View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
            }
        }
    }
}
