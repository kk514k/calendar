import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Tips(),
//     );
//   }
// }

class Tips extends StatefulWidget {
  @override
  _TipsState createState() => _TipsState();
}
class _TipsState extends State<Tips> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  List<YoutubePlayerController> _videoControllers = [];

  final List<Map<String, String>> drugInfo = [
    {
      'title': '阿士匹靈(Aspirin)',
      'imagePath': 'assets/Aspirin.jpeg',
      'subtitle': '神聖萬能藥, 痛痛飛走',
      'description': '阿斯匹靈最好保存在室溫，並避免陽光直射和受潮。為免藥品受損，請勿將它放在浴室或冰箱內。不少藥廠都有生產阿斯匹靈藥品，儲存需求各異，請務必檢視產品包裝上的說明，或者詢問藥師相關資訊。為了安全起見，應將藥品放在小孩和寵物搆不到的地方。此外，當藥品過期，或是不再使用時，除非藥品指示許可，否則請勿將阿斯匹靈丟入馬桶或倒進排水孔，應另詢藥師安全處理藥品的方法。',
      'videoId': 'BAoZN_VFSRQ', // Replace with actual Aspirin video ID
    },
    {
      'title': '嗎啡(Morphine)',
      'imagePath': 'assets/Morphine.jpeg',
      'subtitle': '麻醉劑, 減輕痛楚\n但不包括人生及做Project',
      'description': '依醫師指示按時服藥，突然停藥或大幅調降劑量，會出現不適症狀，有任何用藥問題應與醫護人員討論。當出現突發性疼痛時，可以依據醫師的指示使用事先準備好的救援藥物。這些藥物通常在使用後20~30分鐘後即會出現藥效。若發現病人無法喚醒，或出現呼吸變慢（每分鐘呼吸次數少於6次），請通知醫護人員。',
      'videoId': 'nEla5gQ6NL0', // Replace with actual Morphine video ID
    },
    {
      'title': '抗生素(Anti-Life Powder)',
      'imagePath': 'assets/Anti.jpeg',
      'subtitle': '殺死希望或使人類停止繁殖',
      'description': '抗生素是用於治療和預防細菌感染的藥物，作用是殺死細菌或使細菌停止繁殖。抗生素可由微生物衍生出來或人工合成，但它們對於治療病毒感染，如流感或感冒，則沒有效果。',
      'videoId': 'CSEhsxS3OTY', // Replace with actual Antibiotics video ID
    },
  ];

  @override
  void initState() {
    super.initState();
    _initVideoControllers();
    // _startAutoSlide();
  }

  void _initVideoControllers() {
    for (var drug in drugInfo) {
      _videoControllers.add(YoutubePlayerController(
        initialVideoId: drug['videoId']!,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      ));
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _nextPage();
    });
  }

  void _nextPage() {
    if (_currentPage < drugInfo.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _controller.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
    } else {
      _currentPage = drugInfo.length - 1;
    }
    _controller.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onArrowPressed() {
    _autoSlideTimer?.cancel();
    // Timer(Duration(seconds: 10), () {
    //   _startAutoSlide();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('藥理知識')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: drugInfo.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  for (var controller in _videoControllers) {
                    controller.pause();
                  }
                });
              },
              itemBuilder: (context, index) {
                return _buildDrugCard(
                  drugInfo[index]['title']!,
                  drugInfo[index]['imagePath']!,
                  drugInfo[index]['subtitle']!,
                  drugInfo[index]['description']!,
                  _videoControllers[index],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, size: 30),
                onPressed: () {
                  _previousPage();
                  _onArrowPressed();
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 30),
                onPressed: () {
                  _nextPage();
                  _onArrowPressed();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrugCard(
      String title,
      String imagePath,
      String subtitle,
      String description,
      YoutubePlayerController videoController,
      ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MovingText(text: '切勿濫用藥物！！！'),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Center(
              child: Container(
                width: 200,
                height: 200,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 8),
            BlinkingText(text: subtitle),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 16),
            YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: videoController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
                progressColors: ProgressBarColors(
                  playedColor: Colors.blue,
                  handleColor: Colors.blueAccent,
                ),
                onReady: () {
                  print('Player is ready.');
                },
                onEnded: (data) {
                  videoController.pause();
                },
              ),
              builder: (context, player) {
                return Column(
                  children: [
                    player,
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (videoController.value.isPlaying) {
                          videoController.pause();
                        } else {
                          videoController.play();
                        }
                        setState(() {}); // Rebuild the button
                      },
                      child: Text(
                        !videoController.value.isPlaying ? '暫停' : '播放',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class MovingText extends StatefulWidget {
  final String text;

  MovingText({required this.text});

  @override
  _MovingTextState createState() => _MovingTextState();
}

class _MovingTextState extends State<MovingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(200 * (_controller.value - 0.5), 0),
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class BlinkingText extends StatefulWidget {
  final String text;

  BlinkingText({required this.text});

  @override
  _BlinkingTextState createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _controller.value,
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
