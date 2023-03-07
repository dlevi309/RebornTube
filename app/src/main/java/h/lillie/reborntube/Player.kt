package h.lillie.reborntube

import android.annotation.SuppressLint
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.app.PictureInPictureParams
import android.widget.RelativeLayout
import android.widget.Button
import android.view.KeyEvent
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import android.content.res.Configuration
import android.media.session.MediaSession
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.MediaItem.*
import com.google.android.exoplayer2.source.*
import com.google.android.exoplayer2.Player.*
import com.google.android.exoplayer2.upstream.*
import com.google.android.exoplayer2.ui.StyledPlayerView
import java.io.IOException
import org.json.JSONArray
import org.json.JSONException
import java.util.concurrent.TimeUnit

class Player : AppCompatActivity() {

    private var deviceHeight = 0
    private var deviceWidth = 0

    private lateinit var player: ExoPlayer
    private lateinit var playerHandler: Handler
    private lateinit var playerView: StyledPlayerView
    private lateinit var playerSession: MediaSession

    private var sponsorBlockInfo = String()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
        sponsorBlockInfo = intent.getStringExtra("sponsorBlock").toString()
        playerHandler = Handler(Looper.getMainLooper())
        getDeviceInfo()
        setupUI()
        createPlayer()
        createPlayerSession()
    }

    override fun onDestroy() {
        super.onDestroy()
        player.release()
    }

    override fun onPause() {
        super.onPause()
        playerHandler.removeCallbacks(playerTask)
    }

    override fun onResume() {
        super.onResume()
        playerHandler.post(playerTask)
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
            player.seekTo(player.currentPosition - TimeUnit.SECONDS.toMillis(10))
        }
        rewindButton.visibility = View.GONE

        // Middle Overlay
        val playButton: Button = findViewById(R.id.playButton)
        playButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        playButton.x = deviceWidth / 3.toFloat()
        playButton.setOnClickListener {
            if (player.playWhenReady) {
                player.pause()
            } else if (!player.playWhenReady) {
                player.play()
            }
        }
        playButton.visibility = View.GONE

        // Right Overlay
        val forwardButton: Button = findViewById(R.id.forwardButton)
        forwardButton.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        forwardButton.x = (deviceWidth / 3) * 2.toFloat()
        forwardButton.setOnClickListener {
            player.seekTo(player.currentPosition + TimeUnit.SECONDS.toMillis(10))
        }
        forwardButton.visibility = View.GONE
    }

    private fun createPlayer() {
        player = ExoPlayer.Builder(this).build()
        playerView = findViewById(R.id.playerView)
        playerView.visibility = View.VISIBLE
        // playerView.useController = false
        playerView.setShowPreviousButton(false)
        playerView.setShowNextButton(false)
        playerView.player = player

        val videoUrl = intent.getStringExtra("videoUrl").toString()
        val audioUrl = intent.getStringExtra("audioUrl").toString()
        val videoUri: Uri = Uri.parse(videoUrl)
        val audioUri: Uri = Uri.parse(audioUrl)
        val dataSourceFactory: DataSource.Factory = DefaultHttpDataSource.Factory()
        val videoSource: MediaSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(fromUri(videoUri))
        val audioSource: MediaSource = ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(fromUri(audioUri))
        val mergeSource: MediaSource = MergingMediaSource(videoSource, audioSource)

        player.repeatMode = REPEAT_MODE_ONE
        player.setMediaSource(mergeSource)
        player.playWhenReady = true
        player.prepare()
    }

    private fun createPlayerSession() {
        playerSession = MediaSession(this, "RebornTubePlayerSession")
        val playerSessionCallback = object: MediaSession.Callback() {
            override fun onMediaButtonEvent(intent: Intent) : Boolean {
                val keyEvent : KeyEvent? = intent.getParcelableExtra(Intent.EXTRA_KEY_EVENT)
                Log.d("KeyEvent", keyEvent.toString())
                when (keyEvent?.keyCode) {
                    KeyEvent.KEYCODE_MEDIA_PLAY -> {
                        player.play()
                    }
                    KeyEvent.KEYCODE_MEDIA_PAUSE -> {
                        player.pause()
                    }
                    KeyEvent.KEYCODE_MEDIA_PREVIOUS -> {
                        player.seekToPrevious()
                    }
                    KeyEvent.KEYCODE_MEDIA_NEXT -> {
                        player.seekToNext()
                    }
                }
                return super.onMediaButtonEvent(intent)
            }
        }
        playerSession.setCallback(playerSessionCallback)
        playerSession.isActive = true
    }

    private val playerTask = object : Runnable {
        override fun run() {
            try {
                val jsonArray = JSONArray(sponsorBlockInfo)
                for (i in 0 until jsonArray.length()) {
                    val category = jsonArray.getJSONObject(i).optString("category")
                    val segment = jsonArray.getJSONObject(i).getJSONArray("segment")
                    val segment0 = String.format("%.3f", segment[0].toString().toDouble()).replace(".", "").toFloat()
                    val segment1 = String.format("%.3f", segment[1].toString().toDouble()).replace(".", "").toFloat()
                    if (category.contains("sponsor") && player.currentPosition.toString().toFloat() >= segment0 && player.currentPosition.toString().toFloat() <= (segment1 - 1)) {
                        player.seekTo(segment1.toLong())
                    } else if (category.contains("interaction") && player.currentPosition.toString().toFloat() >= segment0 && player.currentPosition.toString().toFloat() <= (segment1 - 1)) {
                        player.seekTo(segment1.toLong())
                    }
                }
            } catch (e: IOException) {
                Log.e("IOException", e.toString())
            } catch (e: JSONException) {
                Log.e("JSONException", e.toString())
            }
            playerHandler.postDelayed(this, 1000)
        }
    }
}