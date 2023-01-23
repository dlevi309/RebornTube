package h.lillie.reborntube.playerapi

import retrofit2.Call
import retrofit2.http.Headers
import retrofit2.http.POST
import retrofit2.http.Body

interface PlayerApiRequest {
    @Headers("Content-Type: application/json")
    @POST("/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false")
    fun getPlayerApiValues(@Body body: String): Call<PlayerApiValues>
}