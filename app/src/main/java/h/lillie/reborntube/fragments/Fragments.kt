package h.lillie.reborntube.fragments

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import h.lillie.reborntube.R

class Fragments(private val tab: Int) : Fragment() {
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view: View = inflater.inflate(R.layout.fragments, container, false)
        val textView: TextView = view.findViewById(R.id.fragmentsTextView)
        if (tab == 1) {
            textView.text = "Subscriptions"
        }
        if (tab == 2) {
            textView.text = "History"
        }
        if (tab == 3) {
            textView.text = "Playlists"
        }
        if (tab == 4) {
            textView.text = "Downloads"
        }
        return view
    }
}