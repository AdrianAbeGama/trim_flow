import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class StoryViewer extends StatefulWidget {
  final List<String> images;
  final String title;

  const StoryViewer({
    super.key,
    required this.images,
    required this.title,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  late PageController _pageController;
  int _currentIndex = 0;
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.01;
        } else {
          _timer?.cancel();
          _nextPage();
        }
      });
    });
  }

  void _nextPage() {
    if (_currentIndex < widget.images.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startTimer();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 10) Navigator.pop(context);
        },
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _previousPage();
          } else {
            _nextPage();
          }
        },
        child: Stack(
          children: [
            // Imágenes
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),
            
            // Barras de Progreso
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      children: List.generate(widget.images.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: LinearProgressIndicator(
                              value: index == _currentIndex
                                  ? _progress
                                  : (index < _currentIndex ? 1.0 : 0.0),
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: context.primaryGold,
                          child: const Icon(Icons.content_cut_rounded, size: 16, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
