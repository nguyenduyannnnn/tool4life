package annd.personal.toolforlife

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    
    private val RECORDING_NOTIFICATION_CHANNEL = "changmeeting/recording_notification"
    private val RECORDING_NOTIFICATION_EVENTS = "changmeeting/recording_notification_events"
    private val BACKGROUND_UPLOAD_CHANNEL = "changmeeting/background_upload"
    private val BACKGROUND_UPLOAD_EVENTS = "changmeeting/background_upload_events"
    
    private var eventSink: EventChannel.EventSink? = null
    private var uploadEventSink: EventChannel.EventSink? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Required for flutter_web_auth_2 to properly receive the OAuth callback
        // when the app is already running (Chrome Custom Tab sends intent back here)
        setIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup recording notification method channel
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RECORDING_NOTIFICATION_CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startNotification" -> {
                    startRecordingNotification()
                    result.success(true)
                }
                "updateDuration" -> {
                    val duration = call.argument<Int>("duration") ?: 0
                    updateNotificationDuration(duration)
                    result.success(true)
                }
                "stopNotification" -> {
                    stopRecordingNotification()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Setup recording notification event channel
        val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, RECORDING_NOTIFICATION_EVENTS)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }
            
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
        
        // Setup background upload method channel
        val uploadMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKGROUND_UPLOAD_CHANNEL)
        uploadMethodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startUploadService" -> {
                    startUploadService()
                    result.success(true)
                }
                "updateUploadProgress" -> {
                    val fileName = call.argument<String>("fileName") ?: ""
                    val progress = call.argument<Double>("progress") ?: 0.0
                    updateUploadProgress(fileName, progress)
                    result.success(true)
                }
                "stopUploadService" -> {
                    stopUploadService()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Setup background upload event channel
        val uploadEventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, BACKGROUND_UPLOAD_EVENTS)
        uploadEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                uploadEventSink = events
            }
            
            override fun onCancel(arguments: Any?) {
                uploadEventSink = null
            }
        })
    }
    
    private fun startRecordingNotification() {
        val intent = Intent(this, RecordingNotificationService::class.java)
        startForegroundService(intent)
    }
    
    private fun updateNotificationDuration(duration: Int) {
        // Update notification through service instance
        val service = RecordingNotificationService.getInstance()
        service?.updateDuration(duration)
    }
    
    private fun stopRecordingNotification() {
        val intent = Intent(this, RecordingNotificationService::class.java)
        stopService(intent)
    }
    
    // Background Upload Service methods
    private fun startUploadService() {
        val intent = Intent(this, BackgroundUploadService::class.java)
        startForegroundService(intent)
    }
    
    private fun updateUploadProgress(fileName: String, progress: Double) {
        val service = BackgroundUploadService.getInstance()
        service?.updateProgress(fileName, progress)
    }
    
    private fun stopUploadService() {
        val intent = Intent(this, BackgroundUploadService::class.java)
        stopService(intent)
    }
}
