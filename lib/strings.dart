/// All interface text in English and Urdu. Guide content lives in
/// assets/guides.json (or Firestore), not here.
class S {
  final String lang;
  const S(this.lang);

  bool get isUrdu => lang == 'ur';

  String _t(String en, String ur) => isUrdu ? ur : en;

  String get appName => 'ProcessPK';
  String get tagline => _t(
    'Simple guides for processes in Pakistan',
    'پاکستان میں سرکاری کاموں کی آسان رہنمائی',
  );
  String get introLine => _t(
    'Know what you need, what to do, and what comes next.',
    'جانیں کیا چاہیے، کیا کرنا ہے، اور آگے کیا ہوگا۔',
  );
  String get chooseLanguage =>
      _t('Choose your language', 'اپنی زبان منتخب کریں');
  String get continueLabel => _t('Continue', 'جاری رکھیں');

  String get navHome => _t('Home', 'ہوم');
  String get navProgress => _t('My Progress', 'میری پیش رفت');
  String get navAbout => _t('About', 'معلومات');

  String get searchHint => _t(
    'Search e.g. CNIC, passport, MDCAT',
    'تلاش کریں مثلاً شناختی کارڈ، پاسپورٹ',
  );
  String get categories => _t('Categories', 'زمرے');
  String get popular => _t('Popular guides', 'مقبول رہنما');
  String get continueWhereLeft =>
      _t('Continue where you left off', 'جہاں چھوڑا تھا وہاں سے جاری رکھیں');
  String get allGuides => _t('All guides', 'تمام رہنما');
  String get searchResults => _t('Search results', 'تلاش کے نتائج');
  String get noResults => _t(
    'No guides match your search yet.',
    'آپ کی تلاش سے کوئی رہنما نہیں ملا۔',
  );
  String get viewGuide => _t('View guide', 'رہنما دیکھیں');

  String category(String id) => switch (id) {
    'education' => _t('Education', 'تعلیم'),
    'documents' => _t('Documents', 'دستاویزات'),
    'travel' => _t('Travel', 'سفر'),
    'government' => _t('Government Services', 'سرکاری خدمات'),
    _ => id,
  };

