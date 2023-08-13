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

        // Source
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

        // Sponsor
        val sponsorDisableButton: Button = findViewById(R.id.sponsorDisableButton)
        val sponsorAutoSkipButton: Button = findViewById(R.id.sponsorAutoSkipButton)
        val sponsorManualSkipButton: Button = findViewById(R.id.sponsorManualSkipButton)
        val sponsorBlockSponsor: Int = preferences.getInt("RTSponsorBlockSponsor", 0)
        if (sponsorBlockSponsor == 0) {
            sponsorDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            sponsorAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sponsorManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (sponsorBlockSponsor == 1) {
            sponsorDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sponsorAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            sponsorManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (sponsorBlockSponsor == 2) {
            sponsorDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sponsorAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sponsorManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
        }
        sponsorDisableButton.setOnClickListener {
            sponsorDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            sponsorAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sponsorManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockSponsor", 0).apply()
        }
        sponsorAutoSkipButton.setOnClickListener {
            sponsorDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sponsorAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            sponsorManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockSponsor", 1).apply()
        }
        sponsorManualSkipButton.setOnClickListener {
            sponsorDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sponsorAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            sponsorManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            preferences.edit().putInt("RTSponsorBlockSponsor", 2).apply()
        }

        // Selfpromo
        val selfpromoDisableButton: Button = findViewById(R.id.selfpromoDisableButton)
        val selfpromoAutoSkipButton: Button = findViewById(R.id.selfpromoAutoSkipButton)
        val selfpromoManualSkipButton: Button = findViewById(R.id.selfpromoManualSkipButton)
        val selfpromoBlockSelfpromo: Int = preferences.getInt("RTSponsorBlockSelfpromo", 0)
        if (selfpromoBlockSelfpromo == 0) {
            selfpromoDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            selfpromoAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            selfpromoManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (selfpromoBlockSelfpromo == 1) {
            selfpromoDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            selfpromoAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            selfpromoManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (selfpromoBlockSelfpromo == 2) {
            selfpromoDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            selfpromoAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            selfpromoManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
        }
        selfpromoDisableButton.setOnClickListener {
            selfpromoDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            selfpromoAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            selfpromoManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockSelfpromo", 0).apply()
        }
        selfpromoAutoSkipButton.setOnClickListener {
            selfpromoDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            selfpromoAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            selfpromoManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockSelfpromo", 1).apply()
        }
        selfpromoManualSkipButton.setOnClickListener {
            selfpromoDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            selfpromoAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            selfpromoManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            preferences.edit().putInt("RTSponsorBlockSelfpromo", 2).apply()
        }

        // Interaction
        val interactionDisableButton: Button = findViewById(R.id.interactionDisableButton)
        val interactionAutoSkipButton: Button = findViewById(R.id.interactionAutoSkipButton)
        val interactionManualSkipButton: Button = findViewById(R.id.interactionManualSkipButton)
        val interactionBlockInteraction: Int = preferences.getInt("RTSponsorBlockInteraction", 0)
        if (interactionBlockInteraction == 0) {
            interactionDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            interactionAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            interactionManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (interactionBlockInteraction == 1) {
            interactionDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            interactionAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            interactionManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (interactionBlockInteraction == 2) {
            interactionDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            interactionAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            interactionManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
        }
        interactionDisableButton.setOnClickListener {
            interactionDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            interactionAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            interactionManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockInteraction", 0).apply()
        }
        interactionAutoSkipButton.setOnClickListener {
            interactionDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            interactionAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            interactionManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockInteraction", 1).apply()
        }
        interactionManualSkipButton.setOnClickListener {
            interactionDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            interactionAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            interactionManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            preferences.edit().putInt("RTSponsorBlockInteraction", 2).apply()
        }

        // Intro
        val introDisableButton: Button = findViewById(R.id.introDisableButton)
        val introAutoSkipButton: Button = findViewById(R.id.introAutoSkipButton)
        val introManualSkipButton: Button = findViewById(R.id.introManualSkipButton)
        val introBlockIntro: Int = preferences.getInt("RTSponsorBlockIntro", 0)
        if (introBlockIntro == 0) {
            introDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            introAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            introManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (introBlockIntro == 1) {
            introDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            introAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            introManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (introBlockIntro == 2) {
            introDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            introAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            introManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
        }
        introDisableButton.setOnClickListener {
            introDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            introAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            introManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockIntro", 0).apply()
        }
        introAutoSkipButton.setOnClickListener {
            introDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            introAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            introManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockIntro", 1).apply()
        }
        introManualSkipButton.setOnClickListener {
            introDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            introAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            introManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            preferences.edit().putInt("RTSponsorBlockIntro", 2).apply()
        }

        // Outro
        val outroDisableButton: Button = findViewById(R.id.outroDisableButton)
        val outroAutoSkipButton: Button = findViewById(R.id.outroAutoSkipButton)
        val outroManualSkipButton: Button = findViewById(R.id.outroManualSkipButton)
        val outroBlockOutro: Int = preferences.getInt("RTSponsorBlockOutro", 0)
        if (outroBlockOutro == 0) {
            outroDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            outroAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            outroManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (outroBlockOutro == 1) {
            outroDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            outroAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            outroManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (outroBlockOutro == 2) {
            outroDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            outroAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            outroManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
        }
        outroDisableButton.setOnClickListener {
            outroDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            outroAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            outroManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockOutro", 0).apply()
        }
        outroAutoSkipButton.setOnClickListener {
            outroDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            outroAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            outroManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockOutro", 1).apply()
        }
        outroManualSkipButton.setOnClickListener {
            outroDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            outroAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            outroManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            preferences.edit().putInt("RTSponsorBlockOutro", 2).apply()
        }

        // Preview
        val previewDisableButton: Button = findViewById(R.id.previewDisableButton)
        val previewAutoSkipButton: Button = findViewById(R.id.previewAutoSkipButton)
        val previewManualSkipButton: Button = findViewById(R.id.previewManualSkipButton)
        val previewBlockPreview: Int = preferences.getInt("RTSponsorBlockPreview", 0)
        if (previewBlockPreview == 0) {
            previewDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            previewAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            previewManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (previewBlockPreview == 1) {
            previewDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            previewAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            previewManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (previewBlockPreview == 2) {
            previewDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            previewAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            previewManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
        }
        previewDisableButton.setOnClickListener {
            previewDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            previewAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            previewManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockPreview", 0).apply()
        }
        previewAutoSkipButton.setOnClickListener {
            previewDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            previewAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            previewManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockPreview", 1).apply()
        }
        previewManualSkipButton.setOnClickListener {
            previewDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            previewAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            previewManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            preferences.edit().putInt("RTSponsorBlockPreview", 2).apply()
        }

        // Musicofftopic
        val musicofftopicDisableButton: Button = findViewById(R.id.musicofftopicDisableButton)
        val musicofftopicAutoSkipButton: Button = findViewById(R.id.musicofftopicAutoSkipButton)
        val musicofftopicManualSkipButton: Button = findViewById(R.id.musicofftopicManualSkipButton)
        val musicofftopicBlockMusicofftopic: Int = preferences.getInt("RTSponsorBlockMusicofftopic", 0)
        if (musicofftopicBlockMusicofftopic == 0) {
            musicofftopicDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            musicofftopicAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            musicofftopicManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (musicofftopicBlockMusicofftopic == 1) {
            musicofftopicDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            musicofftopicAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            musicofftopicManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
        } else if (musicofftopicBlockMusicofftopic == 2) {
            musicofftopicDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            musicofftopicAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            musicofftopicManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
        }
        musicofftopicDisableButton.setOnClickListener {
            musicofftopicDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            musicofftopicAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            musicofftopicManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockMusicofftopic", 0).apply()
        }
        musicofftopicAutoSkipButton.setOnClickListener {
            musicofftopicDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            musicofftopicAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            musicofftopicManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            preferences.edit().putInt("RTSponsorBlockMusicofftopic", 1).apply()
        }
        musicofftopicManualSkipButton.setOnClickListener {
            musicofftopicDisableButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            musicofftopicAutoSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.transparent))
            )
            musicofftopicManualSkipButton.backgroundTintList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            preferences.edit().putInt("RTSponsorBlockMusicofftopic", 2).apply()
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