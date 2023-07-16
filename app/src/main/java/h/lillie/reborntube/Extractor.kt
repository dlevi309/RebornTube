package h.lillie.reborntube

import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import android.content.Context

class Extractor {
    fun playerRequest(context: Context, videoID: String) : String {
        val countryCode = context.resources.configuration.locales.get(0).country
        val body = """{
            "context": {
                "client": {
                    "hl": "en",
                    "gl": "$countryCode",
                    "clientName": "IOS",
                    "clientVersion": "18.17.2",
                    "deviceModel": "iPhone14,3",
                    "playbackContext": {
                        "contentPlaybackContext": {
                            "vis": 0,
                            "splay": false,
                            "autoCaptionsDefaultOn": false,
                            "autonavState": "STATE_OFF",
                            "signatureTimestamp": "sts",
                            "html5Preference": "HTML5_PREF_WANTS",
                            "lactMilliseconds": "-1"
                        }
                    }
                }
            },
            "contentCheckOk": false,
            "racyCheckOk": false,
            "videoId": "$videoID"
        }"""

        val requestBody = body.trimIndent().toRequestBody()

        val client: OkHttpClient = OkHttpClient.Builder().build()

        val request = Request.Builder()
            .method("POST", requestBody)
            .url("https://www.youtube.com/youtubei/v1/player?key=AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc&prettyPrint=false")
            .build()

        return client.newCall(request).execute().body.string()
    }

    fun browseRequest(context: Context, browseID: String, params: String) : String {
        val countryCode = context.resources.configuration.locales.get(0).country
        val body = """{
            "context": {
                "client": {
                    "hl": "en",
                    "gl": "$countryCode",
                    "clientName": "IOS",
                    "clientVersion": "18.17.2",
                    "deviceModel": "iPhone14,3",
                    "playbackContext": {
                        "contentPlaybackContext": {
                            "vis": 0,
                            "splay": false,
                            "autoCaptionsDefaultOn": false,
                            "autonavState": "STATE_OFF",
                            "signatureTimestamp": "sts",
                            "html5Preference": "HTML5_PREF_WANTS",
                            "lactMilliseconds": "-1"
                        }
                    }
                }
            },
            "contentCheckOk": false,
            "racyCheckOk": false,
            "browseId": "$browseID",
            "params": "$params"
        }"""

        val requestBody = body.trimIndent().toRequestBody()

        val client: OkHttpClient = OkHttpClient.Builder().build()

        val request = Request.Builder()
            .method("POST", requestBody)
            .url("https://www.youtube.com/youtubei/v1/browse?key=AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc&prettyPrint=false")
            .build()

        return client.newCall(request).execute().body.string()
    }

    fun searchRequest(context: Context, query: String) : String {
        val countryCode = context.resources.configuration.locales.get(0).country
        val body = """{
            "context": {
                "client": {
                    "hl": "en",
                    "gl": "$countryCode",
                    "clientName": "WEB",
                    "clientVersion": "2.20220801.00.00",
                    "playbackContext": {
                        "contentPlaybackContext": {
                            "vis": 0,
                            "splay": false,
                            "autoCaptionsDefaultOn": false,
                            "autonavState": "STATE_OFF",
                            "signatureTimestamp": "sts",
                            "html5Preference": "HTML5_PREF_WANTS",
                            "lactMilliseconds": "-1"
                        }
                    }
                }
            },
            "contentCheckOk": false,
            "racyCheckOk": false,
            "query": "$query"
        }"""

        val requestBody = body.trimIndent().toRequestBody()

        val client: OkHttpClient = OkHttpClient.Builder().build()

        val request = Request.Builder()
            .method("POST", requestBody)
            .url("https://www.youtube.com/youtubei/v1/search?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false")
            .build()

        return client.newCall(request).execute().body.string()
    }

    fun returnYouTubeDislikesRequest(videoID: String) : String {
        val client: OkHttpClient = OkHttpClient.Builder().build()

        val request = Request.Builder()
            .method("GET", null)
            .url("https://returnyoutubedislikeapi.com/votes?videoId=$videoID")
            .build()

        return client.newCall(request).execute().body.string()
    }

    fun sponsorBlockRequest(videoID: String) : String {
        val categories = "[%22sponsor%22,%22selfpromo%22,%22interaction%22,%22intro%22,%22outro%22,%22preview%22,%22music_offtopic%22]"
        val client: OkHttpClient = OkHttpClient.Builder().build()

        val request = Request.Builder()
            .method("GET", null)
            .url("https://sponsor.ajay.app/api/skipSegments?videoID=$videoID&categories=$categories")
            .build()

        return client.newCall(request).execute().body.string()
    }
}