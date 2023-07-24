package h.lillie.reborntube

import android.annotation.SuppressLint
import android.content.Intent
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import android.widget.RelativeLayout
import android.widget.Button
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import android.view.View
import android.view.ViewGroup
import android.graphics.drawable.Drawable
import android.graphics.drawable.ColorDrawable
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.common.MediaMetadata
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.session.MediaSession
import androidx.media3.ui.PlayerView
import java.util.concurrent.TimeUnit
import com.google.android.material.slider.Slider
import com.google.android.material.switchmaterial.SwitchMaterial
import com.google.gson.Gson
import com.pedromassango.doubleclick.DoubleClick
import com.pedromassango.doubleclick.DoubleClickListener
import com.squareup.picasso.Picasso
import org.json.JSONArray
import org.json.JSONException
import java.io.IOException

class TVPlayer : AppCompatActivity() {

    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0
    private var overlayVisible = 0
    private var onStopCalled: Boolean = false
    private var sponsorBlockInfo = String()

    private lateinit var player: ExoPlayer
    private lateinit var playerHandler: Handler
    private lateinit var playerSlider: Slider
    private var playerSession: MediaSession? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.player)
        val gson = Gson()
        val videoData = gson.fromJson(Application.getVideoData(), Data::class.java)
        sponsorBlockInfo = videoData.sponsorBlockInfo
        playerHandler = Handler(Looper.getMainLooper())
        playerSlider = findViewById(R.id.playerSlider)
        getDeviceInfo()
        if (deviceType == true) {
            val playerLayout: RelativeLayout = findViewById(R.id.playerLayout)
            val params = playerLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            playerLayout.layoutParams = params
        }
        createPlayer()
    }

    override fun onDestroy() {
        super.onDestroy()
        Application.setVideoData("")
        playerSession?.run {
            playerHandler.removeCallbacks(playerTask)
            playerHandler.removeCallbacksAndMessages(null)
            player.stop()
            player.release()
            release()
            playerSession = null
        }
    }

    override fun onResume() {
        super.onResume()
        onStopCalled = false
    }

    override fun onStop() {
        super.onStop()
        onStopCalled = true
    }

    @SuppressLint("SwitchIntDef")
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        when (newConfig.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> getDeviceInfo()
            Configuration.ORIENTATION_LANDSCAPE -> getDeviceInfo()
        }
    }

    @SuppressLint("SwitchIntDef")
    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
        when (resources.configuration.orientation) {
            Configuration.ORIENTATION_PORTRAIT -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
                createUI(0)
            }
            Configuration.ORIENTATION_LANDSCAPE -> {
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_FULLSCREEN
                createUI(1)
            }
        }
    }

    private fun createUI(orientation: Int) {
        // Info
        val gson = Gson()
        val videoData = gson.fromJson(Application.getVideoData(), Data::class.java)

        // Player
        val videoPlayer: RelativeLayout = findViewById(R.id.videoPlayer)
        videoPlayer.layoutParams = RelativeLayout.LayoutParams(deviceWidth, deviceWidth * 9 / 16)

        // Overlay
        val leftView: View = findViewById(R.id.leftView)
        leftView.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        leftView.setOnClickListener(DoubleClick(object : DoubleClickListener {
            override fun onSingleClick(view: View) {
                changeOverlay(orientation)
            }
            override fun onDoubleClick(view: View) {
                player.seekTo(player.currentPosition - TimeUnit.SECONDS.toMillis(10))
            }
        }))

        val middleView: View = findViewById(R.id.middleView)
        middleView.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        middleView.x = deviceWidth / 3f
        middleView.setOnClickListener {
            changeOverlay(orientation)
        }

        val rightView: View = findViewById(R.id.rightView)
        rightView.layoutParams = RelativeLayout.LayoutParams(deviceWidth / 3, deviceWidth * 9 / 16)
        rightView.x = (deviceWidth / 3) * 2f
        rightView.setOnClickListener(DoubleClick(object : DoubleClickListener {
            override fun onSingleClick(view: View) {
                changeOverlay(orientation)
            }
            override fun onDoubleClick(view: View) {
                player.seekTo(player.currentPosition + TimeUnit.SECONDS.toMillis(10))
            }
        }))

        val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
        playPauseRestartButton.layoutParams = RelativeLayout.LayoutParams(108, 108)
        playPauseRestartButton.x = (deviceWidth / 2) - 54f
        if (orientation == 0) {
            playPauseRestartButton.y = ((deviceWidth * 9 / 16) / 2) - 54f
        } else if (orientation == 1) {
            playPauseRestartButton.y = (deviceHeight / 2) - 54f
        }
        playPauseRestartButton.setOnClickListener {
            if (player.playWhenReady) {
                player.pause()
            } else if (!player.playWhenReady) {
                player.play()
            }
        }

        val videoSwitch: SwitchMaterial = findViewById(R.id.videoSwitch)
        videoSwitch.layoutParams = RelativeLayout.LayoutParams(200, 100)
        if (orientation == 0) {
            videoSwitch.x = deviceWidth - 210f
            videoSwitch.y = 10f
        }
        if (orientation == 1) {
            videoSwitch.x = deviceWidth - 310f
            videoSwitch.y = 50f
        }
        videoSwitch.setOnCheckedChangeListener { _, isChecked ->
            val playerView: PlayerView = findViewById(R.id.playerView)
            val playerImageView: ImageView = findViewById(R.id.playerImageView)
            if (!isChecked) {
                playerView.visibility = View.VISIBLE
                playerImageView.visibility = View.GONE
            } else if (isChecked) {
                playerView.visibility = View.GONE
                playerImageView.visibility = View.VISIBLE
            }
        }

        // Slider
        playerSlider.layoutParams = RelativeLayout.LayoutParams(deviceWidth + 64, 0)
        if (orientation == 0) {
            playerSlider.y = (deviceWidth * 9 / 16) - 64f
            playerSlider.visibility = View.VISIBLE
        } else if (orientation == 1) {
            playerSlider.y = deviceHeight - 256f
            if (overlayVisible == 0) {
                playerSlider.visibility = View.GONE
            } else if (overlayVisible == 1) {
                playerSlider.visibility = View.VISIBLE
            }
        }
        playerSlider.addOnChangeListener { _, value, fromUser ->
            val duration = player.duration.toFloat()
            val position = player.currentPosition.toFloat()
            if (fromUser && duration >= 0 && position >= 0) {
                player.seekTo(value.toLong())
            }
        }

        // Title
        val videoTitle: TextView = findViewById(R.id.videoTitle)
        val title = videoData.title
        videoTitle.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 50)
        if (orientation == 0) {
            videoTitle.y = (deviceWidth * 9 / 16) + 64f
            videoTitle.visibility = View.VISIBLE
        } else if (orientation == 1) {
            videoTitle.y = 50f
            if (overlayVisible == 0) {
                videoTitle.visibility = View.GONE
            } else if (overlayVisible == 1) {
                videoTitle.visibility = View.VISIBLE
            }
        }
        videoTitle.text = title

        // Info
        val videoInfo: RelativeLayout = findViewById(R.id.videoInfo)
        if (orientation == 0) {
            videoInfo.visibility = View.VISIBLE
        } else if (orientation == 1) {
            videoInfo.visibility = View.GONE
        }

        val videoCountLikesDislikes: TextView = findViewById(R.id.videoCountLikesDislikes)
        videoCountLikesDislikes.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 200)
        videoCountLikesDislikes.y = (deviceWidth * 9 / 16) + 144f
        val viewCount = videoData.viewCount.toDouble()
        val likes = videoData.likes.toDouble()
        val dislikes = videoData.dislikes.toDouble()
        val info = "View Count: %,.0f\nLikes: %,.0f\nDislikes: %,.0f".format(viewCount, likes, dislikes)
        videoCountLikesDislikes.text = info

        val videoLoop: Button = findViewById(R.id.videoLoop)
        videoLoop.layoutParams = RelativeLayout.LayoutParams(200, 100)
        videoLoop.y = (deviceWidth * 9 / 16) + 304f
        videoLoop.setOnClickListener {
            if (player.repeatMode == Player.REPEAT_MODE_OFF) {
                player.repeatMode = Player.REPEAT_MODE_ONE
                Toast.makeText(applicationContext, "Loop Enabled", Toast.LENGTH_SHORT).show()
            } else if (player.repeatMode == Player.REPEAT_MODE_ONE) {
                player.repeatMode = Player.REPEAT_MODE_OFF
                Toast.makeText(applicationContext, "Loop Disabled", Toast.LENGTH_SHORT).show()
            }
        }

        val videoShare: Button = findViewById(R.id.videoShare)
        videoShare.layoutParams = RelativeLayout.LayoutParams(200, 100)
        videoShare.x = 220f
        videoShare.y = (deviceWidth * 9 / 16) + 304f
        videoShare.setOnClickListener {
            val videoID = videoData.videoID
            val shareIntent: Intent = Intent().apply {
                action = Intent.ACTION_SEND
                putExtra(Intent.EXTRA_TEXT, "https://youtu.be/$videoID")
                type = "text/plain"
            }
            startActivity(Intent.createChooser(shareIntent, null))
        }
    }

    private fun changeOverlay(orientation: Int) {
        val leftView: View = findViewById(R.id.leftView)
        val middleView: View = findViewById(R.id.middleView)
        val rightView: View = findViewById(R.id.rightView)
        val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
        val videoTitle: TextView = findViewById(R.id.videoTitle)
        val videoSwitch: SwitchMaterial = findViewById(R.id.videoSwitch)

        val leftViewDrawable: Drawable = leftView.background
        val leftViewColorDrawable: ColorDrawable = leftViewDrawable as ColorDrawable
        val middleViewDrawable: Drawable = middleView.background
        val middleViewColorDrawable: ColorDrawable = middleViewDrawable as ColorDrawable
        val rightViewDrawable: Drawable = rightView.background
        val rightViewColorDrawable: ColorDrawable = rightViewDrawable as ColorDrawable

        val blackDimmed = applicationContext.getColor(R.color.blackdimmed)

        if (leftViewColorDrawable.color == blackDimmed && middleViewColorDrawable.color == blackDimmed && rightViewColorDrawable.color == blackDimmed) {
            overlayVisible = 0
            leftView.setBackgroundColor(0x00000000)
            middleView.setBackgroundColor(0x00000000)
            rightView.setBackgroundColor(0x00000000)
            playPauseRestartButton.visibility = View.GONE
            videoSwitch.visibility = View.GONE
            val playerSliderActiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            val playerSliderInactiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.darkgrey))
            )
            if (orientation == 0) {
                videoTitle.visibility = View.VISIBLE
                playerSlider.visibility = View.VISIBLE
            } else if (orientation == 1) {
                videoTitle.visibility = View.GONE
                playerSlider.visibility = View.GONE
            }
            playerSlider.trackActiveTintList = playerSliderActiveColourList
            playerSlider.trackInactiveTintList = playerSliderInactiveColourList
            playerSlider.thumbRadius = 0
            playerSlider.haloRadius = 0
        } else {
            overlayVisible = 1
            leftView.setBackgroundColor(blackDimmed)
            middleView.setBackgroundColor(blackDimmed)
            rightView.setBackgroundColor(blackDimmed)
            playPauseRestartButton.visibility = View.VISIBLE
            videoSwitch.visibility = View.VISIBLE
            val playerSliderActiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.red))
            )
            val playerSliderInactiveColourList = ColorStateList(
                arrayOf(intArrayOf(android.R.attr.state_enabled)),
                intArrayOf(applicationContext.getColor(R.color.lightgrey))
            )
            videoTitle.visibility = View.VISIBLE
            playerSlider.visibility = View.VISIBLE
            playerSlider.trackActiveTintList = playerSliderActiveColourList
            playerSlider.trackInactiveTintList = playerSliderInactiveColourList
            playerSlider.thumbRadius = 15
            playerSlider.haloRadius = 15
        }
    }

    @SuppressLint("UnsafeOptInUsageError")
    private fun createPlayer() {
        val playerImageView: ImageView = findViewById(R.id.playerImageView)
        val gson = Gson()
        val videoData = gson.fromJson(Application.getVideoData(), Data::class.java)
        val artworkUrl = videoData.artworkURL
        val artworkUri: Uri = Uri.parse(artworkUrl)
        Picasso.get().load(artworkUri).into(playerImageView)

        player = ExoPlayer.Builder(this).build()
        playerSession = MediaSession.Builder(this, player).build()

        val title = videoData.title
        val author = videoData.author
        val hlsUrl = videoData.hlsURL

        val mediaMetadata: MediaMetadata = MediaMetadata.Builder()
            .setTitle(title)
            .setArtist(author)
            .setArtworkUri(artworkUri)
            .build()

        val videoUri: Uri = Uri.parse(hlsUrl)

        val videoMediaItem: MediaItem = MediaItem.Builder()
            .setMediaMetadata(mediaMetadata)
            .setUri(videoUri)
            .build()

        val dataSourceFactory: DataSource.Factory = DefaultHttpDataSource.Factory()
        val videoSource: MediaSource = HlsMediaSource.Factory(dataSourceFactory).createMediaSource(videoMediaItem)

        player.setMediaSource(videoSource)
        player.playWhenReady = true
        player.prepare()

        val playerView: PlayerView = findViewById(R.id.playerView)
        playerView.player = player
        playerHandler.post(playerTask)
    }

    private val playerTask = object : Runnable {
        override fun run() {
            try {
                val playPauseRestartButton: ImageButton = findViewById(R.id.playPauseRestartButton)
                if (player.playWhenReady) {
                    playPauseRestartButton.setImageResource(R.drawable.pause)
                } else if (!player.playWhenReady) {
                    playPauseRestartButton.setImageResource(R.drawable.play)
                }

                val duration = player.duration.toFloat()
                val position = player.currentPosition.toFloat()
                if (duration >= 0 && position >= 0 && position <= duration) {
                    playerSlider.valueTo = duration
                    playerSlider.value = position
                }

                val jsonArray = JSONArray(sponsorBlockInfo)
                for (i in 0 until jsonArray.length()) {
                    val category = jsonArray.getJSONObject(i).optString("category")
                    val segment = jsonArray.getJSONObject(i).getJSONArray("segment")
                    val segment0 = String.format("%.3f", segment[0].toString().toDouble()).replace(".", "").toFloat()
                    val segment1 = String.format("%.3f", segment[1].toString().toDouble()).replace(".", "").toFloat()
                    if (category.contains("sponsor") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        player.seekTo(segment1.toLong())
                        Toast.makeText(applicationContext, "Sponsor Skipped", Toast.LENGTH_SHORT).show()
                    } else if (category.contains("interaction") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        player.seekTo(segment1.toLong())
                        Toast.makeText(applicationContext, "Interaction Skipped", Toast.LENGTH_SHORT).show()
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