package h.lillie.reborntube

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.util.TypedValue
import androidx.fragment.app.Fragment
import androidx.core.content.res.ResourcesCompat
import android.widget.ImageView
import android.widget.TextView
import android.widget.RelativeLayout
import android.widget.LinearLayout
import android.widget.Space
import android.view.View
import android.view.ViewGroup
import android.view.LayoutInflater
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

class Home : Fragment() {
    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view: View = inflater.inflate(R.layout.home, container, false)

        getDeviceInfo()

        val applicationContext = activity?.applicationContext
        if (applicationContext != null) {
            val homeScrollView: LinearLayout = view.findViewById(R.id.homeScrollLayout)
            homeScrollView.removeAllViews()

            val extractor = Extractor()
            val browseRequest = extractor.browseRequest(applicationContext, "FEtrending", null)
            val jsonObject = JSONObject(browseRequest)

            val browseContents: JSONArray = jsonObject.getJSONObject("contents").getJSONObject("singleColumnBrowseResultsRenderer").getJSONArray("tabs").getJSONObject(0).getJSONObject("tabRenderer").getJSONObject("content").getJSONObject("sectionListRenderer").getJSONArray("contents")

            for (i in 0 until browseContents.length()) {
                try {
                    val homeRelativeView = RelativeLayout(applicationContext)
                    homeRelativeView.layoutParams = RelativeLayout.LayoutParams(deviceWidth, 200)
                    homeRelativeView.setBackgroundColor(applicationContext.getColor(R.color.darkgrey))

                    val videoID: String = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("navigationEndpoint").getJSONObject("watchEndpoint").optString("videoId").toString()
                    val videoTitle: String = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("headline").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                    val videoArtworkArray = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("thumbnail").getJSONArray("thumbnails")
                    val videoArtworkUrl: String = videoArtworkArray.getJSONObject((videoArtworkArray.length() - 1)).optString("url").toString()
                    val videoAuthor: String = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("shortBylineText").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                    val videoTime: String = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("lengthText").getJSONArray("runs").getJSONObject(0).optString("text").toString()
                    val videoViewCount = browseContents.getJSONObject(i).getJSONObject("itemSectionRenderer").getJSONArray("contents").getJSONObject(0).getJSONObject("videoWithContextRenderer").getJSONObject("shortViewCountText").getJSONArray("runs").getJSONObject(0).optString("text").toString()

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
                    videoTimeTextView.typeface = ResourcesCompat.getFont(applicationContext, R.font.opensans_regular)
                    videoTimeTextView.gravity = Gravity.CENTER
                    videoTimeTextView.setTextColor(applicationContext.getColor(R.color.white))
                    videoTimeTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)
                    videoTimeTextView.setBackgroundColor(applicationContext.getColor(R.color.blackdimmed))

                    val videoTitleTextView = TextView(applicationContext)
                    videoTitleTextView.layoutParams = LinearLayout.LayoutParams(deviceWidth - 190, 160)
                    videoTitleTextView.x = 190f
                    videoTitleTextView.text = videoTitle
                    videoTitleTextView.typeface = ResourcesCompat.getFont(applicationContext, R.font.opensans_regular)
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
                    videoViewCountAuthorTextView.typeface = ResourcesCompat.getFont(applicationContext, R.font.opensans_regular)
                    videoViewCountAuthorTextView.gravity = Gravity.CENTER_VERTICAL
                    videoViewCountAuthorTextView.setTextColor(applicationContext.getColor(R.color.white))
                    videoViewCountAuthorTextView.setAutoSizeTextTypeUniformWithConfiguration(1, 18, 1, TypedValue.COMPLEX_UNIT_DIP)

                    val videoMenuTextView = TextView(applicationContext)
                    videoMenuTextView.layoutParams = LinearLayout.LayoutParams(80, 40)
                    videoMenuTextView.x = deviceWidth - 80f
                    videoMenuTextView.y = 160f
                    videoMenuTextView.text = "•••"
                    videoMenuTextView.typeface = ResourcesCompat.getFont(applicationContext, R.font.opensans_regular)
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
                                    val intent = Intent(applicationContext, Player::class.java)
                                    startActivity(intent)
                                } else if (deviceType) {
                                    val intent = Intent(applicationContext, TVPlayer::class.java)
                                    startActivity(intent)
                                }
                            }
                        }
                    }
                    homeRelativeView.addView(videoImageView)
                    homeRelativeView.addView(videoTimeTextView)
                    homeRelativeView.addView(videoTitleTextView)
                    homeRelativeView.addView(videoViewCountAuthorTextView)
                    homeRelativeView.addView(videoButton)
                    if (!deviceType) {
                        homeRelativeView.addView(videoMenuTextView)
                    }

                    val spaceView = Space(applicationContext)
                    spaceView.minimumHeight = 4
                    homeScrollView.addView(spaceView)
                    homeScrollView.addView(homeRelativeView)
                } catch (e: IOException) {
                    Log.e("IOException", e.toString())
                } catch (e: JSONException) {
                    Log.e("JSONException", e.toString())
                }
            }
        }

        return view
    }

    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        val packageManager = context?.packageManager
        val windowManager = activity?.windowManager
        if (packageManager != null) {
            deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        }
        if (windowManager != null) {
            deviceHeight = windowManager.currentWindowMetrics.bounds.height()
            deviceWidth = windowManager.currentWindowMetrics.bounds.width()
        }
    }
}