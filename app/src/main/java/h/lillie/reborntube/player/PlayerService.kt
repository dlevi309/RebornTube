package h.lillie.reborntube.player

import android.annotation.SuppressLint
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.common.MediaMetadata
import androidx.media3.common.MediaItem
import androidx.media3.common.C
import androidx.media3.session.MediaSessionService
import androidx.media3.session.MediaSession
import com.google.gson.Gson
import h.lillie.reborntube.VideoData
import org.json.JSONArray
import org.json.JSONException
import java.io.IOException

class PlayerService : MediaSessionService() {

    private lateinit var player: ExoPlayer
    private lateinit var playerHandler: Handler
    private var playerSession: MediaSession? = null

    private var sponsorBlockInfo = String()

    override fun onCreate() {
        super.onCreate()
        val gson = Gson()
        val dataPreferences = getSharedPreferences("RTData", 0)
        val videoData = gson.fromJson(dataPreferences.getString("RTVideoData", ""), VideoData::class.java)
        sponsorBlockInfo = videoData.sponsorBlockInfo
        playerHandler = Handler(Looper.getMainLooper())
        createPlayer()
    }

    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaSession? = playerSession

    @SuppressLint("UnsafeOptInUsageError")
    override fun onDestroy() {
        super.onDestroy()
        playerSession?.run {
            playerHandler.removeCallbacks(playerTask)
            playerHandler.removeCallbacksAndMessages(null)
            player.stop()
            player.release()
            release()
            playerSession = null
            clearListener()
        }
    }

    @SuppressLint("UnsafeOptInUsageError")
    private fun createPlayer() {
        val settingsPreferences = getSharedPreferences("RTSettings", 0)
        val enableCaptions: Boolean = settingsPreferences.getBoolean("RTEnableCaptions", false)

        val videoTrackSelector: DefaultTrackSelector = DefaultTrackSelector(this@PlayerService)
        if (!enableCaptions) {
            videoTrackSelector.parameters = DefaultTrackSelector.Parameters.Builder(this@PlayerService).setRendererDisabled(C.TRACK_TYPE_VIDEO, true).setPreferredTextLanguage("en").build()
        } else if (enableCaptions) {
            videoTrackSelector.parameters = DefaultTrackSelector.Parameters.Builder(this@PlayerService).setRendererDisabled(C.TRACK_TYPE_VIDEO, false).setPreferredTextLanguage("en").build()
        }

        player = ExoPlayer.Builder(this).setTrackSelector(videoTrackSelector).build()
        playerSession = MediaSession.Builder(this, player).build()

        val gson = Gson()
        val dataPreferences = getSharedPreferences("RTData", 0)
        val videoData = gson.fromJson(dataPreferences.getString("RTVideoData", ""), VideoData::class.java)
        val title = videoData.title
        val author = videoData.author

        val hlsUrl = videoData.hlsURL
        val artworkUrl = videoData.artworkURL
        val artworkUri: Uri = Uri.parse(artworkUrl)

        val isLive = videoData.live

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
        if (!isLive) {
            playerHandler.post(playerTask)
        }
    }

    private val playerTask = object : Runnable {
        override fun run() {
            try {
                val jsonArray = JSONArray(sponsorBlockInfo)
                val settingsPreferences = getSharedPreferences("RTSettings", 0)
                for (i in 0 until jsonArray.length()) {
                    val category = jsonArray.getJSONObject(i).optString("category")
                    val segment = jsonArray.getJSONObject(i).getJSONArray("segment")
                    val segment0 = String.format("%.3f", segment[0].toString().toDouble()).replace(".", "").toFloat()
                    val segment1 = String.format("%.3f", segment[1].toString().toDouble()).replace(".", "").toFloat()
                    if (category.contains("sponsor") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        val sponsorBlockSponsor: Int = settingsPreferences.getInt("RTSponsorBlockSponsor", 0)
                        if (sponsorBlockSponsor == 1) {
                            player.seekTo(segment1.toLong())
                            Toast.makeText(this@PlayerService, "Sponsor Skipped", Toast.LENGTH_SHORT).show()
                        }
                    } else if (category.contains("selfpromo") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        val selfpromoBlockSelfpromo: Int = settingsPreferences.getInt("RTSponsorBlockSelfpromo", 0)
                        if (selfpromoBlockSelfpromo == 1) {
                            player.seekTo(segment1.toLong())
                            Toast.makeText(this@PlayerService, "Selfpromo Skipped", Toast.LENGTH_SHORT).show()
                        }
                    } else if (category.contains("interaction") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        val interactionBlockInteraction: Int = settingsPreferences.getInt("RTSponsorBlockInteraction", 0)
                        if (interactionBlockInteraction == 1) {
                            player.seekTo(segment1.toLong())
                            Toast.makeText(this@PlayerService, "Interaction Skipped", Toast.LENGTH_SHORT).show()
                        }
                    } else if (category.contains("intro") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        val introBlockIntro: Int = settingsPreferences.getInt("RTSponsorBlockIntro", 0)
                        if (introBlockIntro == 1) {
                            player.seekTo(segment1.toLong())
                            Toast.makeText(this@PlayerService, "Intro Skipped", Toast.LENGTH_SHORT).show()
                        }
                    } else if (category.contains("outro") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        val outroBlockOutro: Int = settingsPreferences.getInt("RTSponsorBlockOutro", 0)
                        if (outroBlockOutro == 1) {
                            player.seekTo(segment1.toLong())
                            Toast.makeText(this@PlayerService, "Outro Skipped", Toast.LENGTH_SHORT).show()
                        }
                    } else if (category.contains("preview") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        val previewBlockPreview: Int = settingsPreferences.getInt("RTSponsorBlockPreview", 0)
                        if (previewBlockPreview == 1) {
                            player.seekTo(segment1.toLong())
                            Toast.makeText(this@PlayerService, "Preview Skipped", Toast.LENGTH_SHORT).show()
                        }
                    } else if (category.contains("filler") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        val fillerBlockFiller: Int = settingsPreferences.getInt("RTSponsorBlockFiller", 0)
                        if (fillerBlockFiller == 1) {
                            player.seekTo(segment1.toLong())
                            Toast.makeText(this@PlayerService, "Filler Tangent/Jokes Skipped", Toast.LENGTH_SHORT).show()
                        }
                    } else if (category.contains("music_offtopic") && player.currentPosition >= segment0 && player.currentPosition <= (segment1 - 1)) {
                        val musicofftopicBlockMusicofftopic: Int = settingsPreferences.getInt("RTSponsorBlockMusicofftopic", 0)
                        if (musicofftopicBlockMusicofftopic == 1) {
                            player.seekTo(segment1.toLong())
                            Toast.makeText(this@PlayerService, "Music_offtopic Skipped", Toast.LENGTH_SHORT).show()
                        }
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