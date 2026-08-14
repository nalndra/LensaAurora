import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

/// Web implementation of the SpeechToText platform interface. This supports
/// the speech to text functionality running in web browsers that have
/// SpeechRecognition support, including Safari's vendor-prefixed
/// `webkitSpeechRecognition`.
class SpeechToTextPlugin extends SpeechToTextPlatform {
  html.SpeechRecognition? _webSpeech;
  static const _doneNoResult = 'doneNoResult';
  bool _resultSent = false;
  bool _doneSent = false;

  /// Registers this class as the default instance of [UrlLauncherPlatform].
  static void registerWith(Registrar registrar) {
    SpeechToTextPlatform.instance = SpeechToTextPlugin();
  }

  /// True if the standard (unprefixed) `SpeechRecognition` API is available.
  static bool get _hasStandardSpeechRecognition =>
      html.SpeechRecognition.supported;

  /// True if only the vendor-prefixed `webkitSpeechRecognition` (Safari) is
  /// available.
  static bool get _hasWebkitSpeechRecognition =>
      js_util.getProperty(html.window, 'webkitSpeechRecognition') != null;

  /// Returns true if the user has already granted permission to access the
  /// microphone, does not prompt the user.
  ///
  /// This method can be called before [initialize] to check if permission
  /// has already been granted. If this returns false then the [initialize]
  /// call will prompt the user for permission if it is allowed to do so.
  /// Note that applications cannot ask for permission again if the user has
  /// denied them permission in the past.
  @override
  Future<bool> hasPermission() async {
    return _hasStandardSpeechRecognition || _hasWebkitSpeechRecognition;
  }

  /// Initialize speech recognition services, returns true if
  /// successful, false if failed.
  ///
  /// This method must be called before any other speech functions.
  /// If this method returns false no further [SpeechToText] methods
  /// should be used. False usually means that the user has denied
  /// permission to use speech.
  ///
  /// Supports both the standard `SpeechRecognition` API and Safari's
  /// vendor-prefixed `webkitSpeechRecognition`.
  ///
  /// [debugLogging] controls whether there is detailed logging from the underlying
  /// plugins. It is off by default, usually only useful for troubleshooting issues
  /// with a paritcular OS version or device, fairly verbose
  @override
  Future<bool> initialize(
      {debugLogging = false, List<SpeechConfigOption>? options}) async {
    final hasStandard = _hasStandardSpeechRecognition;
    final hasWebkit = _hasWebkitSpeechRecognition;
    if (!hasStandard && !hasWebkit) {
      var error = SpeechRecognitionError('not supported', true);
      onError?.call(jsonEncode(error.toJson()));
      return false;
    }

    var initialized = false;
    try {
      _webSpeech =
          hasStandard ? html.SpeechRecognition() : _createWebkitSpeechRecognition();
      if (null != _webSpeech) {
        _webSpeech!.onError.listen((error) => _onError(error));
        _webSpeech!.onStart.listen((startEvent) => _onSpeechStart(startEvent));
        _webSpeech!.onEnd.listen((endEvent) => _onSpeechEnd(endEvent));
        _webSpeech!.onNoMatch
            .listen((noMatchEvent) => _onNoMatch(noMatchEvent));
        initialized = true;
      }
    } finally {
      if (null == _webSpeech) {
        if (null != onError) {
          var error = SpeechRecognitionError('speech_not_supported', true);
          onError!(jsonEncode(error.toJson()));
        }
      }
    }
    return initialized;
  }

  /// Constructs a `webkitSpeechRecognition` instance for browsers (Safari)
  /// that only expose the vendor-prefixed API.
  html.SpeechRecognition? _createWebkitSpeechRecognition() {
    final ctor = js_util.getProperty(html.window, 'webkitSpeechRecognition');
    if (ctor == null) return null;
    final obj = js_util.callConstructor(ctor, []);
    return obj as html.SpeechRecognition?;
  }

  /// Stops the current listen for speech if active, does nothing if not.
  ///
  /// Stopping a listen session will cause a final result to be sent. Each
  /// listen session should be ended with either [stop] or [cancel], for
  /// example in the dispose method of a Widget. [cancel] is automatically
  /// invoked by a permanent error if [cancelOnError] is set to true in the
  /// [listen] call.
  ///
  /// *Note:* Cannot be used until a successful [initialize] call. Should
  /// only be used after a successful [listen] call.
  @override
  Future<void> stop() async {
    if (null == _webSpeech) return;
    _webSpeech!.stop();
  }