  String get whatIsThis => _t('What is this?', 'یہ کیا ہے؟');
  String get whoNeedsIt => _t('Who needs it?', 'کس کو ضرورت ہے؟');
  String get requiredDocuments => _t('Required documents', 'ضروری دستاویزات');
  String get fees => _t('Fees', 'فیس');
  String get processingTime => _t('Estimated time', 'متوقع وقت');
  String get steps => _t('Step-by-step', 'مرحلہ وار طریقہ');
  String get commonMistakes => _t('Common mistakes', 'عام غلطیاں');
  String get problemsAndFixes => _t(
    'Problems people face and fixes',
    'لوگوں کو پیش آنے والے مسائل اور حل',
  );
  String get contactsAndHelp => _t('Contacts and help', 'رابطہ اور مدد');
  String get contactsNote => _t(
    'Official helplines and offices. Numbers can change, so check the website if a call fails.',
    'سرکاری ہیلپ لائنز اور دفاتر۔ نمبر بدل سکتے ہیں، کال نہ ملے تو ویب سائٹ دیکھیں۔',
  );
  String get call => _t('Call', 'کال کریں');
  String get email => _t('Email', 'ای میل');
  String get website => _t('Website', 'ویب سائٹ');
  String get myNotes => _t('My notes', 'میرے نوٹس');
  String get notesHint => _t(
    'Tracking number, appointment date, office address...',
    'ٹریکنگ نمبر، اپائنٹمنٹ کی تاریخ، دفتر کا پتہ...',
  );
  String get helplines => _t('Helplines', 'ہیلپ لائنز');
  String get askProcessPK => _t('Ask ProcessPK', 'ProcessPK سے پوچھیں');
  String get askHint =>
      _t('Ask a question about this guide', 'اس رہنما کے بارے میں سوال پوچھیں');
  String get askIntro => _t(
    'Answers come only from this guide. Always confirm on the official website.',
    'جوابات صرف اس رہنما سے دیے جاتے ہیں۔ ہمیشہ سرکاری ویب سائٹ پر تصدیق کریں۔',
  );
  String questionsLeft(int n) =>
      _t('$n questions left today', 'آج $n سوال باقی ہیں');
  String get askLimitReached => _t(
    'You have used today\'s free questions. Try again tomorrow.',
    'آج کے مفت سوال ختم ہو گئے۔ کل دوبارہ کوشش کریں۔',
  );
  String get askFailed => _t(
    'Could not get an answer. Check your internet and try again.',
    'جواب نہیں مل سکا۔ انٹرنیٹ چیک کر کے دوبارہ کوشش کریں۔',
  );
  String get askBusy => _t(
    'Too many questions right now. Wait a minute.',
    'ابھی بہت سے سوال ہیں۔ ایک منٹ انتظار کریں۔',
  );
  String get suggestedQuestions => _t('Try asking', 'یہ پوچھ کر دیکھیں');
  List<String> get askSuggestions => isUrdu
      ? const [
          'کون سے کاغذات چاہییں؟',
          'فیس کتنی ہے اور کیسے جمع ہوگی؟',
          'کتنا وقت لگے گا؟',
          'اگر درخواست مسترد ہو جائے تو کیا کروں؟',
        ]
      : const [
          'Which documents do I need?',
          'How much is the fee and how do I pay?',
          'How long will it take?',
          'What if my application is rejected?',
        ];
  String get askFollowUpHint =>
      _t('Ask a follow-up question', 'مزید سوال پوچھیں');
  String get copied => _t('Copied', 'کاپی ہو گیا');
  String get newChat => _t('New chat', 'نئی گفتگو');
  String basedOn(String title) => _t('Based on: $title', 'ماخذ: $title');
  String get officialSources => _t('Official sources', 'سرکاری ذرائع');
  String get startChecklist => _t('Start checklist', 'چیک لسٹ شروع کریں');
  String get openChecklist => _t('Open my checklist', 'میری چیک لسٹ کھولیں');
  String get share => _t('Share', 'شیئر کریں');
  String get reportError => _t('Report an error', 'غلطی کی اطلاع دیں');

  String lastVerified(String? date) => date == null
      ? _t(
          'Not yet verified. Check official sources.',
          'ابھی تصدیق نہیں ہوئی۔ سرکاری ذرائع دیکھیں۔',
        )
      : _t('Last verified: $date', 'آخری تصدیق: $date');

  String get noProgress => _t(
    'No checklists yet. Open a guide and tap "Start checklist".',
    'ابھی کوئی چیک لسٹ نہیں۔ کوئی رہنما کھولیں اور "چیک لسٹ شروع کریں" دبائیں۔',
  );
  String get documentsReady => _t('Documents ready', 'تیار دستاویزات');
  String get stepsDone => _t('Steps completed', 'مکمل مراحل');
  String percentDone(int p) => _t('$p% done', '$p% مکمل');
  String get viewFullGuide => _t('View full guide', 'مکمل رہنما دیکھیں');
  String get removeChecklist => _t('Remove checklist', 'چیک لسٹ ہٹائیں');

  String get importantDates => _t('Important dates', 'اہم تاریخیں');
  String get setReminder => _t('Set a reminder', 'یاد دہانی لگائیں');
  String get reminders => _t('My reminders', 'میری یاد دہانیاں');
  String get reminderTitle => _t('What to remember', 'کیا یاد رکھنا ہے');
  String get pickDate => _t('Pick a date', 'تاریخ چنیں');
  String get save => _t('Save', 'محفوظ کریں');
  String get reminderSaved => _t(
    'Reminder saved. Add it to your calendar to get a notification.',
    'یاد دہانی محفوظ ہو گئی۔ نوٹیفکیشن کے لیے اسے کیلنڈر میں شامل کریں۔',
  );
  String get addToCalendar => _t('Add to calendar', 'کیلنڈر میں شامل کریں');
  String get delete => _t('Delete', 'حذف کریں');
  String daysLeft(int n) => switch (n) {
    0 => _t('Today', 'آج'),
    1 => _t('Tomorrow', 'کل'),
    _ => _t('In $n days', '$n دن میں'),
  };
  String get noReminders => _t(
    'No reminders yet. Open a guide and tap "Set a reminder".',
    'ابھی کوئی یاد دہانی نہیں۔ کوئی رہنما کھولیں اور "یاد دہانی لگائیں" دبائیں۔',
  );
  String get upcoming => _t('Coming up', 'آنے والی تاریخ');
  String deadlineFor(String title) =>
      _t('$title: deadline', '$title: آخری تاریخ');

