import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data'; // 直接导入 BytesBuilder

import 'package:fepe_record/record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';
import 'package:kplayer/kplayer.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_encrypt/smart_encrypt.dart';
import 'package:stacked/stacked.dart';

import 'sesame_viewmodel.dart';

class SesameView extends StackedView<SesameViewModel> {
  const SesameView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SesameViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<String>(
        future: viewModel.getValidIdToken(), // 异步获取 idToken
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 如果正在等待异步结果，显示加载中
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 如果发生错误，显示错误信息
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // 如果有数据，显示 idToken 和 Hello World
            return PcmSoundApp(idToken: snapshot.data!);
          } else {
            // 如果没有数据，显示一个空白界面
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  @override
  SesameViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SesameViewModel();
}

class PcmSoundApp extends StatefulWidget {
  final String idToken;
  const PcmSoundApp({super.key, required this.idToken});
  @override
  PcmSoundAppState createState() => PcmSoundAppState(); // Change here
}

class PcmSoundAppState extends State<PcmSoundApp>
    with SingleTickerProviderStateMixin {
  late WebSocketClient client;

  int intValue = 0; // 用来存储用户选择的数字

  final record = AudioRecorder();
  int executeCount = 0; // 用来计数执行次数
  late String chunkSize = "初始录音值";
  late String uuuchunkSize = "初始sesame值";
  bool iscollect = false;
  bool isMute = false;

  // 动画变量
  double animationValue = 0;
  double expandValue = 0;
  double rmsValue = 0;
  double ringWidthFactor = 0;
  int ringWidthFactorDirection = 1;
  double ringWidthFactorSpeed = 0.02;
  double randomFactor = 0;

  // 用于定时刷新动画
  late final Ticker _ticker;
  final Random _random = Random();

  // 用于接收流数据
  final StreamController<double> _rmsStreamController =
      StreamController<double>();

  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 在构建完成后执行异步操作
    client = WebSocketClient(idToken: widget.idToken, character: "Maya");
    // FlutterPcmSound.setFeedCallback(_onFeed);
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      Permission.microphone.request().isGranted.then((value) async {
        if (!value) {
          await [Permission.microphone].request();
        }
      });
    }
    _ticker = createTicker(_tick)..start();

    // 监听RMS值流并更新视图
    _rmsStreamController.stream.listen((rms) {
      setState(() {
        rmsValue = rms;
      });
    });

    client.setgetchunkcallback((event) async {
      // 判断是否为静音数据，可以根据数据的最大幅度来做判断
      if (_isSilent(event)) {
        _rmsStreamController.add(0);
      } else {
        _rmsStreamController.add(_computeRms(event)); // 将计算的 RMS 值发送到流中
      }
      print("来到UI的数据长度${event.lengthInBytes}");
    });
    // 设置连接回调
    client.setConnectCallback(() {
      print("Connected to SesameAI!");
    });

