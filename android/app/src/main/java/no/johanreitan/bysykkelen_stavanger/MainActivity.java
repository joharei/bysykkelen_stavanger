package no.johanreitan.bysykkelen_stavanger;

import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    drawUnderSystemUi();
  }

  @Override
  protected void onPostResume() {
    super.onPostResume();
    drawUnderSystemUi();
  }

  private void drawUnderSystemUi() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      Window window = getWindow();
      window.setStatusBarColor(0x22000000);
      window.setNavigationBarColor(0x22000000);
      int baseFlags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
          View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
          View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION;
      window.getDecorView().setSystemUiVisibility(baseFlags);

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        window.setNavigationBarColor(0x00000000);
        window.getDecorView().setSystemUiVisibility(baseFlags | View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR);
      }
    }
  }
}
