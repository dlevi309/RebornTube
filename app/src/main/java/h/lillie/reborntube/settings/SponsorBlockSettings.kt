package h.lillie.reborntube.settings

import android.os.Bundle
import android.content.pm.PackageManager
import android.content.Context
import android.content.res.ColorStateList
import androidx.appcompat.app.AppCompatActivity
import android.widget.ScrollView
import android.widget.Button
import android.view.ViewGroup
import h.lillie.reborntube.R

class SponsorBlockSettings : AppCompatActivity() {

    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.sponsorblocksettings)
        getDeviceInfo()
        if (deviceType) {
            val sponsorBlockSettingsLayout: ScrollView = findViewById(R.id.sponsorBlockSettingsLayout)
            val params = sponsorBlockSettingsLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            sponsorBlockSettingsLayout.layoutParams = params
        }

        val preferences = getSharedPreferences("RTSettings", Context.MODE_PRIVATE)

        val sourceMainButton: Button = findViewById(R.id.sourceMainButton)
        val sourceMirrorButton: Button = findViewById(R.id.sourceMirrorButton)
        val sponsorBlockSource: Int = preferences.getInt("RTSponsorBlockSource", 0)
        if (sponsorBlockSource == 0) {
            sourceMainButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            sourceMirrorButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (sponsorBlockSource == 1) {
            sourceMainButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sourceMirrorButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
        }
        sourceMainButton.setOnClickListener {
            sourceMainButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            sourceMirrorButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockSource", 0).apply()
        }
        sourceMirrorButton.setOnClickListener {
            sourceMainButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sourceMirrorButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            preferences.edit().putInt("RTSponsorBlockSource", 1).apply()
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