  String get findOffice => _t('Find nearest office', 'قریبی دفتر تلاش کریں');
  String get findOffices =>
      _t('Find an office near you', 'اپنے قریب دفتر تلاش کریں');
  String get officesIntro => _t(
    'Opens Google Maps with offices near you. Check timings before you go.',
    'گوگل میپس پر آپ کے قریب کے دفاتر کھلیں گے۔ جانے سے پہلے اوقات چیک کریں۔',
  );
  String get openInMaps => _t('Open in Maps', 'میپس میں کھولیں');
  String get officialList => _t('Official list', 'سرکاری فہرست');
  String usedFor(String titles) => _t('For: $titles', 'برائے: $titles');

  String get sharePdf => _t('Share as PDF', 'پی ڈی ایف شیئر کریں');
  String get shareText => _t('Share as text', 'متن شیئر کریں');
  String get pdfChecklist => _t('My checklist', 'میری چیک لسٹ');
  String get pdfFooter => _t(
    'Made with ProcessPK. Independent app, not affiliated with the Government of Pakistan. Confirm on official websites.',
    'ProcessPK سے بنایا گیا۔ آزاد ایپ، حکومت پاکستان سے کوئی تعلق نہیں۔ سرکاری ویب سائٹس پر تصدیق کریں۔',
  );
  String get contacts => _t('Contacts', 'رابطے');

  String get checklists => _t('My checklists', 'میری چیک لسٹیں');
  String get savedGuides => _t('Saved guides', 'محفوظ رہنما');
  String get saveGuide => _t('Save guide', 'رہنما محفوظ کریں');
  String get unsaveGuide => _t('Remove from saved', 'محفوظ سے ہٹائیں');

  String get aboutTitle => _t('About ProcessPK', 'ProcessPK کے بارے میں');
  String get aboutBody => _t(
    'ProcessPK turns scattered official information into clear guides, '
        'document checklists and progress tracking, made for students and '
        'young people in Pakistan.',
    'ProcessPK بکھری ہوئی سرکاری معلومات کو واضح رہنمائی، دستاویزات کی چیک لسٹ '
        'اور پیش رفت میں بدلتا ہے، خاص طور پر پاکستان کے طلبہ اور نوجوانوں کے لیے۔',
  );
  String get disclaimerTitle => _t('Independent app', 'آزاد ایپ');
  String get disclaimer => _t(
    'ProcessPK is not affiliated with, endorsed by, or acting on behalf of '
        'the Government of Pakistan or any government body. Always confirm '
        'fees, dates and requirements on the official websites listed below.',
    'ProcessPK کا حکومت پاکستان یا کسی سرکاری ادارے سے کوئی تعلق نہیں، نہ ہی یہ '
        'ان کی طرف سے کام کرتی ہے۔ فیس، تاریخیں اور شرائط ہمیشہ نیچے دی گئی '
        'سرکاری ویب سائٹس پر تصدیق کریں۔',
  );
  String get language => _t('Language', 'زبان');
  String get privacyPolicy => _t('Privacy policy', 'پرائیویسی پالیسی');
  String get privacySummary => _t(
    'No account needed. Your checklists stay on your phone. Ads are '
        'provided by Google AdMob.',
    'اکاؤنٹ کی ضرورت نہیں۔ آپ کی چیک لسٹ آپ کے فون پر ہی رہتی ہے۔ اشتہارات '
        'Google AdMob فراہم کرتا ہے۔',
  );
  String version(String v) => _t('Version $v', 'ورژن $v');
  String get couldNotOpen =>
      _t('Could not open the link.', 'لنک نہیں کھل سکا۔');
}