    client.setDisconnectCallback(() {
      print("Disconnected from SesameAI!");
    });
  }

  @override
  void dispose() {
    client._onClose();
    record.dispose();
    _ticker.dispose();
    _rmsStreamController.close();
    super.dispose();
  }

  /// 判断是否为静音数据
  bool _isSilent(List<int> data) {
    // 判断是否是静音数据（大多数数据值接近 0）
    int silentThreshold = 5; // 设置一个阈值，当绝大部分数据都小于此阈值时认为是静音
    int silentCount = data.where((e) => e.abs() <= silentThreshold).length;

    // 如果大部分数据都接近零，则认为是静音
    return silentCount > data.length * 0.5; // 超过 80% 的数据是静音数据
  }

  // 每帧更新动画参数
  void _tick(Duration elapsed) {
    setState(() {
      animationValue += 0.01;
      expandValue += 0.016;
      if (expandValue > 1) expandValue = 0;

      // 控制圆环宽度变化
      randomFactor = _random.nextDouble() * 0.05;
      ringWidthFactorSpeed = 0.02 + randomFactor * 0.5;
      ringWidthFactor += ringWidthFactorSpeed * ringWidthFactorDirection;

      // 这里使用 easing 函数处理（类似于原代码中的 sin 和幂运算）
      const easingFactor = 0.7;
      // 调整 ringWidthFactor 和 rmsValue 的关系
      ringWidthFactor = sin(
        pow(ringWidthFactor.clamp(0, 1), 1 / easingFactor) * (pi / 2),
      ); // rmsValue * 0.5 用来增加震动幅度

      if (ringWidthFactor >= 1) {
        ringWidthFactor = 1;
        ringWidthFactorDirection = -1;
      } else if (ringWidthFactor <= 0) {
        ringWidthFactor = 0;
        ringWidthFactorDirection = 1;
      }
    });
  }

  /// 计算 RMS 值
  double _computeRms(Uint8List data) {
    final normalized =
        data.map((e) => (e - 128) / 128.0).toList(); // 转换到 -1 ~ 1
    final sumOfSquares = normalized.fold(
      0.0,
      (prev, element) => prev + element * element,
    );
    return sqrt(sumOfSquares / normalized.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(300),
                child: InkWell(
                  borderRadius: BorderRadius.circular(300),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    if (iscollect) {
                      if (!Platform.isWindows) {}
                      setState(() {
                        _rmsStreamController.add(0); // 重置 rms 值
                      });
                      return;
                    }
                    if (!iscollect) {
                      setState(() {
                        iscollect = true;
                      });
                      try {
                        if (!Platform.isWindows) {
                          if (await record.hasPermission() &&
                              Platform.isAndroid) {
                            final stream = await record.startStream(
                              const RecordConfig(
                                encoder: AudioEncoder.pcm16bits,
                                numChannels: 1,
                                sampleRate: 16000,
                                echoCancel: true,
                              ),
                            );
                            stream.listen(
                              (chunk) {
                                client.sendAudioData(chunk);
                                setState(() {
                                  chunkSize = '环境声音: ${chunk.lengthInBytes} 字节';
                                });
                                debugPrint(chunkSize);
                              },
                              onError: (error) {
                                record.dispose();
                                debugPrint('音频流错误: $error');
                              },
                              onDone: () {
                                debugPrint('音频流结束');
                              },
                              cancelOnError: true, // 遇到错误时自动取消订阅
                            );
                          }
                        }
                        try {
                          await connectToWebSocket();
                        } catch (e) {
                          setState(() {
                            iscollect = false;
                          });
                          print("连接 WebSocket 失败: $e");
                        }
                      } on Exception catch (e) {
                        debugPrint('-------------- init() error: $e\n');
                      }
                    }
                  },
                  child: SizedBox(
                    width: 350,
                    height: 350,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: CustomPaint(
                            painter: WavePainter(
                              animationValue: animationValue,
                              expandValue: expandValue,
                              rmsValue: rmsValue,
                              ringWidthFactor: ringWidthFactor,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: !iscollect
                              ? Lottie.asset(
                                  'images/sesame.json',
                                  fit: BoxFit.fill,
                                )
                              : null,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (iscollect)
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Maya',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(width: 10),
                                        TimerWidget(isCollect: iscollect),
                                      ],
                                    ),
                                    const Text(
                                      'Sesame',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(
                                          169,
                                          181,
                                          110,
                                          0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (!iscollect)
                                const Text(
                                  '来自Sesame的语音',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            CallControlWidget(
              onMute: () async {
                HapticFeedback.mediumImpact();
                if (!Platform.isWindows && !isMute) {
                  setState(() {
                    isMute = !isMute;
                  });
                  print("isMute: $isMute");
                  await record.cancel();
                  return;
                }
                if (isMute) {
                  setState(() {
                    isMute = !isMute;
                  });
                  print("uuuisMute: $isMute");
                  if (await record.hasPermission() && Platform.isAndroid) {
                    final stream = await record.startStream(
                      const RecordConfig(
                        encoder: AudioEncoder.pcm16bits,
                        numChannels: 1,
                        sampleRate: 16500,
                        echoCancel: true,
                      ),
                    );
                    stream.listen(
                      (chunk) {
                        client.sendAudioData(chunk);
                        setState(() {
                          chunkSize = '环境声音: ${chunk.lengthInBytes} 字节';
                        });
                        debugPrint(chunkSize);
                      },
                      onError: (error) {
                        record.dispose();
                        debugPrint('音频流错误: $error');
                      },
                      onDone: () {
                        debugPrint('音频流结束');
                      },
                      cancelOnError: true, // 遇到错误时自动取消订阅
                    );
                  }
                }
                print("Mute button clicked");
              },
              onEndCall: () async {
                client._onClose();
                if (!Platform.isWindows) {
                  await record.cancel();
                }
                setState(() {
                  iscollect = false;
                  _rmsStreamController.add(0); // 重置 rms 值
                });
                return;
              },
            ),
            Text("信号的强度: $rmsValue"),
            Text(chunkSize),
            Text('是否正在录制: $iscollect'),
          ],
        ),
      ),
    );
  }

  // 重连机制
  Future<void> connectToWebSocket() async {
    /// Listen to audio data stream. The data is received as Uint8List.

    bool isConnected = false;

    while (!isConnected) {
      try {
        await client.connect();
        isConnected = true;
      } catch (e) {
        print("WebSocket 连接失败: $e");
        await Future.delayed(Duration(seconds: 5)); // 5秒后重试
      }
    }
  }
}

