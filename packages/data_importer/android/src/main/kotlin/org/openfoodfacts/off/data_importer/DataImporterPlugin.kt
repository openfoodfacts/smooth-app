package org.openfoodfacts.off.data_importer

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.openfoodfacts.off.data_importer.DataImporterPlugin.Companion.LOGIN_PREFERENCES

/** DataImporterPlugin */
class DataImporterPlugin: FlutterPlugin, MethodCallHandler {

  companion object {
    const val LOGIN_PREFERENCES = "login"
  }

  private lateinit var channel : MethodChannel
  private var context : Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "data_importer")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val loginPreferences = getLoginPreferences()
    if (loginPreferences == null) {
      result.error("SP", "Shared Preferences don't exist!", "")
      return
    }

    when (call.method) {
        "getUser" -> {
          loginPreferences.apply {
            val user =  getString("user", null)
            val password =  getString("pass", null)

            result.success(mapOf("user" to user, "password" to password))
          }
        }
        "clearOldData" -> {
          loginPreferences.run {
            edit().clear().apply()
            result.success(true)
          }
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  private fun getLoginPreferences() =
    context?.getSharedPreferences(LOGIN_PREFERENCES, Context.MODE_PRIVATE)

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
  }
}
