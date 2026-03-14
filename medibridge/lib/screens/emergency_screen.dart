import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../services/settings_provider.dart';
import '../services/consultation_provider.dart';
import '../theme/app_theme.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class EmergencyPhrase {
  final String emoji;
  final String english;
  final String category;
  const EmergencyPhrase(
      {required this.emoji, required this.english, required this.category});
}

const _phrases = [
  EmergencyPhrase(
      emoji: '😮‍💨', english: "I can't breathe", category: 'Respiratory'),
  EmergencyPhrase(
      emoji: '🫁', english: 'I have chest tightness', category: 'Respiratory'),
  EmergencyPhrase(
      emoji: '🌬️', english: 'I am wheezing', category: 'Respiratory'),
  EmergencyPhrase(
      emoji: '💔', english: 'I have chest pain', category: 'Cardiac'),
  EmergencyPhrase(
      emoji: '💓', english: 'My heart is racing', category: 'Cardiac'),
  EmergencyPhrase(
      emoji: '🫀', english: 'I feel irregular heartbeat', category: 'Cardiac'),
  EmergencyPhrase(
      emoji: '🤕', english: 'I have severe headache', category: 'Neurological'),
  EmergencyPhrase(
      emoji: '😵', english: 'I feel dizzy and faint', category: 'Neurological'),
  EmergencyPhrase(
      emoji: '👁️', english: "I can't see properly", category: 'Neurological'),
  EmergencyPhrase(
      emoji: '🦵', english: "I can't move my leg", category: 'Neurological'),
  EmergencyPhrase(
      emoji: '🗣️',
      english: "I can't speak normally",
      category: 'Neurological'),
  EmergencyPhrase(
      emoji: '🦴', english: 'I think I broke something', category: 'Trauma'),
  EmergencyPhrase(
      emoji: '🩸', english: 'I am bleeding heavily', category: 'Trauma'),
  EmergencyPhrase(
      emoji: '🤜', english: 'I was in an accident', category: 'Trauma'),
  EmergencyPhrase(
      emoji: '🌡️', english: 'I have very high fever', category: 'General'),
  EmergencyPhrase(
      emoji: '🤢', english: 'I feel like vomiting', category: 'General'),
  EmergencyPhrase(
      emoji: '😫', english: 'I am in severe pain', category: 'General'),
  EmergencyPhrase(
      emoji: '💧', english: 'I am very dehydrated', category: 'General'),
  EmergencyPhrase(
      emoji: '💊', english: 'I took too many pills', category: 'Toxicology'),
  EmergencyPhrase(
      emoji: '🐝', english: 'I had an allergic reaction', category: 'Allergy'),
  EmergencyPhrase(
      emoji: '😶', english: 'My throat is swelling', category: 'Allergy'),
  EmergencyPhrase(
      emoji: '☠️',
      english: 'I ingested something toxic',
      category: 'Toxicology'),
];

const _categories = [
  'All',
  'Respiratory',
  'Cardiac',
  'Neurological',
  'Trauma',
  'General',
  'Allergy',
  'Toxicology',
];

const _categoryColors = {
  'Respiratory': Color(0xFF4DA8FF),
  'Cardiac': Color(0xFFFF5C7A),
  'Neurological': Color(0xFFB97FFF),
  'Trauma': Color(0xFFFF7043),
  'General': Color(0xFF00E5C3),
  'Allergy': Color(0xFFFFB347),
  'Toxicology': Color(0xFFFF5C7A),
  'All': Color(0xFF7A9CC0),
};