class WebSocketClient {
  final String idToken;
  String character;
  String clientName;

  // WebSocket connection
  WebSocket? ws;
  String? sessionId;
  dynamic callId;

  // Audio settings
  int clientSampleRate = 16000;
  int serverSampleRate = 24000; // Default, will be updated from server
  String audioCodec = 'none';

  // Connection state
  bool reconnect = false;
  bool isPrivate = false;
  String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36';

  final BytesBuilder bytesSink = BytesBuilder();
  final Queue<Uint8List> audioQueue = Queue<Uint8List>(); // 创建一个队列
  final int maxQueueSize = 14; // 限制队列最多存 10 个元素
  bool isPlaying = false;
  late dynamic bytesSinkbufferSize = 64 * 1024;
  // 记录上次接收数据的时间
  int lastReceivedTime = DateTime.now().millisecondsSinceEpoch;

  // Message tracking
  String? lastSentMessageType;
  bool receivedSinceLastSent = false;
  bool firstAudioReceived = false;

  // Callbacks
  Function()? onConnectCallback;
  Function()? onDisconnectCallback;
  late Function(Uint8List) uuuonGetChunkDataCallback;

  // 构造函数
  WebSocketClient({
    required this.idToken,
    this.character = 'Miles', // 默认值
    this.clientName = 'RP-Web', // 默认值
  }) {
    ws = null;
    sessionId = null;
    callId = null;

    // 初始化其他状态
    print('WebSocketClient initialized');
  }

  // 连接方法
  Future<bool> connect({bool blocking = true}) async {
    // Reset connection state

    // 启动 WebSocket 连接
    await _connectWebSocket();

    if (blocking) {
      // 等待连接完成（最多 10 秒）
      try {
        return true;
      } catch (e) {
        print('Connection timeout or error: $e');
        return false;
      }
    }

    // 非阻塞方式立即返回
    return true;
  }

  void listen() {
    print("WebSocket ready state: ${ws?.readyState}");
  }

  // 内部方法，用于建立 WebSocket 连接
  Future<void> _connectWebSocket() async {
    final HttpClient httpClient = HttpClient();

    // 忽略 SSL 验证
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    try {
      // 构造 WebSocket 连接参数
      final headers = {
        'accept-encoding': 'gzip, deflate, br, zstd',
        'accept-language': 'en-US,en;q=0.9',
        'host': 'sesameai.app',
        'Origin': 'https://www.sesame.com',
        'User-Agent': userAgent,
      };

      final params = {
        'id_token': idToken,
        'client_name': clientName,
        'usercontext': jsonEncode({"timezone": "America/Chicago"}),
        'character': character,
      };

      // 构造 WebSocket URL
      const baseUrl = 'wss://sesameai.app/agent-service-0/v1/connect';
      final queryString = params.entries.map((entry) {
        return '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}';
      }).join('&');
      final wsUrl = '$baseUrl?$queryString';

      ws = await WebSocket.connect(
        wsUrl,
        headers: headers,
        customClient: httpClient,
      );

      // 连接成功，触发连接回调
      _onOpen();

      // 监听 WebSocket 消息
      ws?.listen(_onMessage, onDone: _onClose, onError: _onError);
    } catch (e) {
      print('Failed to connect: $e');
    }
  }

  // WebSocket 连接成功时的回调
  void _onOpen() {
    print('WebSocket connection opened');
  }

