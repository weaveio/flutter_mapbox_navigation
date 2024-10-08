package com.eopeter.flutter_mapbox_navigation.models

import com.google.gson.*
import com.mapbox.navigation.base.trip.model.RouteProgress

class MapBoxRouteProgressEvent(progress: RouteProgress) {

    var arrived: Boolean? = null
    private var distance: Float? = null
    private var duration: Double? = null
    private var distanceTraveled: Float? = null
    var currentLegDistanceTraveled: Float? = null
    var currentLegDistanceRemaining: Float? = null
    var currentStepInstruction: String? = null
    var legIndex: Int? = null
    var stepIndex: Int? = null
    var currentLeg: MapBoxRouteLeg? = null
    var priorLeg: MapBoxRouteLeg? = null
    lateinit var remainingLegs: List<MapBoxRouteLeg>

    init {
        //val util = RouteUtils()
        //arrived = util.isArrivalEvent(progress) && util.isLastLeg(progress)
        distance = progress.distanceRemaining
        duration = progress.durationRemaining
        distanceTraveled = progress.distanceTraveled
        legIndex = progress.currentLegProgress?.legIndex
        //stepIndex = progress.stepIndex
        val leg = progress.currentLegProgress?.routeLeg
        if (leg != null)
            currentLeg = MapBoxRouteLeg(leg)
        currentStepInstruction = progress.bannerInstructions?.primary()?.text()
        currentLegDistanceTraveled = progress.currentLegProgress?.distanceTraveled
        currentLegDistanceRemaining = progress.currentLegProgress?.distanceRemaining
    }

    fun toJson(): String {
        return Gson().toJson(toJsonObject())
    }

    fun toJsonObject(): JsonObject {
        val json = JsonObject();
        addProperty(json, "distance", distance);
        addProperty(json, "duration", duration);
        addProperty(json, "distanceTraveled", distanceTraveled);
        addProperty(json, "legIndex", legIndex);
        addProperty(json, "currentLegDistanceRemaining", currentLegDistanceRemaining);
        addProperty(json, "currentLegDistanceTraveled", currentLegDistanceTraveled);
        addProperty(json,"currentStepInstruction", currentStepInstruction);

        if (currentLeg != null) {
            json.add("currentLeg", currentLeg!!.toJsonObject())
        }

        return json
    }

    private fun addProperty(json: JsonObject, prop: String, value: Double?) {
        if (value != null) {
            json.addProperty(prop, value);
        }
    }

    private fun addProperty(json: JsonObject, prop: String, value: Int?) {
        if (value != null) {
            json.addProperty(prop, value);
        }
    }

    private fun addProperty(json: JsonObject, prop: String, value: String?) {
        if (value?.isNotEmpty() == true) {
            json.addProperty(prop, value);
        }
    }

    private fun addProperty(json: JsonObject, prop: String, value: Float?) {
        if (value != null) {
            json.addProperty(prop, value);
        }
    }
}