  /// Cancels the current listen for speech if active, does nothing if not.
  ///
  /// Canceling means that there will be no final result returned from the
  /// recognizer. Each listen session should be ended with either [stop] or
  /// [cancel], for example in the dispose method of a Widget. [cancel] is
  /// automatically invoked by a permanent error if [cancelOnError] is set
  /// to true in the [listen] call.
  ///
  /// *Note* Cannot be used until a successful [initialize] call. Should only
  /// be used after a successful [listen] call.
  @override
  Future<void> cancel() async {
    if (null == _webSpeech) return;
    _webSpeech!.abort();
  }

  /// Starts a listening session for speech and converts it to text.
  ///
  /// Cannot be used until a successful [initialize] call. There is a
  /// time limit on listening imposed by both Android and iOS. The time
  /// depends on the device, network, etc. Android is usually quite short,
  /// especially if there is no active speech event detected, on the order
  /// of ten seconds or so.
  ///
  /// [localeId] is an optional locale that can be used to listen in a language
  /// other than the current system default. See [locales] to find the list of
  /// supported languages for listening.
  ///
  /// [partialResults] if true the listen reports results as they are recognized,
  /// when false only final results are reported. Defaults to true.
  ///
  /// [onDevice] if true the listen attempts to recognize locally with speech never
  /// leaving the device. If it cannot do this the listen attempt will fail. This is
  /// usually only needed for sensitive content where privacy or security is a concern.
  ///
  /// [sampleRate] optional for compatibility with certain iOS devices, some devices
  /// crash with `sampleRate != device's supported sampleRate`, try 44100 if seeing
  /// crashes
  ///
  /// [options] newer replacement for the individual deprecated parameters above.
  @override
  Future<bool> listen(
      {String? localeId,
      partialResults = true,
      onDevice = false,
      int listenMode = 0,
      sampleRate = 0,
      SpeechListenOptions? options}) async {
    if (null == _webSpeech) return false;
    _webSpeech!.onResult.listen((speechEvent) => _onResult(speechEvent));
    _webSpeech!.interimResults = options?.partialResults ?? partialResults;
    _webSpeech!.continuous = options?.partialResults ?? partialResults;
    final locale = options?.localeId ?? localeId;
    if (null != locale) {
      _webSpeech!.lang = locale;
    }
    _doneSent = false;
    _resultSent = false;
    _webSpeech!.start();
    return true;
  }

  /// Returns the list of speech locales available on the device.
  @override
  Future<List<dynamic>> locales() async {
    var availableLocales = [];
    var lang = _webSpeech?.lang;
    if (null != lang && lang.isNotEmpty) {
      lang = lang.replaceAll(':', '_');
      availableLocales.add('$lang:$lang');
    }
    return availableLocales;
  }

  void _onError(html.SpeechRecognitionError event) {
    if (null != event.error) {
      var error = SpeechRecognitionError(event.error!, false);
      onError?.call(jsonEncode(error.toJson()));
      _sendDone(_doneNoResult);
    }
  }

  void _onSpeechStart(html.Event event) {
    onStatus?.call('listening');
  }

  void _onSpeechEnd(html.Event event) {
    onStatus?.call('notListening');
    _sendDone(_resultSent ? 'done' : _doneNoResult);
  }

  void _onNoMatch(html.Event event) {
    _sendDone(_doneNoResult);
  }

  void _sendDone(String status) {
    if (_doneSent) return;
    onStatus?.call(status);
    _doneSent = true;
  }

  void _onResult(html.SpeechRecognitionEvent event) {
    var isFinal = false;
    var recogResults = <SpeechRecognitionWords>[];
    var results = event.results;
    if (null == results) return;
    for (var recognitionResult in results) {
      if (null == recognitionResult.length || recognitionResult.length == 0) {
        continue;
      }
      for (var altIndex = 0; altIndex < recognitionResult.length!; ++altIndex) {
        var alt = js_util.callMethod(recognitionResult, 'item', [altIndex]);
        if (null == alt) continue;
        String? transcript = js_util.getProperty(alt, 'transcript');
        num? confidence = js_util.getProperty(alt, 'confidence');
        if (null != transcript && null != confidence) {
          recogResults
              .add(SpeechRecognitionWords(transcript, confidence.toDouble()));
        }
      }
    }
    var result = SpeechRecognitionResult(recogResults, isFinal);
    onTextRecognition?.call(jsonEncode(result.toJson()));
    _resultSent = true;
  }
}
