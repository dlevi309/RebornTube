package h.lillie.reborntube.settings

import android.os.Bundle
import android.content.pm.PackageManager
import androidx.appcompat.app.AppCompatActivity
import android.widget.ScrollView
import android.widget.CheckBox
import android.widget.TableRow
import android.view.View
import android.view.ViewGroup
import h.lillie.reborntube.R

class BackgroundModeSettings : AppCompatActivity() {

    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.backgroundmodesettings)
        getDeviceInfo()
        if (deviceType) {
            val backgroundModeSettingsLayout: ScrollView = findViewById(R.id.backgroundModeSettingsLayout)
            val params = backgroundModeSettingsLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            backgroundModeSettingsLayout.layoutParams = params
        }

        if (android.os.Build.VERSION.SDK_INT < 31) {
            val pipTableRow: TableRow = findViewById(R.id.pipTableRow)
            pipTableRow.visibility = View.GONE
        }

        val preferences = getSharedPreferences("RTSettings", 0)

        val noneCheckBox: CheckBox = findViewById(R.id.noneCheckBox)
        val bgPlaybackCheckBox: CheckBox = findViewById(R.id.bgPlaybackCheckBox)
        val pipCheckBox: CheckBox = findViewById(R.id.pipCheckBox)

        val backgroundMode: Int = preferences.getInt("RTBackgroundMode", 0)
        if (backgroundMode == 0) {
            noneCheckBox.isChecked = true
            bgPlaybackCheckBox.isChecked = false
            pipCheckBox.isChecked = false
        } else if (backgroundMode == 1) {
            noneCheckBox.isChecked = false
            bgPlaybackCheckBox.isChecked = true
            pipCheckBox.isChecked = false
        } else if (backgroundMode == 2) {
            noneCheckBox.isChecked = false
            bgPlaybackCheckBox.isChecked = false
            pipCheckBox.isChecked = true
        }
        noneCheckBox.setOnClickListener {
            noneCheckBox.isChecked = true
            bgPlaybackCheckBox.isChecked = false
            pipCheckBox.isChecked = false
            preferences.edit().putInt("RTBackgroundMode", 0).apply()
        }
        bgPlaybackCheckBox.setOnClickListener {
            noneCheckBox.isChecked = false
            bgPlaybackCheckBox.isChecked = true
            pipCheckBox.isChecked = false
            preferences.edit().putInt("RTBackgroundMode", 1).apply()
        }
        pipCheckBox.setOnClickListener {
            noneCheckBox.isChecked = false
            bgPlaybackCheckBox.isChecked = false
            pipCheckBox.isChecked = true
            preferences.edit().putInt("RTBackgroundMode", 2).apply()
        }
    }

    override fun onStop() {
        super.onStop()
        if (deviceType) {
            finish()
        }
    }

    private fun getDeviceInfo() {
        deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
    }
}