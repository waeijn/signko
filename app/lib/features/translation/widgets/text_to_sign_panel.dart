import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextToSignPanel extends StatefulWidget {
  final bool isTranslating;
  final bool showVideoMock;
  final String lastSentText;
  final String? mediaType;
  final String? mediaPath;
  final List<List<String>>? mediaSequence;

  const TextToSignPanel({
    super.key,
    required this.isTranslating,
    required this.showVideoMock,
    required this.lastSentText,
    this.mediaType,
    this.mediaPath,
    this.mediaSequence,
  });

  @override
  State<TextToSignPanel> createState() => _TextToSignPanelState();
}

class _TextToSignPanelState extends State<TextToSignPanel> {
  int _selectedWordIndex = -1; // -1 means [All]

  // Mock list of 30 dynamic words
  final List<String> _dynamicVocabulary = [
    'hello', 'world', 'please', 'thank', 'you', 'sorry', 'yes', 'no',
    'help', 'love', 'name', 'what', 'where', 'when', 'why', 'how',
    'good', 'bad', 'happy', 'sad', 'angry', 'eat', 'drink', 'sleep',
    'time', 'day', 'night', 'today', 'tomorrow', 'yesterday'
  ];

  bool isDynamicWord(String word) {
    final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    return _dynamicVocabulary.contains(cleanWord);
  }

  // Extract letter from path, e.g., "assets/images/alphabet/a.png" -> "A"
  String _extractLetter(String path) {
    try {
      final filename = path.split('/').last;
      return filename.split('.').first.toUpperCase();
    } catch (e) {
      return '';
    }
  }

  @override
  void didUpdateWidget(covariant TextToSignPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to [All] when new text is submitted
    if (oldWidget.lastSentText != widget.lastSentText) {
      _selectedWordIndex = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isTranslating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Translating...',
              style: GoogleFonts.poppins(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.showVideoMock) {
      final words = widget.lastSentText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // 1. Phrase Bubble (Pinned near top)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A3357) : const Color(0xFFEBF2FF), // Soft Accent Blue
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.transparent : const Color(0xFF1E56F0).withValues(alpha: 0.1)),
              ),
              child: Text(
                widget.lastSentText,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF42E8E0) : const Color(0xFF1E56F0), // Primary Royal Blue
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // 2. Interactive Word Filter Chips
          if (words.length > 1) // Only show chips if there are multiple words
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(
                      'All',
                      style: GoogleFonts.poppins(
                        fontWeight: _selectedWordIndex == -1 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: _selectedWordIndex == -1,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedWordIndex = -1);
                    },
                    selectedColor: isDark ? const Color(0xFF42E8E0).withValues(alpha: 0.1) : const Color(0xFF1E56F0).withValues(alpha: 0.1),
                    checkmarkColor: isDark ? const Color(0xFF42E8E0) : const Color(0xFF1E56F0),
                    labelStyle: TextStyle(
                      color: _selectedWordIndex == -1 
                        ? (isDark ? const Color(0xFF42E8E0) : const Color(0xFF1E56F0)) 
                        : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                    ),
                  ),
                  ...List.generate(words.length, (index) {
                    final cleanWord = words[index].replaceAll(RegExp(r'[^a-zA-Z]'), '');
                    if (cleanWord.isEmpty) return const SizedBox.shrink();
                    
                    final isSelected = _selectedWordIndex == index;
                    return ChoiceChip(
                      label: Text(
                        cleanWord,
                        style: GoogleFonts.poppins(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedWordIndex = index);
                      },
                      selectedColor: isDark ? const Color(0xFF42E8E0).withValues(alpha: 0.1) : const Color(0xFF1E56F0).withValues(alpha: 0.1),
                      checkmarkColor: isDark ? const Color(0xFF42E8E0) : const Color(0xFF1E56F0),
                      labelStyle: TextStyle(
                        color: isSelected 
                          ? (isDark ? const Color(0xFF42E8E0) : const Color(0xFF1E56F0)) 
                          : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 3. Main Sign Display Area (Zero Scrolling, Auto-Scaling)
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2642) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? const Color(0xFF2A3357) : const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Center(
                  key: ValueKey<int>(_selectedWordIndex),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 64,
                        ),
                        child: _buildSignDisplayContent(words, isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    // Default Idle State
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: isDark ? const Color(0xFF2A3357) : const Color(0xFFF8FAFC),
          ),
          const SizedBox(height: 16),
          Container(
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A3357) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignDisplayContent(List<String> words, bool isDark) {
    // SINGLE WORD MODE
    if (_selectedWordIndex != -1) {
      final word = words[_selectedWordIndex];
      // TODO: Re-enable video hook once .mp4 files are ready
      // if (isDynamicWord(word)) {
      //   return _buildVideoPlaceholder(word);
      // } else {
      
      final cleanLetters = word.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase().split('');
      final paths = cleanLetters.map((c) => 'assets/images/alphabet/$c.png').toList();
      return _buildWordGroup(paths, isDark: isDark);
      // }
    }

    // [ALL] MODE
    if (widget.mediaType == 'sequence' && widget.mediaSequence != null) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: List.generate(words.length, (index) {
          final word = words[index];
          final cleanLetters = word.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase().split('');
          if (cleanLetters.isEmpty || cleanLetters[0].isEmpty) return const SizedBox.shrink();
          
          final paths = cleanLetters.map((c) => 'assets/images/alphabet/$c.png').toList();
          return _buildWordGroup(paths, isGrouped: true, wordIndex: index, isDark: isDark);
        }),
      );
    } else if (widget.mediaType == 'image' && widget.mediaPath != null) {
      // Entire phrase returned a single image (unlikely for phrases, but possible for single words)
      return Image.asset(
        widget.mediaPath!,
        height: 150,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 64, color: Colors.red),
      );
    } else {
      // Entire phrase returned a video
      return _buildVideoPlaceholder(widget.lastSentText, isDark);
    }
  }

  // Renders a single word's letters in a Wrap
  Widget _buildWordGroup(List<String> paths, {bool isGrouped = false, int? wordIndex, required bool isDark}) {
    final wrapWidget = Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 12,
      children: paths.map((path) => _buildCharacterCard(path, isDark)).toList(),
    );

    if (isGrouped) {
      return Material(
        color: isDark ? const Color(0xFF141A31) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: wordIndex != null ? () {
            setState(() {
              _selectedWordIndex = wordIndex;
            });
          } : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2A3357) : const Color(0xFFE2E8F0)),
            ),
            child: wrapWidget,
          ),
        ),
      );
    }

    return wrapWidget;
  }

  // Renders the individual Image + Character Pill
  Widget _buildCharacterCard(String path, bool isDark) {
    final letter = _extractLetter(path);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          path,
          height: 80,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 48, color: Colors.red),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF42E8E0) : const Color(0xFF1E56F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            letter,
            style: GoogleFonts.poppins(
              color: isDark ? const Color(0xFF141A31) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlaceholder(String word, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.play_circle_fill, size: 80, color: isDark ? const Color(0xFF42E8E0) : const Color(0xFF1E56F0)),
        const SizedBox(height: 16),
        Text(
          'Dynamic Video:',
          style: GoogleFonts.poppins(color: isDark ? Colors.white54 : const Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            word.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: isDark ? const Color(0xFF42E8E0) : const Color(0xFF1E56F0),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
