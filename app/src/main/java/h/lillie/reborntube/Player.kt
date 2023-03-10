package h.lillie.reborntube

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.app.PictureInPictureParams
import android.widget.RelativeLayout
import android.widget.Button
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import android.content.res.Configuration
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import androidx.media3.ui.PlayerView
import java.util.concurrent.TimeUnit
import com.google.common.util.concurrent.MoreExecutors

class Player : AppCompatActivity() {

    private var deviceHeight = 0
    private var deviceWidth = 0

    private lateinit var playerView: PlayerView
    private lateinit var playerController: MediaController

    @SuppressLint("UnsafeOptInUsageError")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
        getDeviceInfo()
        setupUI()
        val sessionToken = SessionToken(this, ComponentName(this, PlayerService::class.java))
        val controllerFuture = MediaController.Builder(this, sessionToken).buildAsync()
        controllerFuture.addListener(
            {
                playerController = controllerFuture.get()

                playerView = findViewById(R.id.playerView)
                playerView.visibility = View.VISIBLE
                playerView.useController = false
                playerView.setShowPreviousButton(false)
                playerView.setShowNextButton(false)
                playerView.player = playerController
            },
            MoreExecutors.directExecutor()
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        stopService(Intent(this, PlayerService::class.java))
    }

    @SuppressLint("SwitchIntDef")
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        when (newConfig.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                getDeviceInfo()
                setupUI()
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                getDeviceInfo()
                setupUI()
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        val pictureInPictureParams: PictureInPictureParams = PictureInPictureParams.Builder()
            .setAutoEnterEnabled(true)
            .build()
        this.enterPictureInPictureMode(pictureInPictureParams)
    }

    @SuppressLint("SwitchIntDef")
    private fun getDeviceInfo() {
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
        when (resources.configuration.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_FULLSCREEN
            }
        }
    }

    private fun setupUI() {
        // Video Player
        val videoRelativeLayout: RelativeLayout = findViewById(R.id.videoRelativeLayout)
        videoRelativeLayout.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)

        // Left Overlay
        val rewindButton: Button = findViewById(R.id.rewindButton)
        rewindButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        rewindButton.setOnClickListener {
            playerController.seekTo(playerController.currentPosition - TimeUnit.SECONDS.toMillis(10))
        }

        // Middle Overlay
        val playButton: Button = findViewById(R.id.playButton)
        playButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        playButton.x = deviceWidth / 3.toFloat()
        playButton.setOnClickListener {
            if (playerController.playWhenReady) {
                playerController.pause()
            } else if (!playerController.playWhenReady) {
                playerController.play()
            }
        }

        // Right Overlay
        val forwardButton: Button = findViewById(R.id.forwardButton)
        forwardButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        forwardButton.x = (deviceWidth / 3) * 2.toFloat()
        forwardButton.setOnClickListener {
            playerController.seekTo(playerController.currentPosition + TimeUnit.SECONDS.toMillis(10))
        }
    }
}