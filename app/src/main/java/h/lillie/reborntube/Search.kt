package h.lillie.reborntube

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.util.TypedValue
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.res.ResourcesCompat
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import android.widget.RelativeLayout
import android.widget.LinearLayout
import android.widget.Space
import android.view.View
import android.view.ViewGroup
import android.view.Gravity
import com.squareup.picasso.Picasso
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class Search : AppCompatActivity() {

    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.search)
        getDeviceInfo()
        if (deviceType) {
            val searchLayout: RelativeLayout = findViewById(R.id.searchLayout)
            val params = searchLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            searchLayout.layoutParams = params
        }

        val searchScrollView: LinearLayout = findViewById(R.id.searchScrollLayout)

        val searchBar: EditText = findViewById(R.id.searchBar)
        val searchBarButton: Button = findViewById(R.id.searchBarButton)
        if (deviceType) {
            searchBarButton.setBackgroundResource(R.drawable.tvbutton)
        }
        searchBarButton.setOnClickListener {
            searchScrollView.removeAllViews()
            val extractor = Extractor()

            val youtubeRegex = Regex("^.*(?:(?:youtu\\.be\\/|v\\/|vi\\/|u\\/\\w\\/|embed\\/|shorts\\/|live\\/)|(?:(?:watch)?\\?v(?:i)?=|\\&v(?:i)?=))([^#\\&\\?]*).*")
            if (youtubeRegex.containsMatchIn(searchBar.text)) {
                val result = youtubeRegex.findAll(searchBar.text).map { it.groupValues[1] }.joinToString()
                val playerRequest = extractor.playerRequest(applicationContext, result)
                val jsonObject = JSONObject(playerRequest)

                val searchRelativeView = RelativeLayout(applicationContext)
                searchRelativeView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 200)
                searchRelativeView.setBackgroundColor(applicationContext.getColor(R.color.darkgrey))

                val videoID: String = jsonObject.getJSONObject("videoDetails").optString("videoId").toString()
                val videoTitle: String = jsonObject.getJSONObject("videoDetails").optString("title").toString()
                val videoArtworkArray = jsonObject.getJSONObject("videoDetails").getJSONObject("thumbnail").getJSONArray("thumbnails")
                val videoArtworkUrl = videoArtworkArray.getJSONObject((videoArtworkArray.length() - 1)).optString("url")
                val videoAuthor: String = jsonObject.getJSONObject("videoDetails").optString("author").toString()
                val videoTime: Int = jsonObject.getJSONObject("videoDetails").optString("lengthSeconds").toString().toInt()
                val videoViewCount: Double = jsonObject.getJSONObject("videoDetails").optString("viewCount").toString().toDouble()

                val videoImageView = ImageView(applicationContext)
                videoImageView.layoutParams = LinearLayout.LayoutParams(180, 160)
                videoImageView.scaleType = ImageView.ScaleType.FIT_XY
                val artworkUri: Uri = Uri.parse(videoArtworkUrl)
                Picasso.get().load(artworkUri).into(videoImageView)

                val videoTimeTextView = TextView(applicationContext)
                videoTimeTextView.layoutParams = LinearLayout.LayoutParams(70, 30)
                videoTimeTextView.x = 110f
                videoTimeTextView.y = 130f
                videoTimeTextView.text = String.format("%02d:%02d:%02d", videoTime / 3600, (videoTime % 3600) / 60, videoTime % 60);
                videoTimeTextView.typeface = ResourcesCompat.getFont(this@Search, R.font.opensans_regular)
                videoTimeTextView.gravity = Gravity.CENTER
                videoTimeTextView.setTextColor(applicationContext.getColor(R.color.white))
                videoTimeTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)
                videoTimeTextView.setBackgroundColor(applicationContext.getColor(R.color.blackdimmed))

                val videoTitleTextView = TextView(applicationContext)
                videoTitleTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth - 190, 160)
                videoTitleTextView.x = 190f
                videoTitleTextView.text = videoTitle
                videoTitleTextView.typeface = ResourcesCompat.getFont(this@Search, R.font.opensans_regular)
                videoTitleTextView.gravity = Gravity.CENTER_VERTICAL
                videoTitleTextView.setTextColor(applicationContext.getColor(R.color.white))

                val videoViewCountAuthorTextView = TextView(applicationContext)
                if (!deviceType) {
                    videoViewCountAuthorTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth - 80, 40)
                } else if (deviceType) {
                    videoViewCountAuthorTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth, 40)
                }
                videoViewCountAuthorTextView.y = 160f
                videoViewCountAuthorTextView.text = String.format("%,.0f views - $videoAuthor", videoViewCount)
                videoViewCountAuthorTextView.typeface = ResourcesCompat.getFont(this@Search, R.font.opensans_regular)
                videoViewCountAuthorTextView.gravity = Gravity.CENTER_VERTICAL
                videoViewCountAuthorTextView.setTextColor(applicationContext.getColor(R.color.white))
                videoViewCountAuthorTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)

                val videoMenuTextView = TextView(applicationContext)
                videoMenuTextView.layoutParams = LinearLayout.LayoutParams(80, 40)
                videoMenuTextView.x = deviceWidth - 80f
                videoMenuTextView.y = 160f
                videoMenuTextView.text = "•••"
                videoMenuTextView.typeface = ResourcesCompat.getFont(this@Search, R.font.opensans_regular)
                videoMenuTextView.gravity = Gravity.CENTER
                videoMenuTextView.setTextColor(applicationContext.getColor(R.color.white))
                videoMenuTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)
                videoMenuTextView.setOnClickListener {
                    val shareIntent: Intent = Intent().apply {
                        action = Intent.ACTION_SEND
                        putExtra(Intent.EXTRA_TEXT, "https://youtu.be/$videoID")
                        type = "text/plain"
                    }
                    startActivity(Intent.createChooser(shareIntent, null))
                }

                val videoButton = View(applicationContext)
                videoButton.layoutParams = LinearLayout.LayoutParams(deviceWidth, 200)
                if (deviceType) {
                    videoButton.setBackgroundResource(R.drawable.tvbutton)
                }
                videoButton.setOnClickListener {
                    CoroutineScope(Dispatchers.Main).launch {
                        withContext(Dispatchers.IO) {
                            val loader = Loader()
                            loader.playerInit(applicationContext, videoID)

                            if (!deviceType) {
                                val intent = Intent(this@Search, Player::class.java)
                                startActivity(intent)
                            } else if (deviceType) {
                                val intent = Intent(this@Search, TVPlayer::class.java)
                                startActivity(intent)
                            }
                        }
                    }
                }
                searchRelativeView.addView(videoImageView)
                searchRelativeView.addView(videoTimeTextView)
                searchRelativeView.addView(videoTitleTextView)
                searchRelativeView.addView(videoViewCountAuthorTextView)
                searchRelativeView.addView(videoButton)
                if (!deviceType) {
                    searchRelativeView.addView(videoMenuTextView)
                }

                val spaceView = Space(applicationContext)
                spaceView.minimumHeight = 4
                searchScrollView.addView(spaceView)
                searchScrollView.addView(searchRelativeView)
            } else {
                val searchRequest = extractor.searchRequest(applicationContext, searchBar.text.toString())
                val jsonObject = JSONObject(searchRequest)

                val searchContents: JSONArray = jsonObject.getJSONObject("contents").getJSONObject("twoColumnSearchResultsRenderer").getJSONObject("primaryContents").getJSONObject("sectionListRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("itemSectionRenderer").getJSONArray("contents")

                for (i in 0 until searchContents.length()) {
                    try {
                        val searchRelativeView = RelativeLayout(applicationContext)
                        searchRelativeView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 200)
                        searchRelativeView.setBackgroundColor(applicationContext.getColor(R.color.darkgrey))

                        val videoID: String = searchContents.getJSONObject(i).getJSONObject("videoRenderer").optString("videoId").toString()
                        val videoTitle: String = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("title").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                        val videoArtworkArray = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("thumbnail").getJSONArray("thumbnails")
                        val videoArtworkUrl: String = videoArtworkArray.getJSONObject((videoArtworkArray.length() - 1)).optString("url").toString()
                        val videoAuthor: String = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("longBylineText").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                        val videoTime: String = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("lengthText").optString("simpleText").toString()
                        var videoViewCount = String()
                        if (searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").optString("simpleText").toString() != null) {
                            videoViewCount = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").optString("simpleText").toString()
                        } else if (searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").getJSONArray("runs").length() >= 1) {
                            videoViewCount = searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").getJSONArray("runs").getJSONObject(0).optString("text").toString() + searchContents.getJSONObject(i).getJSONObject("videoRenderer").getJSONObject("viewCountText").getJSONArray("runs").getJSONObject(1).optString("text").toString()
                        }

                        val videoImageView = ImageView(applicationContext)
                        videoImageView.layoutParams = LinearLayout.LayoutParams(180, 160)
                        videoImageView.scaleType = ImageView.ScaleType.FIT_XY
                        val artworkUri: Uri = Uri.parse(videoArtworkUrl)
                        Picasso.get().load(artworkUri).into(videoImageView)

                        val videoTimeTextView = TextView(applicationContext)
                        videoTimeTextView.layoutParams = LinearLayout.LayoutParams(70, 30)
                        videoTimeTextView.x = 110f
                        videoTimeTextView.y = 130f
                        videoTimeTextView.text = videoTime
                        videoTimeTextView.typeface = ResourcesCompat.getFont(this@Search, R.font.opensans_regular)
                        videoTimeTextView.gravity = Gravity.CENTER
                        videoTimeTextView.setTextColor(applicationContext.getColor(R.color.white))
                        videoTimeTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)
                        videoTimeTextView.setBackgroundColor(applicationContext.getColor(R.color.blackdimmed))

                        val videoTitleTextView = TextView(applicationContext)
                        videoTitleTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth - 190, 160)
                        videoTitleTextView.x = 190f
                        videoTitleTextView.text = videoTitle
                        videoTitleTextView.typeface = ResourcesCompat.getFont(this@Search, R.font.opensans_regular)
                        videoTitleTextView.gravity = Gravity.CENTER_VERTICAL
                        videoTitleTextView.setTextColor(applicationContext.getColor(R.color.white))

                        val videoViewCountAuthorTextView = TextView(applicationContext)
                        if (!deviceType) {
                            videoViewCountAuthorTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth - 80, 40)
                        } else if (deviceType) {
                            videoViewCountAuthorTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth, 40)
                        }
                        videoViewCountAuthorTextView.y = 160f
                        videoViewCountAuthorTextView.text = String.format("$videoViewCount - $videoAuthor")
                        videoViewCountAuthorTextView.typeface = ResourcesCompat.getFont(this@Search, R.font.opensans_regular)
                        videoViewCountAuthorTextView.gravity = Gravity.CENTER_VERTICAL
                        videoViewCountAuthorTextView.setTextColor(applicationContext.getColor(R.color.white))
                        videoViewCountAuthorTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)

                        val videoMenuTextView = TextView(applicationContext)
                        videoMenuTextView.layoutParams = LinearLayout.LayoutParams(80, 40)
                        videoMenuTextView.x = deviceWidth - 80f
                        videoMenuTextView.y = 160f
                        videoMenuTextView.text = "•••"
                        videoMenuTextView.typeface = ResourcesCompat.getFont(this@Search, R.font.opensans_regular)
                        videoMenuTextView.gravity = Gravity.CENTER
                        videoMenuTextView.setTextColor(applicationContext.getColor(R.color.white))
                        videoMenuTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)
                        videoMenuTextView.setOnClickListener {
                            val shareIntent: Intent = Intent().apply {
                                action = Intent.ACTION_SEND
                                putExtra(Intent.EXTRA_TEXT, "https://youtu.be/$videoID")
                                type = "text/plain"
                            }
                            startActivity(Intent.createChooser(shareIntent, null))
                        }

                        val videoButton = View(applicationContext)
                        videoButton.layoutParams = LinearLayout.LayoutParams(deviceWidth, 200)
                        if (deviceType) {
                            videoButton.setBackgroundResource(R.drawable.tvbutton)
                        }
                        videoButton.setOnClickListener {
                            CoroutineScope(Dispatchers.Main).launch {
                                withContext(Dispatchers.IO) {
                                    val loader = Loader()
                                    loader.playerInit(applicationContext, videoID)

                                    if (!deviceType) {
                                        val intent = Intent(this@Search, Player::class.java)
                                        startActivity(intent)
                                    } else if (deviceType) {
                                        val intent = Intent(this@Search, TVPlayer::class.java)
                                        startActivity(intent)
                                    }
                                }
                            }
                        }
                        searchRelativeView.addView(videoImageView)
                        searchRelativeView.addView(videoTimeTextView)
                        searchRelativeView.addView(videoTitleTextView)
                        searchRelativeView.addView(videoViewCountAuthorTextView)
                        searchRelativeView.addView(videoButton)
                        if (!deviceType) {
                            searchRelativeView.addView(videoMenuTextView)
                        }

                        val spaceView = Space(applicationContext)
                        spaceView.minimumHeight = 4
                        searchScrollView.addView(spaceView)
                        searchScrollView.addView(searchRelativeView)
                    } catch (e: IOException) {
                        Log.e("IOException", e.toString())
                    } catch (e: JSONException) {
                        Log.e("JSONException", e.toString())
                    }
                }
            }
        }
    }

    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
    }
}