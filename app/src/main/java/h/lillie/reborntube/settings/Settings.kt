package h.lillie.reborntube.settings

import android.os.Bundle
import android.content.Intent
import android.content.pm.PackageManager
import androidx.appcompat.app.AppCompatActivity
import android.widget.ScrollView
import android.widget.TableLayout
import android.widget.TableRow
import android.view.View
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

        val settingsTableLayout: TableLayout = findViewById(R.id.settingsTableLayout)
        if (deviceType) {
            settingsTableLayout.setBackgroundColor(applicationContext.getColor(R.color.darkgrey))
        } else if (!deviceType) {
            settingsTableLayout.setBackgroundColor(applicationContext.getColor(R.color.black))
        }

        val themeSettingsRow: TableRow = findViewById(R.id.themeSettingsRow)
        if (deviceType) {
            themeSettingsRow.setBackgroundResource(R.drawable.tvbutton)
        }
        themeSettingsRow.setOnClickListener {}
        themeSettingsRow.requestFocus()

        val backgroundModeSettingsRow: TableRow = findViewById(R.id.backgroundModeSettingsRow)
        if (deviceType) {
            backgroundModeSettingsRow.visibility = View.GONE
        }
        backgroundModeSettingsRow.setOnClickListener {
            startActivity(Intent(this@Settings, BackgroundModeSettings::class.java))
        }

        val sponsorBlockSettingsRow: TableRow = findViewById(R.id.sponsorBlockSettingsRow)
        if (deviceType) {
            sponsorBlockSettingsRow.setBackgroundResource(R.drawable.tvbutton)
        }
        sponsorBlockSettingsRow.setOnClickListener {
            startActivity(Intent(this@Settings, SponsorBlockSettings::class.java))
        }

        val enableCaptionsSwitch: SwitchMaterial = findViewById(R.id.enableCaptionsSwitch)
        val preferences = getSharedPreferences("RTSettings", 0)
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

        val clearHistorySettingsRow: TableRow = findViewById(R.id.clearHistorySettingsRow)
        if (deviceType) {
            clearHistorySettingsRow.setBackgroundResource(R.drawable.tvbutton)
        }
        clearHistorySettingsRow.setOnClickListener {}

        val creditsSettingsRow: TableRow = findViewById(R.id.creditsSettingsRow)
        if (deviceType) {
            creditsSettingsRow.setBackgroundResource(R.drawable.tvbutton)
        }
        creditsSettingsRow.setOnClickListener {}

        val opensourceLibrariesSettingsRow: TableRow = findViewById(R.id.opensourceLibrariesSettingsRow)
        if (deviceType) {
            opensourceLibrariesSettingsRow.setBackgroundResource(R.drawable.tvbutton)
        }
        opensourceLibrariesSettingsRow.setOnClickListener {}
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