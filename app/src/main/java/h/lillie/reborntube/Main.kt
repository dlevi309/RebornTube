package h.lillie.reborntube

import android.content.Intent
import android.os.Bundle
import android.content.pm.PackageManager
import android.widget.RelativeLayout
import android.os.StrictMode
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import kotlin.system.exitProcess
import com.google.android.material.bottomnavigation.BottomNavigationView

class Main : AppCompatActivity() {

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
    }

    override fun onDestroy() {
        super.onDestroy()
        finish()
        exitProcess(0)
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
}