  // WebSocket 接收到消息时调用
  void _onMessage(dynamic message) {
    try {
      // 解析 JSON 消息
      final data = jsonDecode(message);

      // 处理不同类型的消息
      final messageType = data['type'];
      final requestId = data['request_id'];
      final callId = data['call_id'];
      final sessionId = data['session_id'];
      print('接收 message type: $messageType');
      print("$sessionId, $callId, $requestId");

      switch (messageType) {
        case 'initialize':
          _handleInitialize(data);
          break;
        case 'call_connect_response':
          _handleCallConnectResponse(data);
          break;
        case 'ping_response':
          _handlePingResponse(data);
          break;
        case 'audio':
          _handleAudio(data);
          break;
        case 'call_disconnect_response':
          _handleCallDisconnectResponse(data);
          break;
        default:
          print('default message type: $messageType');
      }
    } catch (e) {
      print('Error handling message: $e');
      // 处理非 JSON 消息
      print('Received non-JSON message: $message');
    }
  }

  // WebSocket 错误时调用
  void _onError(error) {
    print('WebSocket error: $error');
  }

  // WebSocket 连接关闭时的回调
  void _onClose() {
    print('WebSocket closed');
    // 清除连接事件
    if (ws != null && ws?.readyState == WebSocket.open) {
      ws?.close();
    }
    // 调用断开连接回调（如果有设置）
    if (onDisconnectCallback != null) {
      onDisconnectCallback!();
    }
  }

  // 处理 'initialize' 消息类型
  void _handleInitialize(Map<String, dynamic> data) {
    sessionId = data['session_id'];

    // 发送客户端位置和呼叫连接
    _sendClientLocationState();
    _sendCallConnect();
  }

  // 处理 'call_connect_response' 消息类型
  void _handleCallConnectResponse(Map<String, dynamic> data) {
    sessionId = data['session_id'];
    callId = data['call_id'];

    final content = data['content'] as Map<String, dynamic>? ?? {};
    serverSampleRate = content['sample_rate'] ?? serverSampleRate;
    print(serverSampleRate);
    audioCodec = content['audio_codec'] ?? 'none';

    // 调用连接回调（如果已设置）
    onConnectCallback?.call();
  }

  // 处理 'ping_response' 消息类型
  void _handlePingResponse(Map<String, dynamic> data) {
    return;
  }

  // 处理 'audio' 消息类型
  Future<void> _handleAudio(Map<String, dynamic> data) async {
    final audioData = data['content']['audio_data'];

    if (audioData.isNotEmpty) {
      try {
        // if (_clearCompleter != null) {
        //   await _clearCompleter!.future; // 确保 `clear()` 已完成
        // }
        // 解码 base64 编码的音频数据
        var audioBytes = base64Decode(audioData);
        print("长度是 ${audioBytes.length}");
        // pcmtowave.run(audioBytes);

        // audioQueue.add(audioBytes); // 添加新数据

        // int now = DateTime.now().millisecondsSinceEpoch;
        // int timeDiff = now - lastReceivedTime;
        //
        // // 根据 WebSocket 传输速率动态调整 `_bufferSize`
        // if (timeDiff < 50) {
        //   // 50ms 内到达多个 chunk，说明服务器发送速度快
        //   bytesSinkbufferSize = (bytesSinkbufferSize * 0.9).clamp(
        //     32 * 1024,
        //     128 * 1024,
        //   );
        // } else {
        //   // 速度变慢，稍微增大缓冲区
        //   bytesSinkbufferSize = (bytesSinkbufferSize * 1.1).clamp(
        //     32 * 1024,
        //     128 * 1024,
        //   );
        // }
        // lastReceivedTime = now;
        //
        // 将新的 audioBytes 添加到 BytesBuilder 中
        bytesSink.add(audioBytes);
        if (bytesSink.length >= bytesSinkbufferSize) {
          flushBufferToQueue();
        }
        debugPrint('Last chunk: ${audioBytes.lengthInBytes / 1024} KB');
        playNextInQueue();

        if (!firstAudioReceived) {
          firstAudioReceived = true;
          String chunkOfAs = 'H' * 1707 + '=';
          _sendAudio(chunkOfAs);
          _sendAudio(chunkOfAs);
        }
      } catch (e) {
        print('Error processing audio: $e');
      }
    }
  }

