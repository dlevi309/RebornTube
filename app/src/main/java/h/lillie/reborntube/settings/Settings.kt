package h.lillie.reborntube.settings

import android.os.Bundle
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.appcompat.app.AppCompatActivity
import android.widget.ScrollView
import android.widget.TableRow
import android.view.ViewGroup
import com.google.android.material.switchmaterial.SwitchMaterial
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

        val backgroundModeSettingsRow: TableRow = findViewById(R.id.backgroundModeSettingsRow)
        backgroundModeSettingsRow.setOnClickListener {
            startActivity(Intent(this@Settings, BackgroundModeSettings::class.java))
        }

        val sponsorBlockSettingsRow: TableRow = findViewById(R.id.sponsorBlockSettingsRow)
        sponsorBlockSettingsRow.setOnClickListener {
            startActivity(Intent(this@Settings, SponsorBlockSettings::class.java))
        }

        val enableCaptionsSwitch: SwitchMaterial = findViewById(R.id.enableCaptionsSwitch)
        val preferences = getSharedPreferences("RTSettings", Context.MODE_PRIVATE)
        val enableCaptions: Boolean = preferences.getBoolean("RTEnableCaptions", false)
        if (!enableCaptions) {
            enableCaptionsSwitch.isChecked = false
        } else if (enableCaptions) {
            enableCaptionsSwitch.isChecked = true
        }
        enableCaptionsSwitch.setOnCheckedChangeListener { _, isChecked ->
            if (!isChecked) {
                preferences.edit().putBoolean("RTEnableCaptions", false).apply()
            } else if (isChecked) {
                preferences.edit().putBoolean("RTEnableCaptions", true).apply()
            }
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