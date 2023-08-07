package h.lillie.reborntube.settings

import android.content.pm.PackageManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.ScrollView
import android.view.ViewGroup
import h.lillie.reborntube.R

class Settings : AppCompatActivity() {

    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.settings)
        getDeviceInfo()
        if (deviceType) {
            val settingsLayout: ScrollView = findViewById(R.id.settingsLayout)
            val params = settingsLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            settingsLayout.layoutParams = params
        }
    }

    override fun onStop() {
        super.onStop()
        if (deviceType) {
            finish()
        }
    }

    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
    }
}