// ── Screen ────────────────────────────────────────────────────────────────────

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String? _activePhraseId;
  final Map<String, String> _translations = {};
  String _selectedCategory = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Theme helpers — read from Theme so they respond to light/dark
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? AppTheme.bgDeep : AppTheme.lBgDeep;
  Color get _card => _isDark ? AppTheme.bgCard : AppTheme.lBgCard;
  Color get _surf => _isDark ? AppTheme.bgSurface : AppTheme.lBgSurface;
  Color get _border => _isDark ? AppTheme.divider : AppTheme.lDivider;
  Color get _txt => _isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
  Color get _sub => _isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;
  Color get _muted => _isDark ? AppTheme.textMuted : AppTheme.lTextMuted;
  // Error stays the same in both themes — it's a semantic color
  Color get _err => AppTheme.errorColor;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EmergencyPhrase> get _filtered => _phrases.where((p) {
        final matchCat =
            _selectedCategory == 'All' || p.category == _selectedCategory;
        final matchQ = _searchQuery.isEmpty ||
            p.english.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchCat && matchQ;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ConsultationProvider>();
    final patientLang = provider.patientLanguage;
    final str = context.watch<SettingsProvider>().strings;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _isDark ? AppTheme.bgDeep : AppTheme.lBgCard,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: _sub),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppTheme.errorColor),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeOut(duration: 600.ms)
              .then()
              .fadeIn(duration: 600.ms),
          const SizedBox(width: 8),
          Text(str.emergencyPhrases,
              style: GoogleFonts.dmSans(
                  fontSize: 17, fontWeight: FontWeight.w700, color: _err)),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _err.withOpacity(0.2)),
        ),
      ),
      body: Column(children: [
        // Info banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _err.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _err.withOpacity(0.25)),
          ),
          child: Row(children: [
            Icon(Icons.touch_app, color: _err, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${str.tapToSpeak} ${patientLang.name}',
                style: GoogleFonts.dmSans(fontSize: 13, color: _err),
              ),
            ),
          ]),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (q) => setState(() => _searchQuery = q),
            style: GoogleFonts.dmSans(fontSize: 14, color: _txt),
            decoration: InputDecoration(
              hintText: str.searchPhrases,
              hintStyle: GoogleFonts.dmSans(fontSize: 13, color: _muted),
              prefixIcon: Icon(Icons.search, color: _muted, size: 18),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Icon(Icons.close, color: _muted, size: 16))
                  : null,
              filled: true,
              fillColor: _card,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _err.withOpacity(0.4))),
            ),
          ),
        ),

        // Category chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: _categories.length,
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              final isSelected = _selectedCategory == cat;
              final color = _categoryColors[cat] ?? _muted;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.13) : _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color.withOpacity(0.55) : _border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(cat,
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? color : _muted)),
                ),
              );
            },
          ),
        ),

        // Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${_filtered.length} ${str.phraseCount}',
                style: GoogleFonts.dmSans(fontSize: 11, color: _muted)),
          ),
        ),

        // Grid
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, color: _muted, size: 40),
                      const SizedBox(height: 12),
                      Text(str.noPhrasesFound,
                          style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _sub)),
                      const SizedBox(height: 6),
                      Text(str.tryDifferentSearch,
                          style:
                              GoogleFonts.dmSans(fontSize: 13, color: _muted)),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final phrase = _filtered[i];
                    final isActive = _activePhraseId == phrase.english;
                    final translation = _translations[phrase.english];
                    final catColor = _categoryColors[phrase.category] ?? _err;

                    return GestureDetector(
                      onTap: () => _speakPhrase(
                          phrase, patientLang.speechCode, patientLang.name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isActive ? catColor.withOpacity(0.11) : _card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isActive ? catColor.withOpacity(0.55) : _border,
                            width: isActive ? 1.5 : 1,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                      color: catColor.withOpacity(0.18),
                                      blurRadius: 12)
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(phrase.emoji,
                                    style: const TextStyle(fontSize: 26)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(phrase.category,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 9,
                                          color: catColor,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3)),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(phrase.english,
                                style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _txt,
                                    height: 1.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            if (isActive && translation == null)
                              Row(children: [
                                SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5, color: catColor),
                                ),
                                const SizedBox(width: 6),
                                Text(str.translating,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 10, color: _muted)),
                              ])
                            else if (translation != null)
                              Row(children: [
                                if (isActive)
                                  Icon(Icons.volume_up,
                                          color: catColor, size: 12)
                                      .animate(onPlay: (c) => c.repeat())
                                      .fadeOut(duration: 500.ms)
                                      .then()
                                      .fadeIn(duration: 500.ms),
                                if (isActive) const SizedBox(width: 4),
                                Expanded(
                                  child: Text(translation,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: catColor,
                                          fontStyle: FontStyle.italic),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ])
                            else
                              Text(str.tapToTranslate,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 10, color: _muted)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: 40 * i),
                        duration: 250.ms);
                  },
                ),
        ),
      ]),
    );
  }

  Future<void> _speakPhrase(
      EmergencyPhrase phrase, String langCode, String langName) async {
    setState(() => _activePhraseId = phrase.english);

    if (_translations[phrase.english] == null) {
      try {
        final translation = await AiService.instance.translateEmergency(
          text: phrase.english,
          targetLanguage: langName,
        );
        if (mounted) {
          setState(() => _translations[phrase.english] = translation);
        }
      } catch (_) {
        if (mounted) {
          setState(() => _translations[phrase.english] = phrase.english);
        }
      }
    }

    final textToSpeak = _translations[phrase.english] ?? phrase.english;
    await TtsService.instance.speak(text: textToSpeak, languageCode: langCode);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _activePhraseId = null);
  }
}
