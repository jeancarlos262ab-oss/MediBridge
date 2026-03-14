import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/history_service.dart'; // ← was supabase_history_service.dart
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../services/settings_provider.dart';
import '../widgets/message_bubble.dart';
import 'summary_screen.dart';

// ── Main screen ───────────────────────────────────────────────────────────────

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SessionRecord> _sessions = [];
  bool _loading = true;
  String? _loadError;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final sessions = await HistoryService.instance.loadAll();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _delete(String id) async {
    await HistoryService.instance.delete(id);
    await _load();
  }

  List<SessionRecord> get _filtered {
    if (_searchQuery.isEmpty) return _sessions;
    final q = _searchQuery.toLowerCase();
    return _sessions.where((s) {
      return s.doctorLanguage.toLowerCase().contains(q) ||
          s.patientLanguage.toLowerCase().contains(q) ||
          s.messages.any((m) =>
              m.originalText.toLowerCase().contains(q) ||
              m.translatedText.toLowerCase().contains(q));
    }).toList();
  }

  Map<String, List<SessionRecord>> get _grouped {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final Map<String, List<SessionRecord>> groups = {};
    for (final s in _filtered) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      String key;
      if (d == today) {
        key = 'Today';
      } else if (d == yesterday) {
        key = 'Yesterday';
      } else if (!d.isBefore(weekStart)) {
        key = 'This week';
      } else {
        key = DateFormat('MMMM yyyy').format(s.date);
      }
      groups.putIfAbsent(key, () => []).add(s);
    }
    return groups;
  }

  int get _totalMessages => _sessions.fold(0, (sum, s) => sum + s.messageCount);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;

    return Scaffold(
      appBar: _buildAppBar(context, isDark),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: acc))
          : _loadError != null
              ? _ErrorState(
                  error: _loadError!,
                  isDark: isDark,
                  onRetry: _load,
                )
              : _sessions.isEmpty
                  ? _EmptyHistory(isDark: isDark)
                  : RefreshIndicator(
                      color: acc,
                      onRefresh: _load,
                      child: _SessionList(
                        grouped: _grouped,
                        totalMessages: _totalMessages,
                        sessionCount: _sessions.length,
                        isDark: isDark,
                        onDelete: _delete,
                        searchCtrl: _searchCtrl,
                        onSearch: (q) => setState(() => _searchQuery = q),
                      ),
                    ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isDark) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final str = context.watch<SettingsProvider>().strings;
    return AppBar(
      title: Text(
        str.historyTitle,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ),
      actions: [
        if (_sessions.isNotEmpty)
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, color: AppTheme.errorColor),
            tooltip: context.watch<SettingsProvider>().strings.clearAll,
            onPressed: () => _confirmClearAll(context, isDark),
          ),
        IconButton(
          icon: Icon(Icons.refresh_outlined, color: acc),
          tooltip: 'Refresh',
          onPressed: _load,
        ),
      ],
    );
  }

  Future<void> _confirmClearAll(BuildContext context, bool isDark) async {
    final str = context.watch<SettingsProvider>().strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
        title: Text(str.clearAllHistory,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text(str.clearAllConfirm, style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(str.cancel,
                style: GoogleFonts.dmSans(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.lTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(str.deleteAll,
                style: GoogleFonts.dmSans(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryService.instance.clearAll();
      await _load();
    }
  }
}

// ── Session list with search bar ──────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  final Map<String, List<SessionRecord>> grouped;
  final int totalMessages;
  final int sessionCount;
  final bool isDark;
  final Future<void> Function(String id) onDelete;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;

  const _SessionList({
    required this.grouped,
    required this.totalMessages,
    required this.sessionCount,
    required this.isDark,
    required this.onDelete,
    required this.searchCtrl,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(children: [
              _StatsRow(
                  sessions: sessionCount,
                  messages: totalMessages,
                  isDark: isDark),
              const SizedBox(height: 12),
              _SearchBar(
                  controller: searchCtrl, onChanged: onSearch, isDark: isDark),
            ]),
          ),
        ),
        for (final entry in grouped.entries) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                entry.key,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _SessionCard(
                session: entry.value[i],
                isDark: isDark,
                onDelete: onDelete,
              ).animate().fadeIn(
                    delay: Duration(milliseconds: i * 60),
                    duration: 350.ms,
                  ),
              childCount: entry.value.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int sessions;
  final int messages;
  final bool isDark;
  const _StatsRow(
      {required this.sessions, required this.messages, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final card = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final div = isDark ? AppTheme.divider : AppTheme.lDivider;
    final txtP = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final txtS = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: div),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
              label: 'Sessions',
              value: '$sessions',
              color: acc,
              txtP: txtP,
              txtS: txtS),
          Container(width: 1, height: 30, color: div),
          _Stat(
              label: 'Messages',
              value: '$messages',
              color: acc,
              txtP: txtP,
              txtS: txtS),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color txtP;
  final Color txtS;
  const _Stat(
      {required this.label,
      required this.value,
      required this.color,
      required this.txtP,
      required this.txtS});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: GoogleFonts.dmSans(
              fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: txtS)),
    ]);
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  const _SearchBar(
      {required this.controller,
      required this.onChanged,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surf = isDark ? AppTheme.bgSurface : AppTheme.lBgSurface;
    final div = isDark ? AppTheme.divider : AppTheme.lDivider;
    final txtM = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(
          fontSize: 14,
          color: isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary),
      decoration: InputDecoration(
        hintText: 'Search sessions…',
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: txtM),
        prefixIcon: Icon(Icons.search, size: 18, color: txtM),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, size: 16, color: txtM),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: surf,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: div),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: div),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? AppTheme.accent : AppTheme.lAccent, width: 1.5),
        ),
      ),
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final SessionRecord session;
  final bool isDark;
  final Future<void> Function(String id) onDelete;
  const _SessionCard(
      {required this.session, required this.isDark, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final card = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final div = isDark ? AppTheme.divider : AppTheme.lDivider;
    final txtP = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final txtS = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;
    final hasSummary = session.summaryData != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openDetail(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: div),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      '${session.doctorLanguage}  ⇄  ${session.patientLanguage}',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: txtP),
                    ),
                  ),
                  if (hasSummary)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: acc.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        context.watch<SettingsProvider>().strings.summary,
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: acc,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: AppTheme.errorColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _confirmDelete(context),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMM d, yyyy  HH:mm').format(session.date),
                  style: GoogleFonts.dmSans(fontSize: 12, color: txtS),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.messageCount} message${session.messageCount != 1 ? 's' : ''}',
                  style: GoogleFonts.dmSans(fontSize: 12, color: txtS),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SessionDetailScreen(session: session),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
        title: Text(context.watch<SettingsProvider>().strings.deleteSession,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text(
            context.watch<SettingsProvider>().strings.deleteSessionConfirm,
            style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.watch<SettingsProvider>().strings.cancel,
                style: GoogleFonts.dmSans(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.lTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.watch<SettingsProvider>().strings.delete,
                style: GoogleFonts.dmSans(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true) await onDelete(session.id);
  }
}

// ── Session detail screen ─────────────────────────────────────────────────────

class _SessionDetailScreen extends StatelessWidget {
  final SessionRecord session;
  const _SessionDetailScreen({required this.session});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doctorLang = LanguageList.supported.firstWhere(
      (l) => l.name == session.doctorLanguage,
      orElse: () => LanguageList.byCode('en'),
    );
    final patientLang = LanguageList.supported.firstWhere(
      (l) => l.name == session.patientLanguage,
      orElse: () => LanguageList.byCode('es'),
    );

    // Rebuild ConsultationSummary from stored map if present
    final summary = session.summaryData != null
        ? ConsultationSummary.fromMap(session.summaryData!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('MMM d, yyyy').format(session.date),
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (summary != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                icon: Icon(Icons.summarize_outlined,
                    size: 16,
                    color: isDark ? AppTheme.accent : AppTheme.lAccent),
                label: Text(context.watch<SettingsProvider>().strings.summary,
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: isDark ? AppTheme.accent : AppTheme.lAccent,
                        fontWeight: FontWeight.w600)),
                onPressed: () =>
                    _showSummary(context, summary, patientLang, isDark),
              ),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: session.messages.length,
        itemBuilder: (_, i) {
          final msg = session.messages[i];
          // Speak the translated text in the listener's language
          final speakLang =
              msg.speaker == SpeakerRole.doctor ? patientLang : doctorLang;
          return MessageBubble(
            message: msg,
            doctorLanguage: doctorLang,
            patientLanguage: patientLang,
            onSpeak: () => TtsService.instance.speak(
              text: msg.translatedText,
              languageCode: speakLang.speechCode,
            ),
          );
        },
      ),
    );
  }

  void _showSummary(
    BuildContext context,
    ConsultationSummary summary,
    Language patientLang,
    bool isDark,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          summary: summary,
          patientLanguage: patientLang,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  final bool isDark;
  const _EmptyHistory({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final acc = isDark ? AppTheme.accent : AppTheme.lAccent;
    final txtS = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 56, color: acc.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(context.watch<SettingsProvider>().strings.noSessionsYet,
              style: GoogleFonts.dmSans(
                  fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(context.watch<SettingsProvider>().strings.noSessionsSubtitle,
              style: GoogleFonts.dmSans(fontSize: 13, color: txtS)),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorState(
      {required this.error, required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final txtS = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: AppTheme.errorColor.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(context.watch<SettingsProvider>().strings.couldNotLoad,
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 12, color: txtS)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(context.watch<SettingsProvider>().strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
