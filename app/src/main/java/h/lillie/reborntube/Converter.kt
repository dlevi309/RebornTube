package h.lillie.reborntube

import android.content.Context
import android.util.DisplayMetrics

class Converter {
    fun pxToDp(context: Context, px: Float) : Float {
        return px / (context.resources.displayMetrics.densityDpi.toFloat() / DisplayMetrics.DENSITY_DEFAULT)
    }

    fun dpToPx(context: Context, dp: Float) : Float {
        return dp * (context.resources.displayMetrics.densityDpi.toFloat() / DisplayMetrics.DENSITY_DEFAULT)
    }
}