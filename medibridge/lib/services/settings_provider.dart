import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Supported UI languages ────────────────────────────────────────────────────

class UiLanguage {
  final String code;
  final String name;
  final String flag;
  const UiLanguage(
      {required this.code, required this.name, required this.flag});
}

const kUiLanguages = [
  UiLanguage(code: 'en', name: 'English', flag: '🇺🇸'),
  UiLanguage(code: 'es', name: 'Español', flag: '🇲🇽'),
  UiLanguage(code: 'pt', name: 'Português', flag: '🇧🇷'),
  UiLanguage(code: 'fr', name: 'Français', flag: '🇫🇷'),
  UiLanguage(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
  UiLanguage(code: 'zh', name: '中文', flag: '🇨🇳'),
  UiLanguage(code: 'ar', name: 'العربية', flag: '🇸🇦'),
  UiLanguage(code: 'hi', name: 'हिंदी', flag: '🇮🇳'),
  UiLanguage(code: 'ja', name: '日本語', flag: '🇯🇵'),
  UiLanguage(code: 'ko', name: '한국어', flag: '🇰🇷'),
];

// ── UI strings per language ───────────────────────────────────────────────────

class AppStrings {
  final String startConsultation;
  final String history;
  final String settings;
  final String emergency;
  final String about;
  final String languageSetup;
  final String liveSession;
  final String pastSessions;
  final String preferences;
  final String quickPhrases;
  final String howItWorks;
  final String aboutTitle;
  final String aboutBody;
  final String aboutBadge;
  final String medicalInterpreter;
  final String realtimeSubtitle;
  final String settingsTitle;
  final String appearance;
  final String darkMode;
  final String lightMode;
  final String systemDefault;
  final String appLanguage;
  final String appLanguageSubtitle;
  final String voiceSettings;
  final String speechRate;
  final String pitch;
  final String volume;
  final String slow;
  final String fast;
  final String low;
  final String high;

  // Emergency screen
  final String emergencyPhrases;
  final String tapToSpeak;
  final String searchPhrases;
  final String phraseCount;
  final String noPhrasesFound;
  final String tryDifferentSearch;
  final String translating;
  final String tapToTranslate;

  // History screen
  final String historyTitle;
  final String clearAll;
  final String clearAllHistory;
  final String clearAllConfirm;
  final String cancel;
  final String deleteAll;
  final String deleteSession;
  final String deleteSessionConfirm;
  final String delete;
  final String retry;
  final String noSessionsYet;
  final String noSessionsSubtitle;
  final String couldNotLoad;

  // Consultation screen
  final String consultation;
  final String listening;
  final String summary;
  final String readyToInterpret;
  final String selectSpeaker;
  final String detectedSymptoms;
  final String testVoice;
  final String testPhrase;
  final String saveSettings;
  final String settingsSaved;
  final String theme;

  const AppStrings({
    required this.startConsultation,
    required this.history,
    required this.settings,
    required this.emergency,
    required this.about,
    required this.languageSetup,
    required this.liveSession,
    required this.pastSessions,
    required this.preferences,
    required this.quickPhrases,
    required this.howItWorks,
    required this.aboutTitle,
    required this.aboutBody,
    required this.aboutBadge,
    required this.medicalInterpreter,
    required this.realtimeSubtitle,
    required this.settingsTitle,
    required this.appearance,
    required this.darkMode,
    required this.lightMode,
    required this.systemDefault,
    required this.appLanguage,
    required this.appLanguageSubtitle,
    required this.voiceSettings,
    required this.speechRate,
    required this.pitch,
    required this.volume,
    required this.testVoice,
    required this.testPhrase,
    required this.saveSettings,
    required this.settingsSaved,
    required this.theme,
    required this.slow,
    required this.fast,
    required this.low,
    required this.high,
    // Emergency
    required this.emergencyPhrases,
    required this.tapToSpeak,
    required this.searchPhrases,
    required this.phraseCount,
    required this.noPhrasesFound,
    required this.tryDifferentSearch,
    required this.translating,
    required this.tapToTranslate,
    // History
    required this.historyTitle,
    required this.clearAll,
    required this.clearAllHistory,
    required this.clearAllConfirm,
    required this.cancel,
    required this.deleteAll,
    required this.deleteSession,
    required this.deleteSessionConfirm,
    required this.delete,
    required this.retry,
    required this.noSessionsYet,
    required this.noSessionsSubtitle,
    required this.couldNotLoad,
    // Consultation
    required this.consultation,
    required this.listening,
    required this.summary,
    required this.readyToInterpret,
    required this.selectSpeaker,
    required this.detectedSymptoms,
  });
}

const Map<String, AppStrings> kStrings = {
  'en': AppStrings(
    startConsultation: 'Start Consultation',
    history: 'History',
    settings: 'Settings',
    emergency: 'Emergency',
    about: 'About',
    languageSetup: 'Language Setup',
    liveSession: 'Live interpretation session',
    pastSessions: 'Past sessions',
    preferences: 'Preferences',
    quickPhrases: 'Quick phrases',
    howItWorks: 'How it works',
    aboutTitle: 'About MediBridge',
    aboutBody:
        'MediBridge uses Gemini 2.5 Flash to provide real-time medical interpretation between doctors and patients who speak different languages.\n\nSelect your languages, tap the mic, and speak naturally. The AI handles the rest — with clinical accuracy.',
    aboutBadge: 'Built for Frostbyte Hackathon 2026',
    medicalInterpreter: 'Medical Interpreter',
    realtimeSubtitle:
        'Real-time AI interpretation\nfor doctor–patient communication',
    settingsTitle: 'Settings',
    appearance: 'Appearance',
    darkMode: 'Dark',
    lightMode: 'Light',
    systemDefault: 'System',
    appLanguage: 'App Language',
    appLanguageSubtitle: 'Interface language',
    voiceSettings: 'Voice Settings',
    speechRate: 'Speech Rate',
    pitch: 'Pitch',
    volume: 'Volume',
    testVoice: 'Test Voice',
    testPhrase: 'Hello, this is a voice test for MediBridge.',
    saveSettings: 'Save',
    settingsSaved: 'Settings saved',
    theme: 'Theme',
    slow: 'Slow',
    fast: 'Fast',
    low: 'Low',
    high: 'High',
    emergencyPhrases: 'Emergency Phrases',
    tapToSpeak: 'Tap any phrase to instantly speak it in',
    searchPhrases: 'Search phrases...',
    phraseCount: 'phrases',
    noPhrasesFound: 'No phrases found',
    tryDifferentSearch: 'Try a different search or category',
    translating: 'Translating...',
    tapToTranslate: 'Tap to translate & speak',
    historyTitle: 'History',
    clearAll: 'Clear All',
    clearAllHistory: 'Clear All History',
    clearAllConfirm: 'Delete all consultation sessions? This cannot be undone.',
    cancel: 'Cancel',
    deleteAll: 'Delete All',
    deleteSession: 'Delete Session',
    deleteSessionConfirm: 'Remove this session from history?',
    delete: 'Delete',
    retry: 'Retry',
    noSessionsYet: 'No sessions yet',
    noSessionsSubtitle: 'Start a consultation to see history here.',
    couldNotLoad: 'Could not load sessions',
    consultation: 'Consultation',
    listening: 'Listening...',
    summary: 'Summary',
    readyToInterpret: 'Ready to interpret',
    selectSpeaker: 'Select who is speaking then tap the mic button',
    detectedSymptoms: 'DETECTED SYMPTOMS',
  ),
  'es': AppStrings(
    startConsultation: 'Iniciar Consulta',
    history: 'Historial',
    settings: 'Ajustes',
    emergency: 'Emergencia',
    about: 'Acerca de',
    languageSetup: 'Configurar Idiomas',
    liveSession: 'Sesión de interpretación en vivo',
    pastSessions: 'Sesiones anteriores',
    preferences: 'Preferencias',
    quickPhrases: 'Frases rápidas',
    howItWorks: 'Cómo funciona',
    aboutTitle: 'Acerca de MediBridge',
    aboutBody:
        'MediBridge usa Gemini 2.5 Flash para ofrecer interpretación médica en tiempo real entre médicos y pacientes que hablan distintos idiomas.\n\nElige tus idiomas, toca el micrófono y habla con naturalidad. La IA se encarga del resto, con precisión clínica.',
    aboutBadge: 'Creado para Frostbyte Hackathon 2026',
    medicalInterpreter: 'Intérprete Médico',
    realtimeSubtitle:
        'Interpretación con IA en tiempo real\npara comunicación médico–paciente',
    settingsTitle: 'Ajustes',
    appearance: 'Apariencia',
    darkMode: 'Oscuro',
    lightMode: 'Claro',
    systemDefault: 'Sistema',
    appLanguage: 'Idioma de la app',
    appLanguageSubtitle: 'Idioma de la interfaz',
    voiceSettings: 'Configuración de voz',
    speechRate: 'Velocidad',
    pitch: 'Tono',
    volume: 'Volumen',
    testVoice: 'Probar voz',
    testPhrase: 'Hola, esto es una prueba de voz para MediBridge.',
    saveSettings: 'Guardar',
    settingsSaved: 'Ajustes guardados',
    theme: 'Tema',
    slow: 'Lento',
    fast: 'Rápido',
    low: 'Bajo',
    high: 'Alto',
    emergencyPhrases: 'Frases de Emergencia',
    tapToSpeak: 'Toca cualquier frase para hablarla en',
    searchPhrases: 'Buscar frases...',
    phraseCount: 'frases',
    noPhrasesFound: 'No se encontraron frases',
    tryDifferentSearch: 'Intenta otra búsqueda o categoría',
    translating: 'Traduciendo...',
    tapToTranslate: 'Toca para traducir y hablar',
    historyTitle: 'Historial',
    clearAll: 'Borrar todo',
    clearAllHistory: 'Borrar todo el historial',
    clearAllConfirm:
        '¿Eliminar todas las sesiones? Esta acción no se puede deshacer.',
    cancel: 'Cancelar',
    deleteAll: 'Eliminar todo',
    deleteSession: 'Eliminar sesión',
    deleteSessionConfirm: '¿Eliminar esta sesión del historial?',
    delete: 'Eliminar',
    retry: 'Reintentar',
    noSessionsYet: 'Sin sesiones aún',
    noSessionsSubtitle: 'Inicia una consulta para ver el historial aquí.',
    couldNotLoad: 'No se pudieron cargar las sesiones',
    consultation: 'Consulta',
    listening: 'Escuchando...',
    summary: 'Resumen',
    readyToInterpret: 'Listo para interpretar',
    selectSpeaker: 'Selecciona quién habla luego toca el micrófono',
    detectedSymptoms: 'SÍNTOMAS DETECTADOS',
  ),
  'pt': AppStrings(
    startConsultation: 'Iniciar Consulta',
    history: 'Histórico',
    settings: 'Configurações',
    emergency: 'Emergência',
    about: 'Sobre',
    languageSetup: 'Configurar Idiomas',
    liveSession: 'Sessão de interpretação ao vivo',
    pastSessions: 'Sessões anteriores',
    preferences: 'Preferências',
    quickPhrases: 'Frases rápidas',
    howItWorks: 'Como funciona',
    aboutTitle: 'Sobre o MediBridge',
    aboutBody:
        'O MediBridge usa o Gemini 2.5 Flash para oferecer interpretação médica em tempo real entre médicos e pacientes que falam idiomas diferentes.\n\nEscolha seus idiomas, toque no microfone e fale naturalmente. A IA cuida do resto — com precisão clínica.',
    aboutBadge: 'Criado para o Frostbyte Hackathon 2026',
    medicalInterpreter: 'Intérprete Médico',
    realtimeSubtitle:
        'Interpretação com IA em tempo real\npara comunicação médico–paciente',
    settingsTitle: 'Configurações',
    appearance: 'Aparência',
    darkMode: 'Escuro',
    lightMode: 'Claro',
    systemDefault: 'Sistema',
    appLanguage: 'Idioma do app',
    appLanguageSubtitle: 'Idioma da interface',
    voiceSettings: 'Configurações de voz',
    speechRate: 'Velocidade',
    pitch: 'Tom',
    volume: 'Volume',
    testVoice: 'Testar voz',
    testPhrase: 'Olá, este é um teste de voz para o MediBridge.',
    saveSettings: 'Salvar',
    settingsSaved: 'Configurações salvas',
    theme: 'Tema',
    slow: 'Lento',
    fast: 'Rápido',
    low: 'Baixo',
    high: 'Alto',
    emergencyPhrases: 'Frases de Emergência',
    tapToSpeak: 'Toque qualquer frase para falar em',
    searchPhrases: 'Buscar frases...',
    phraseCount: 'frases',
    noPhrasesFound: 'Nenhuma frase encontrada',
    tryDifferentSearch: 'Tente outra busca ou categoria',
    translating: 'Traduzindo...',
    tapToTranslate: 'Toque para traduzir e falar',
    historyTitle: 'Histórico',
    clearAll: 'Limpar tudo',
    clearAllHistory: 'Limpar todo o histórico',
    clearAllConfirm:
        'Excluir todas as sessões? Esta ação não pode ser desfeita.',
    cancel: 'Cancelar',
    deleteAll: 'Excluir tudo',
    deleteSession: 'Excluir sessão',
    deleteSessionConfirm: 'Remover esta sessão do histórico?',
    delete: 'Excluir',
    retry: 'Tentar novamente',
    noSessionsYet: 'Sem sessões ainda',
    noSessionsSubtitle: 'Inicie uma consulta para ver o histórico aqui.',
    couldNotLoad: 'Não foi possível carregar as sessões',
    consultation: 'Consulta',
    listening: 'Ouvindo...',
    summary: 'Resumo',
    readyToInterpret: 'Pronto para interpretar',
    selectSpeaker: 'Selecione quem está falando depois toque no microfone',
    detectedSymptoms: 'SINTOMAS DETECTADOS',
  ),
  'fr': AppStrings(
    startConsultation: 'Démarrer consultation',
    history: 'Historique',
    settings: 'Paramètres',
    emergency: 'Urgence',
    about: 'À propos',
    languageSetup: 'Configuration des langues',
    liveSession: 'Session d\'interprétation en direct',
    pastSessions: 'Sessions précédentes',
    preferences: 'Préférences',
    quickPhrases: 'Phrases rapides',
    howItWorks: 'Comment ça fonctionne',
    aboutTitle: 'À propos de MediBridge',
    aboutBody:
        'MediBridge utilise Gemini 2.5 Flash pour fournir une interprétation médicale en temps réel entre médecins et patients parlant des langues différentes.\n\nChoisissez vos langues, appuyez sur le micro et parlez naturellement. L\'IA s\'occupe du reste — avec une précision clinique.',
    aboutBadge: 'Créé pour Frostbyte Hackathon 2026',
    medicalInterpreter: 'Interprète médical',
    realtimeSubtitle:
        'Interprétation IA en temps réel\npour la communication médecin–patient',
    settingsTitle: 'Paramètres',
    appearance: 'Apparence',
    darkMode: 'Sombre',
    lightMode: 'Clair',
    systemDefault: 'Système',
    appLanguage: 'Langue de l\'app',
    appLanguageSubtitle: 'Langue de l\'interface',
    voiceSettings: 'Paramètres vocaux',
    speechRate: 'Débit',
    pitch: 'Tonalité',
    volume: 'Volume',
    testVoice: 'Tester la voix',
    testPhrase: 'Bonjour, ceci est un test vocal pour MediBridge.',
    saveSettings: 'Enregistrer',
    settingsSaved: 'Paramètres sauvegardés',
    theme: 'Thème',
    slow: 'Lent',
    fast: 'Rapide',
    low: 'Bas',
    high: 'Élevé',
    emergencyPhrases: "Phrases d'urgence",
    tapToSpeak: 'Appuyez sur une phrase pour la prononcer en',
    searchPhrases: 'Rechercher des phrases...',
    phraseCount: 'phrases',
    noPhrasesFound: 'Aucune phrase trouvée',
    tryDifferentSearch: 'Essayez une autre recherche ou catégorie',
    translating: 'Traduction...',
    tapToTranslate: 'Appuyez pour traduire et parler',
    historyTitle: 'Historique',
    clearAll: 'Tout effacer',
    clearAllHistory: "Effacer tout l'historique",
    clearAllConfirm:
        "Supprimer toutes les sessions ? Cette action est irréversible.",
    cancel: 'Annuler',
    deleteAll: 'Tout supprimer',
    deleteSession: 'Supprimer la session',
    deleteSessionConfirm: "Retirer cette session de l'historique ?",
    delete: 'Supprimer',
    retry: 'Réessayer',
    noSessionsYet: 'Aucune session',
    noSessionsSubtitle: "Démarrez une consultation pour voir l'historique ici.",
    couldNotLoad: 'Impossible de charger les sessions',
    consultation: 'Consultation',
    listening: 'Écoute...',
    summary: 'Résumé',
    readyToInterpret: 'Prêt à interpréter',
    selectSpeaker: 'Sélectionnez qui parle puis appuyez sur le micro',
    detectedSymptoms: 'SYMPTÔMES DÉTECTÉS',
  ),
  'de': AppStrings(
    startConsultation: 'Beratung starten',
    history: 'Verlauf',
    settings: 'Einstellungen',
    emergency: 'Notfall',
    about: 'Über uns',
    languageSetup: 'Spracheinstellungen',
    liveSession: 'Live-Dolmetschsitzung',
    pastSessions: 'Vergangene Sitzungen',
    preferences: 'Einstellungen',
    quickPhrases: 'Schnellphrasen',
    howItWorks: 'Wie es funktioniert',
    aboutTitle: 'Über MediBridge',
    aboutBody:
        'MediBridge nutzt Gemini 2.5 Flash, um eine Echtzeit-Dolmetschung zwischen Ärzten und Patienten mit unterschiedlichen Sprachen zu ermöglichen.\n\nWähle deine Sprachen, tippe auf das Mikrofon und sprich natürlich. Die KI übernimmt den Rest — mit klinischer Präzision.',
    aboutBadge: 'Für den Frostbyte Hackathon 2026 entwickelt',
    medicalInterpreter: 'Medizinischer Dolmetscher',
    realtimeSubtitle:
        'Echtzeit-KI-Dolmetschen\nfür Arzt-Patienten-Kommunikation',
    settingsTitle: 'Einstellungen',
    appearance: 'Erscheinungsbild',
    darkMode: 'Dunkel',
    lightMode: 'Hell',
    systemDefault: 'System',
    appLanguage: 'App-Sprache',
    appLanguageSubtitle: 'Sprache der Benutzeroberfläche',
    voiceSettings: 'Spracheinstellungen',
    speechRate: 'Sprechgeschwindigkeit',
    pitch: 'Tonhöhe',
    volume: 'Lautstärke',
    testVoice: 'Stimme testen',
    testPhrase: 'Hallo, dies ist ein Stimmtest für MediBridge.',
    saveSettings: 'Speichern',
    settingsSaved: 'Einstellungen gespeichert',
    theme: 'Design',
    slow: 'Langsam',
    fast: 'Schnell',
    low: 'Niedrig',
    high: 'Hoch',
    emergencyPhrases: 'Notfallphrasen',
    tapToSpeak: 'Tippe auf eine Phrase, um sie zu sprechen in',
    searchPhrases: 'Phrasen suchen...',
    phraseCount: 'Phrasen',
    noPhrasesFound: 'Keine Phrasen gefunden',
    tryDifferentSearch: 'Versuche eine andere Suche oder Kategorie',
    translating: 'Übersetzung...',
    tapToTranslate: 'Tippen zum Übersetzen und Sprechen',
    historyTitle: 'Verlauf',
    clearAll: 'Alles löschen',
    clearAllHistory: 'Gesamten Verlauf löschen',
    clearAllConfirm:
        "Alle Sitzungen löschen? Diese Aktion kann nicht rückgängig gemacht werden.",
    cancel: 'Abbrechen',
    deleteAll: 'Alles löschen',
    deleteSession: 'Sitzung löschen',
    deleteSessionConfirm: 'Diese Sitzung aus dem Verlauf entfernen?',
    delete: 'Löschen',
    retry: 'Wiederholen',
    noSessionsYet: 'Noch keine Sitzungen',
    noSessionsSubtitle:
        'Starte eine Konsultation, um den Verlauf hier zu sehen.',
    couldNotLoad: 'Sitzungen konnten nicht geladen werden',
    consultation: 'Konsultation',
    listening: 'Zuhören...',
    summary: 'Zusammenfassung',
    readyToInterpret: 'Bereit zum Dolmetschen',
    selectSpeaker: 'Wähle, wer spricht dann tippe auf das Mikrofon',
    detectedSymptoms: 'ERKANNTE SYMPTOME',
  ),
  'zh': AppStrings(
    startConsultation: '开始问诊',
    history: '历史记录',
    settings: '设置',
    emergency: '紧急情况',
    about: '关于',
    languageSetup: '语言设置',
    liveSession: '实时口译会话',
    pastSessions: '历史会话',
    preferences: '偏好设置',
    quickPhrases: '快速短语',
    howItWorks: '使用方法',
    aboutTitle: '关于 MediBridge',
    aboutBody:
        'MediBridge 使用 Gemini 2.5 Flash，为说不同语言的医生和患者提供实时医疗口译服务。\n\n选择语言，点击麦克风，自然地说话。AI 会以临床精准度处理其余一切。',
    aboutBadge: '为 Frostbyte Hackathon 2026 而建',
    medicalInterpreter: '医疗口译员',
    realtimeSubtitle: '为医患沟通提供\nAI实时口译服务',
    settingsTitle: '设置',
    appearance: '外观',
    darkMode: '深色',
    lightMode: '浅色',
    systemDefault: '跟随系统',
    appLanguage: '应用语言',
    appLanguageSubtitle: '界面语言',
    voiceSettings: '语音设置',
    speechRate: '语速',
    pitch: '音调',
    volume: '音量',
    testVoice: '测试语音',
    testPhrase: '你好，这是MediBridge的语音测试。',
    saveSettings: '保存',
    settingsSaved: '设置已保存',
    theme: '主题',
    slow: '慢',
    fast: '快',
    low: '低',
    high: '高',
    emergencyPhrases: '急救用语',
    tapToSpeak: '点击任意短语立即用以下语言朗读',
    searchPhrases: '搜索短语...',
    phraseCount: '个短语',
    noPhrasesFound: '未找到短语',
    tryDifferentSearch: '尝试不同的搜索词或分类',
    translating: '翻译中...',
    tapToTranslate: '点击翻译并朗读',
    historyTitle: '历史记录',
    clearAll: '清除全部',
    clearAllHistory: '清除所有历史记录',
    clearAllConfirm: '删除所有咨询会话？此操作无法撤销。',
    cancel: '取消',
    deleteAll: '全部删除',
    deleteSession: '删除会话',
    deleteSessionConfirm: '从历史记录中删除此会话？',
    delete: '删除',
    retry: '重试',
    noSessionsYet: '暂无会话',
    noSessionsSubtitle: '开始一次咨询以在此处查看历史记录。',
    couldNotLoad: '无法加载会话',
    consultation: '问诊',
    listening: '监听中...',
    summary: '摘要',
    readyToInterpret: '准备翻译',
    selectSpeaker: '选择发言人然后点击麦克风按钮',
    detectedSymptoms: '检测到的症状',
  ),
  'ar': AppStrings(
    startConsultation: 'بدء الاستشارة',
    history: 'السجل',
    settings: 'الإعدادات',
    emergency: 'طوارئ',
    about: 'حول',
    languageSetup: 'إعداد اللغة',
    liveSession: 'جلسة ترجمة فورية',
    pastSessions: 'الجلسات السابقة',
    preferences: 'التفضيلات',
    quickPhrases: 'عبارات سريعة',
    howItWorks: 'كيف يعمل',
    aboutTitle: 'حول MediBridge',
    aboutBody:
        'يستخدم MediBridge نموذج Gemini 2.5 Flash لتوفير ترجمة طبية فورية بين الأطباء والمرضى الذين يتحدثون لغات مختلفة.\n\nاختر لغاتك، اضغط على الميكروفون، وتحدث بشكل طبيعي. سيتولى الذكاء الاصطناعي الباقي بدقة سريرية.',
    aboutBadge: 'مُطوَّر لـ Frostbyte Hackathon 2026',
    medicalInterpreter: 'مترجم طبي',
    realtimeSubtitle:
        'ترجمة فورية بالذكاء الاصطناعي\nللتواصل بين الطبيب والمريض',
    settingsTitle: 'الإعدادات',
    appearance: 'المظهر',
    darkMode: 'داكن',
    lightMode: 'فاتح',
    systemDefault: 'النظام',
    appLanguage: 'لغة التطبيق',
    appLanguageSubtitle: 'لغة الواجهة',
    voiceSettings: 'إعدادات الصوت',
    speechRate: 'سرعة الكلام',
    pitch: 'درجة الصوت',
    volume: 'مستوى الصوت',
    testVoice: 'اختبار الصوت',
    testPhrase: 'مرحباً، هذا اختبار صوتي لـ MediBridge.',
    saveSettings: 'حفظ',
    settingsSaved: 'تم حفظ الإعدادات',
    theme: 'السمة',
    slow: 'بطيء',
    fast: 'سريع',
    low: 'منخفض',
    high: 'مرتفع',
    emergencyPhrases: 'عبارات الطوارئ',
    tapToSpeak: 'اضغط على أي عبارة للتحدث بها فوراً بالـ',
    searchPhrases: 'البحث في العبارات...',
    phraseCount: 'عبارات',
    noPhrasesFound: 'لا توجد عبارات',
    tryDifferentSearch: 'جرب بحثاً مختلفاً أو فئة أخرى',
    translating: 'جارٍ الترجمة...',
    tapToTranslate: 'اضغط للترجمة والتحدث',
    historyTitle: 'السجل',
    clearAll: 'مسح الكل',
    clearAllHistory: 'مسح كل السجل',
    clearAllConfirm:
        'هل تريد حذف جميع الجلسات؟ لا يمكن التراجع عن هذا الإجراء.',
    cancel: 'إلغاء',
    deleteAll: 'حذف الكل',
    deleteSession: 'حذف الجلسة',
    deleteSessionConfirm: 'هل تريد إزالة هذه الجلسة من السجل؟',
    delete: 'حذف',
    retry: 'إعادة المحاولة',
    noSessionsYet: 'لا توجد جلسات بعد',
    noSessionsSubtitle: 'ابدأ استشارة لرؤية السجل هنا.',
    couldNotLoad: 'تعذر تحميل الجلسات',
    consultation: 'استشارة',
    listening: 'جارٍ الاستماع...',
    summary: 'الملخص',
    readyToInterpret: 'جاهز للترجمة',
    selectSpeaker: 'اختر المتحدث ثم اضغط على الميكروفون',
    detectedSymptoms: 'الأعراض المكتشفة',
  ),
  'hi': AppStrings(
    startConsultation: 'परामर्श शुरू करें',
    history: 'इतिहास',
    settings: 'सेटिंग्स',
    emergency: 'आपातकाल',
    about: 'के बारे में',
    languageSetup: 'भाषा सेटअप',
    liveSession: 'लाइव इंटरप्रिटेशन सत्र',
    pastSessions: 'पिछले सत्र',
    preferences: 'प्राथमिकताएं',
    quickPhrases: 'त्वरित वाक्यांश',
    howItWorks: 'यह कैसे काम करता है',
    aboutTitle: 'MediBridge के बारे में',
    aboutBody:
        'MediBridge, Gemini 2.5 Flash का उपयोग करके अलग-अलग भाषाएं बोलने वाले डॉक्टरों और मरीजों के बीच रीयल-टाइम चिकित्सा दुभाषिया सेवा प्रदान करता है।\n\nअपनी भाषाएं चुनें, माइक पर टैप करें और स्वाभाविक रूप से बोलें। AI नैदानिक सटीकता के साथ बाकी सब संभाल लेती है।',
    aboutBadge: 'Frostbyte Hackathon 2026 के लिए बनाया गया',
    medicalInterpreter: 'चिकित्सा दुभाषिया',
    realtimeSubtitle: 'डॉक्टर-मरीज संचार के लिए\nरीयल-टाइम AI इंटरप्रिटेशन',
    settingsTitle: 'सेटिंग्स',
    appearance: 'रूप-रंग',
    darkMode: 'डार्क',
    lightMode: 'लाइट',
    systemDefault: 'सिस्टम',
    appLanguage: 'ऐप भाषा',
    appLanguageSubtitle: 'इंटरफ़ेस भाषा',
    voiceSettings: 'वॉयस सेटिंग्स',
    speechRate: 'बोलने की गति',
    pitch: 'पिच',
    volume: 'वॉल्यूम',
    testVoice: 'वॉयस टेस्ट करें',
    testPhrase: 'नमस्ते, यह MediBridge के लिए वॉयस टेस्ट है।',
    saveSettings: 'सहेजें',
    settingsSaved: 'सेटिंग्स सहेजी गईं',
    theme: 'थीम',
    slow: 'धीमा',
    fast: 'तेज़',
    low: 'कम',
    high: 'अधिक',
    emergencyPhrases: 'आपातकालीन वाक्यांश',
    tapToSpeak: 'किसी भी वाक्यांश पर टैप करके बोलें',
    searchPhrases: 'वाक्यांश खोजें...',
    phraseCount: 'वाक्यांश',
    noPhrasesFound: 'कोई वाक्यांश नहीं मिला',
    tryDifferentSearch: 'कोई अलग खोज या श्रेणी आज़माएं',
    translating: 'अनुवाद हो रहा है...',
    tapToTranslate: 'अनुवाद करने के लिए टैप करें',
    historyTitle: 'इतिहास',
    clearAll: 'सब हटाएं',
    clearAllHistory: 'पूरा इतिहास हटाएं',
    clearAllConfirm:
        'सभी परामर्श सत्र हटाएं? यह क्रिया पूर्ववत नहीं की जा सकती।',
    cancel: 'रद्द करें',
    deleteAll: 'सब हटाएं',
    deleteSession: 'सत्र हटाएं',
    deleteSessionConfirm: 'इस सत्र को इतिहास से हटाएं?',
    delete: 'हटाएं',
    retry: 'पुनः प्रयास करें',
    noSessionsYet: 'अभी कोई सत्र नहीं',
    noSessionsSubtitle: 'यहां इतिहास देखने के लिए एक परामर्श शुरू करें।',
    couldNotLoad: 'सत्र लोड नहीं हो सके',
    consultation: 'परामर्श',
    listening: 'सुन रहे हैं...',
    summary: 'सारांश',
    readyToInterpret: 'व्याख्या के लिए तैयार',
    selectSpeaker: 'कौन बोल रहा है चुनें फिर माइक बटन दबाएं',
    detectedSymptoms: 'पहचाने गए लक्षण',
  ),
  'ja': AppStrings(
    startConsultation: '診察を開始',
    history: '履歴',
    settings: '設定',
    emergency: '緊急',
    about: 'について',
    languageSetup: '言語設定',
    liveSession: 'ライブ通訳セッション',
    pastSessions: '過去のセッション',
    preferences: '設定',
    quickPhrases: 'クイックフレーズ',
    howItWorks: '使い方',
    aboutTitle: 'MediBridge について',
    aboutBody:
        'MediBridge は Gemini 2.5 Flash を活用し、異なる言語を話す医師と患者の間でリアルタイムの医療通訳を提供します。\n\n言語を選択し、マイクをタップして自然に話してください。AIが臨床的な精度で残りを処理します。',
    aboutBadge: 'Frostbyte Hackathon 2026 のために制作',
    medicalInterpreter: '医療通訳',
    realtimeSubtitle: '医師と患者のコミュニケーションのための\nリアルタイムAI通訳',
    settingsTitle: '設定',
    appearance: '外観',
    darkMode: 'ダーク',
    lightMode: 'ライト',
    systemDefault: 'システム',
    appLanguage: 'アプリの言語',
    appLanguageSubtitle: 'インターフェース言語',
    voiceSettings: '音声設定',
    speechRate: '話速',
    pitch: 'ピッチ',
    volume: '音量',
    testVoice: '音声テスト',
    testPhrase: 'こんにちは、MediBridgeの音声テストです。',
    saveSettings: '保存',
    settingsSaved: '設定を保存しました',
    theme: 'テーマ',
    slow: '遅い',
    fast: '速い',
    low: '低い',
    high: '高い',
    emergencyPhrases: '緊急フレーズ',
    tapToSpeak: "フレーズをタップして即座に話す（言語：",
    searchPhrases: 'フレーズを検索...',
    phraseCount: '件',
    noPhrasesFound: 'フレーズが見つかりません',
    tryDifferentSearch: '別の検索またはカテゴリを試してください',
    translating: '翻訳中...',
    tapToTranslate: 'タップして翻訳・読み上げ',
    historyTitle: '履歴',
    clearAll: 'すべて削除',
    clearAllHistory: '履歴をすべて削除',
    clearAllConfirm: 'すべての診察セッションを削除しますか？この操作は取り消せません。',
    cancel: 'キャンセル',
    deleteAll: 'すべて削除',
    deleteSession: 'セッションを削除',
    deleteSessionConfirm: 'このセッションを履歴から削除しますか？',
    delete: '削除',
    retry: '再試行',
    noSessionsYet: 'セッションなし',
    noSessionsSubtitle: 'ここに履歴を表示するには診察を開始してください。',
    couldNotLoad: 'セッションを読み込めませんでした',
    consultation: '診察',
    listening: '聴取中...',
    summary: 'サマリー',
    readyToInterpret: '通訳準備完了',
    selectSpeaker: '話者を選択してからマイクボタンをタップ',
    detectedSymptoms: '検出された症状',
  ),
  'ko': AppStrings(
    startConsultation: '진료 시작',
    history: '기록',
    settings: '설정',
    emergency: '응급',
    about: '정보',
    languageSetup: '언어 설정',
    liveSession: '실시간 통역 세션',
    pastSessions: '이전 세션',
    preferences: '환경설정',
    quickPhrases: '빠른 문구',
    howItWorks: '사용 방법',
    aboutTitle: 'MediBridge 정보',
    aboutBody:
        'MediBridge는 Gemini 2.5 Flash를 활용하여 서로 다른 언어를 사용하는 의사와 환자 간의 실시간 의료 통역을 제공합니다.\n\n언어를 선택하고, 마이크를 탭한 후 자연스럽게 말하세요. AI가 임상적 정확성으로 나머지를 처리합니다.',
    aboutBadge: 'Frostbyte Hackathon 2026을 위해 제작',
    medicalInterpreter: '의료 통역사',
    realtimeSubtitle: '의사-환자 소통을 위한\n실시간 AI 통역',
    settingsTitle: '설정',
    appearance: '외관',
    darkMode: '다크',
    lightMode: '라이트',
    systemDefault: '시스템',
    appLanguage: '앱 언어',
    appLanguageSubtitle: '인터페이스 언어',
    voiceSettings: '음성 설정',
    speechRate: '말하기 속도',
    pitch: '음높이',
    volume: '음량',
    testVoice: '음성 테스트',
    testPhrase: '안녕하세요, MediBridge 음성 테스트입니다.',
    saveSettings: '저장',
    settingsSaved: '설정이 저장되었습니다',
    theme: '테마',
    slow: '느림',
    fast: '빠름',
    low: '낮음',
    high: '높음',
    emergencyPhrases: '응급 문구',
    tapToSpeak: '문구를 탭하여 즉시 말하기',
    searchPhrases: '문구 검색...',
    phraseCount: '개 문구',
    noPhrasesFound: '문구를 찾을 수 없음',
    tryDifferentSearch: '다른 검색어나 카테고리를 시도해 보세요',
    translating: '번역 중...',
    tapToTranslate: '번역 및 말하기',
    historyTitle: '기록',
    clearAll: '모두 삭제',
    clearAllHistory: '기록 모두 삭제',
    clearAllConfirm: '모든 진료 세션을 삭제할까요? 이 작업은 취소할 수 없습니다.',
    cancel: '취소',
    deleteAll: '모두 삭제',
    deleteSession: '세션 삭제',
    deleteSessionConfirm: '이 세션을 기록에서 삭제할까요?',
    delete: '삭제',
    retry: '다시 시도',
    noSessionsYet: '세션 없음',
    noSessionsSubtitle: '여기에서 기록을 보려면 진료를 시작하세요.',
    couldNotLoad: '세션을 불러올 수 없습니다',
    consultation: '진료',
    listening: '듣는 중...',
    summary: '요약',
    readyToInterpret: '통역 준비 완료',
    selectSpeaker: '말하는 사람을 선택하고 마이크 버튼을 누르세요',
    detectedSymptoms: '감지된 증상',
  ),
};

// ── Provider ──────────────────────────────────────────────────────────────────

class SettingsProvider extends ChangeNotifier {
  static const _keyTheme = 'settings_theme';
  static const _keyLang = 'settings_lang';
  static const _keyRate = 'settings_rate';
  static const _keyPitch = 'settings_pitch';
  static const _keyVolume = 'settings_volume';

  ThemeMode _themeMode = ThemeMode.dark;
  String _uiLanguage = 'en';
  double _speechRate = 0.9;
  double _pitch = 1.0;
  double _volume = 1.0;

  ThemeMode get themeMode => _themeMode;
  String get uiLanguage => _uiLanguage;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;

  AppStrings get strings => kStrings[_uiLanguage] ?? kStrings['en']!;

  UiLanguage get currentUiLanguage =>
      kUiLanguages.firstWhere((l) => l.code == _uiLanguage,
          orElse: () => kUiLanguages.first);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_keyTheme) ?? 'dark';
    _themeMode = {
          'dark': ThemeMode.dark,
          'light': ThemeMode.light,
          'system': ThemeMode.system,
        }[themeStr] ??
        ThemeMode.dark;
    _uiLanguage = prefs.getString(_keyLang) ?? 'en';
    _speechRate = prefs.getDouble(_keyRate) ?? 0.9;
    _pitch = prefs.getDouble(_keyPitch) ?? 1.0;
    _volume = prefs.getDouble(_keyVolume) ?? 1.0;
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final str = {
      ThemeMode.dark: 'dark',
      ThemeMode.light: 'light',
      ThemeMode.system: 'system',
    }[mode]!;
    await prefs.setString(_keyTheme, str);
  }

  Future<void> setUiLanguage(String code) async {
    _uiLanguage = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLang, code);
  }

  Future<void> setVoice({
    double? rate,
    double? pitch,
    double? volume,
  }) async {
    if (rate != null) _speechRate = rate;
    if (pitch != null) _pitch = pitch;
    if (volume != null) _volume = volume;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyRate, _speechRate);
    await prefs.setDouble(_keyPitch, _pitch);
    await prefs.setDouble(_keyVolume, _volume);
  }
}
