package com.example.cts

import android.os.Bundle
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.text.textembedder.TextEmbedder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {

    private lateinit var methodChannelResult: MethodChannel.Result
    private val baseOptionsBuilder = BaseOptions.builder()
        .setModelAssetPath("universal_sentence_encoder.tflite")
    private val baseOptions = baseOptionsBuilder.build()

    private val optionsBuilder = TextEmbedder.TextEmbedderOptions.builder()
        .setBaseOptions(baseOptions)
    private val options = optionsBuilder.build()

    private var textEmbedder: TextEmbedder? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        textEmbedder = TextEmbedder.createFromOptions(this, options)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "textPlatform"
        ).setMethodCallHandler { call, result ->
            methodChannelResult = result
            when (call.method) {
                "checkEmbedding" -> {
                    val data = call.argument<String>("data")
                    val data2 = call.argument<String>("data1")

                    val firstEmbed = textEmbedder?.embed(data)?.embeddingResult()?.embeddings()?.first()
                    val secondEmbed = textEmbedder?.embed(data2)?.embeddingResult()?.embeddings()?.first()

                    val similarity = TextEmbedder.cosineSimilarity(firstEmbed, secondEmbed)
                    methodChannelResult.success(similarity.toString())
                }
                else -> result.notImplemented()
            }
        }
    }
}

