package h.lillie.reborntube

import android.content.Intent
import android.os.Bundle
import android.content.Context
import android.content.ClipboardManager
import android.content.pm.PackageManager
import android.widget.RelativeLayout
import android.os.StrictMode
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import com.google.gson.Gson
import kotlin.system.exitProcess
import com.google.android.material.bottomnavigation.BottomNavigationView

class Main : AppCompatActivity() {

    private var hasRan = 0
    private var hasCreated = 0

    private var deviceType: Boolean = false
    private var deviceHeight = 0
    private var deviceWidth = 0
    @Suppress("Deprecation")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main)
        getDeviceInfo()
        if (deviceType == true) {
            val mainLayout: RelativeLayout = findViewById(R.id.mainLayout)
            val params = mainLayout.layoutParams as ViewGroup.MarginLayoutParams
            params.setMargins(38,26,38,26)
            mainLayout.layoutParams = params
        }

        val policy = StrictMode.ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)

        val topNavigationView: BottomNavigationView = findViewById(R.id.topNavigationView)
        topNavigationView.setOnNavigationItemSelectedListener(topNavigationViewListener)

        val bottomNavigationView: BottomNavigationView = findViewById(R.id.bottomNavigationView)
        bottomNavigationView.setOnNavigationItemSelectedListener(bottomNavigationViewListener)
        supportFragmentManager.beginTransaction().replace(R.id.fragments, Fragments(0)).commit()

        hasCreated = 1
    }

    override fun onDestroy() {
        super.onDestroy()
        finish()
        exitProcess(0)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus && hasRan == 0 && hasCreated == 1) {
            hasRan = 1
            if (intent.action.equals(Intent.ACTION_SEND)) {
                if (intent.type != null) {
                    if (intent.type.toString().startsWith("text/")) {
                        val receivedText = intent.getStringExtra(Intent.EXTRA_TEXT);
                        if (receivedText != null) {
                            getInfo(receivedText)
                            return
                        }
                    }
                }
            }
            getInfo(null)
        }
    }

    @Suppress("Deprecation")
    private fun getDeviceInfo() {
        deviceType = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) || packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        deviceHeight = windowManager.currentWindowMetrics.bounds.height()
        deviceWidth = windowManager.currentWindowMetrics.bounds.width()
    }

    @Suppress("Deprecation")
    private val topNavigationViewListener = BottomNavigationView.OnNavigationItemSelectedListener { item ->
        when(item.itemId) {
            R.id.action_search -> {
                val intent = Intent(this@Main, Search::class.java)
                startActivity(intent)
            }
            R.id.action_settings -> {
                getInfo("https://youtu.be/kSOEbBTvU7Q")
            }
        }
        true
    }

    @Suppress("Deprecation")
    private val bottomNavigationViewListener = BottomNavigationView.OnNavigationItemSelectedListener { item ->
        lateinit var selectedFragment: Fragment
        when(item.itemId) {
            R.id.action_home -> {
                selectedFragment = Fragments(0)
            }
            R.id.action_subscriptions -> {
                selectedFragment = Fragments(1)
            }
            R.id.action_history -> {
                selectedFragment = Fragments(2)
            }
            R.id.action_playlists -> {
                selectedFragment = Fragments(3)
            }
            R.id.action_downloads -> {
                selectedFragment = Fragments(4)
            }
        }
        supportFragmentManager.beginTransaction().replace(R.id.fragments, selectedFragment).commit()
        true
    }

    private fun getInfo(text: String?) {
        var info = String()
        if (text == null) {
            val clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            info = clipboardManager.primaryClip?.getItemAt(0)?.text.toString()
        } else {
            info = text
        }
        val youtubeRegex = Regex("^.*(?:(?:youtu\\.be\\/|v\\/|vi\\/|u\\/\\w\\/|embed\\/|shorts\\/|live\\/)|(?:(?:watch)?\\?v(?:i)?=|\\&v(?:i)?=))([^#\\&\\?]*).*")
        val check = youtubeRegex.containsMatchIn(info)
        if (check) {
            val result = youtubeRegex.findAll(info).map { it.groupValues[1] }.joinToString()

            val extractor = Extractor()
            val playerRequest = extractor.playerRequest(applicationContext, result)
            val dislikesRequest = extractor.returnYouTubeDislikesRequest(result)
            val sponsorBlockRequest = extractor.sponsorBlockRequest(result)

            val loader = Loader()
            val loaderPlayerInfo = loader.playerInit(playerRequest)
            val loaderDislikesInfo = loader.dislikesInit(dislikesRequest)

            val gson = Gson()
            Application.setVideoData(gson.toJson(Data(
                loaderPlayerInfo[0].toString(),
                loaderPlayerInfo[1].toString(),
                sponsorBlockRequest,
                loaderPlayerInfo[2].toString(),
                loaderPlayerInfo[3].toString(),
                loaderPlayerInfo[4].toString(),
                loaderPlayerInfo[5].toString(),
                loaderPlayerInfo[6].toString().toBoolean(),
                loaderDislikesInfo[0].toString(),
                loaderDislikesInfo[1].toString()
            )))

            val intent = Intent(this@Main, Player::class.java)
            startActivity(intent)
        }
    }
}