  List<int> _toBytes(int value, int byteCount) {
    List<int> bytes = [];
    for (int i = 0; i < byteCount; i++) {
      bytes.add((value >> (i * 8)) & 0xFF);
    }
    return bytes;
  }

  int makeFourCC(String a, String b, String c, String d) {
    return (a.codeUnitAt(0) |
            (b.codeUnitAt(0) << 8) |
            (c.codeUnitAt(0) << 16) |
            (d.codeUnitAt(0) << 24)) &
        0xFFFFFFFF;
  }

  // 生成WAV文件头
  Uint8List generateWaveHeader(
    int pcmDataSize,
    int sampleRate,
    int sampleBits,
    int channels,
  ) {
    List<int> header = [];

    // RIFF header
    header.addAll(utf8.encode('RIFF'));
    header.addAll(
      _toBytes(36 + pcmDataSize, 4),
    ); // Chunk size (36 + PCM data size)
    header.addAll(utf8.encode('WAVE'));

    // fmt chunk
    header.addAll(
      _toBytes(makeFourCC('f', 'm', 't', ' '), 4),
    ); // Chunk ID "fmt "
    header.addAll(_toBytes(16, 4)); // Subchunk size (for PCM format)
    header.addAll(_toBytes(1, 2)); // Audio format (1: PCM)
    header.addAll(_toBytes(channels, 2)); // Number of channels
    header.addAll(_toBytes(sampleRate, 4)); // Sample rate
    header.addAll(
      _toBytes(sampleRate * channels * sampleBits ~/ 8, 4),
    ); // Byte rate
    header.addAll(_toBytes(channels * sampleBits ~/ 8, 2)); // Block align
    header.addAll(_toBytes(sampleBits, 2)); // Bits per sample

    // data chunk
    header.addAll(
      _toBytes(makeFourCC('d', 'a', 't', 'a'), 4),
    ); // Chunk ID "data"
    header.addAll(_toBytes(pcmDataSize, 4)); // Subchunk size (PCM data size)

    return Uint8List.fromList(header);
  }

  // 主转换函数：将PCM数据转换为WAV数据
  Uint8List pcmToWav(
    Uint8List pcmData,
    int sampleRate,
    int sampleBits,
    int channels,
  ) {
    int pcmDataSize = pcmData.length;

    // 生成WAV头部
    Uint8List header = generateWaveHeader(
      pcmDataSize,
      sampleRate,
      sampleBits,
      channels,
    );

    // 将头部与PCM数据连接，形成最终的WAV文件数据
    return Uint8List.fromList(header + pcmData);
  }

  Future<void> playNextInQueue() async {
    if (isPlaying || audioQueue.isEmpty) return;

    final nextChunk = audioQueue.removeFirst();
    isPlaying = true;

    try {
      debugPrint('Playing chunk: ${nextChunk.lengthInBytes / 1024} KB');
      // Uint8List wavData = convertPcmToWav(nextChunk);
      Uint8List wavData = pcmToWav(nextChunk, 24000, 16, 1);
      Player.bytes(wavData);
      uuuonGetChunkDataCallback(wavData);
    } catch (e) {
      debugPrint('Error playing chunk: $e');
    } finally {
      isPlaying = false;
      if (audioQueue.isNotEmpty) {
        playNextInQueue();
      }
    }
  }

  void flushBufferToQueue({bool finalFlush = false}) {
    if (bytesSink.isNotEmpty) {
      audioQueue.add(bytesSink.toBytes());
      bytesSink.clear();
    }
    if (finalFlush) {
      playNextInQueue();
    }
  }

  // 处理 'call_disconnect_response' 消息类型
  void _handleCallDisconnectResponse(Map<String, dynamic> data) {
    print('Call disconnected');
    callId = null;

    // 调用断开连接回调（如果有设置）
    if (onDisconnectCallback != null) {
      onDisconnectCallback!();
    }
  }

  // 发送 'ping' 消息
  void _sendPing() {
    if (sessionId == null) {
      return;
    }

    final message = {
      "type": "ping",
      "session_id": sessionId,
      "call_id": callId,
      "request_id": _generateRequestId(),
      "content": "ping",
    };

    _sendData(message);
  }

  // 发送客户端位置信息
  void _sendClientLocationState() {
    if (sessionId == null) {
      return;
    }
    final message = {
      "type": "client_location_state",
      "session_id": sessionId,
      "call_id": null,
      "content": {
        "latitude": 0,
        "longitude": 0,
        "address": "",
        "timezone": "America/Chicago",
      },
    };

    _sendData(message);
  }

  // 发送音频消息
  void _sendAudio(dynamic encodedData) {
    if (sessionId == null || callId == null) {
      return;
    }
    final message = {
      "type": "audio",
      "session_id": sessionId,
      "call_id": callId,
      "content": {"audio_data": encodedData},
    };

    _sendData(message);
  }

  // 发送呼叫连接请求
  void _sendCallConnect() {
    if (sessionId == null) {
      return;
    }
    final message = {
      "type": "call_connect",
      "session_id": sessionId,
      "call_id": null,
      "request_id": _generateRequestId(),
      "content": {
        "sample_rate": clientSampleRate,
        "audio_codec": audioCodec,
        "reconnect": reconnect,
        "is_private": isPrivate,
        "client_name": clientName,
        "settings": {"preset": character},
        "client_metadata": {
          "language": "en-US",
          "user_agent": userAgent,
          "mobile_browser": false,
          "media_devices": _getMediaDevices(),
        },
      },
    };

    _sendData(message);
  }

  // 发送音频数据
  bool sendAudioData(Uint8List rawAudioBytes) {
    if (sessionId == null || callId == null) {
      return false;
    }

    // 编码原始音频数据为 base64
    final encodedData = base64Encode(rawAudioBytes);

    _sendAudio(encodedData);
    return true;
  }

  // 断开连接
  bool disconnect() {
    if (sessionId == null || callId == null) {
      print("Cannot disconnect: Not connected");
      return false;
    }

    final message = {
      "type": "call_disconnect",
      "session_id": sessionId,
      "call_id": callId,
      "request_id": _generateRequestId(),
      "content": {"reason": "user_request"},
    };

    print("Sending disconnect request");
    _sendData(message);
    return true;
  }

  // 发送原始消息
  bool _sendMessage(Map<String, dynamic> message) {
    if (ws != null && ws!.readyState == WebSocket.open) {
      final messageStr = jsonEncode(message);
      ws?.add(messageStr);
      return true;
    } else {
      print("WebSocket is not connected");
      return false;
    }
  }

  // 发送数据并处理 ping
  bool _sendData(Map<String, dynamic> message) {
    try {
      final dataType = message['type'];

      // 发送 ping 消息以保持连接活跃
      if (callId != null &&
          dataType != 'ping' &&
          dataType != 'call_connect' &&
          dataType != 'call_disconnect') {
        if (lastSentMessageType == null ||
            receivedSinceLastSent ||
            dataType != lastSentMessageType) {
          _sendPing();
        }

        lastSentMessageType = dataType;
        receivedSinceLastSent = false;
      }

      return _sendMessage(message);
    } catch (e, stackTrace) {
      print('Error sending data: $e\n$stackTrace');
      return false;
    }
  }

  // 生成唯一请求 ID
  // String _generateRequestId() {
  //   return Uuid().v4(); // Generates a random UUID
  // }

  // 自定义生成请求 ID（伪 UUID）
  // String _generateRequestId() {
  //   // 你可以根据需求定长，比如 32 字符，或分段拼接
  //   return '${SmartEncrypt.getRandomString(8)}-${SmartEncrypt.getRandomString(4)}-${SmartEncrypt.getRandomString(4)}-${SmartEncrypt.getRandomString(4)}-${SmartEncrypt.getRandomString(12)}';
  // }

  String _generateRequestId() =>
      [8, 4, 4, 4, 12].map(SmartEncrypt.getRandomString).join('-');

  // 获取媒体设备
  List<Map<String, dynamic>> _getMediaDevices() {
    return [
      {
        "deviceId": "default",
        "kind": "audioinput",
        "label": "Default - Microphone",
        "groupId": "default",
      },
      {
        "deviceId": "default",
        "kind": "audiooutput",
        "label": "Default - Speaker",
        "groupId": "default",
      },
    ];
  }

  Future<void> getNextAudioChunk() async {}

  int realserverSampleRate() {
    return serverSampleRate;
  }

  // 设置连接回调
  void setConnectCallback(void Function() callback) {
    onConnectCallback = callback;
  }

  // 设置回调
  void setgetchunkcallback(Function(Uint8List) callback) {
    uuuonGetChunkDataCallback = callback;
  }

  // 设置断开连接回调
  void setDisconnectCallback(void Function() callback) {
    onDisconnectCallback = callback;
  }

  // 检查 WebSocket 是否已连接
  bool isConnected() {
    return sessionId != null && callId != null;
  }
}

/// 自定义绘制类，实现所有绘图逻辑
class WavePainter extends CustomPainter {
  final double animationValue;
  final double expandValue;
  final double rmsValue;
  final double ringWidthFactor;

  WavePainter({
    required this.animationValue,
    required this.expandValue,
    required this.rmsValue,
    required this.ringWidthFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const baseRadius = 80.0; // 增大圆环基础半径
    final maxWaveRadius = 100; // 增大波纹的最大半径范围

    // 绘制波纹圆环（一个）
    for (int i = 0; i < 1; i++) {
      final waveProgress = (animationValue + i * 0.5) % 1;
      final radius = baseRadius + waveProgress * maxWaveRadius;
      final wavePaint = Paint()
        ..color = Color.fromRGBO(224, 232, 192, 0.5)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, wavePaint);
    }

    // 绘制中心圆（使用径向渐变）
    final centerGradient = RadialGradient(
      center: Alignment.center,
      radius: baseRadius,
      colors: [const Color(0xFFC3CB9C), const Color(0xFFC3CB9C)],
    );
    final centerPaint = Paint()
      ..shader = centerGradient.createShader(
        Rect.fromCircle(center: center, radius: baseRadius),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius, centerPaint);

    // 绘制固定大小的圆环
    final ringPaint = Paint()
      ..color = const Color(0xECF4F6ED)
      ..style = PaintingStyle.stroke;
    final minRingWidth = baseRadius / 4;
    final maxRingWidth = baseRadius;
    final ringWidth =
        minRingWidth + ringWidthFactor * (maxRingWidth - minRingWidth);
    ringPaint.strokeWidth = ringWidth * (1 + rmsValue * 0.2);
    final fixedCircleRadius = baseRadius + ringWidth / 2;
    canvas.drawCircle(center, fixedCircleRadius, ringPaint);

    // 绘制最外层扩散的透明圆
    final expandStartRadius = baseRadius + ringWidth;
    final expandRadius = expandStartRadius + expandValue * 50;
    final opacityFactor =
        pow(max(0, 1 - (expandRadius) / (maxWaveRadius * 1.1)), 2.5).toDouble();
    final expandPaint = Paint()
      ..color = Color.fromRGBO(219, 224, 195, opacityFactor)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, expandRadius, expandPaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        expandValue != oldDelegate.expandValue ||
        rmsValue != oldDelegate.rmsValue ||
        ringWidthFactor != oldDelegate.ringWidthFactor;
  }
}

class CallControlWidget extends StatefulWidget {
  final VoidCallback? onMute;
  final VoidCallback onEndCall;

  const CallControlWidget({Key? key, this.onMute, required this.onEndCall})
      : super(key: key);

  @override
  _CallControlWidgetState createState() => _CallControlWidgetState();
}

class _CallControlWidgetState extends State<CallControlWidget> {
  bool isMuted = false;

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });

    // 触发外部回调（如果有）
    widget.onMute?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6EB), // 背景颜色
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              hoverColor: const Color.fromRGBO(219, 224, 195, 0.8),
              onTap: _toggleMute,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isMuted
                        ? const Icon(Icons.mic_off, color: Colors.red)
                        : Icon(Icons.mic, color: Colors.green[800]),
                    const SizedBox(width: 8),
                    isMuted
                        ? const Text(
                            "取消静音",
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          )
                        : Text(
                            "静音",
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 16,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              hoverColor: const Color.fromRGBO(219, 224, 195, 0.8),
              onTap: widget.onEndCall,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "挂断",
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  final bool isCollect;

  const TimerWidget({Key? key, required this.isCollect}) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isCollect) {
      _startTimer(); // 如果一开始 isCollect 就是 true，启动计时器
    }
  }

  @override
  void didUpdateWidget(covariant TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollect && !oldWidget.isCollect) {
      _startTimer();
    } else if (!widget.isCollect && oldWidget.isCollect) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _seconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return widget.isCollect
        ? Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF5A6230), // 绿色文本
            ),
          )
        : const SizedBox();
  }
}
