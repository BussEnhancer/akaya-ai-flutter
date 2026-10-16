import 'package:flutter/material.dart';

import '../commerce/intent.dart';

class ChatAttachment {
  ChatAttachment({required this.id, required this.kind, required this.name, this.meta, this.visual = false});
  final String id;
  final String kind;
  final String name;
  final String? meta;
  final bool visual;
}

class ChatMsg {
  ChatMsg({
    required this.from,
    required this.text,
    required this.at,
    this.attachments = const [],
    this.action,
    this.modes = const [],
  });
  final String from;
  final String text;
  final int at;
  final List<ChatAttachment> attachments;
  final LinkAction? action;
  final List<String> modes;
}

class ChatThread {
  ChatThread({required this.id, required this.title, required this.updatedAt, required this.messages});
  final String id;
  String title;
  int updatedAt;
  final List<ChatMsg> messages;
}

class NoteItem {
  NoteItem({required this.id, required this.text, required this.createdAt, required this.color});
  final String id;
  final String text;
  final int createdAt;
  final String color;
}

class FutureItem {
  FutureItem({
    required this.id,
    required this.to,
    required this.text,
    required this.when,
    required this.status,
    required this.channels,
    this.repeat = 'once',
    this.subject,
    int? createdAt,
  }) : createdAt = createdAt ?? when;
  final String id;
  String to;
  String text;
  int when;
  String status;
  List<String> channels;
  String repeat;
  String? subject;
  int createdAt;
}

class TodayEvent {
  TodayEvent({required this.id, required this.kind, required this.title, required this.time});
  final String id;
  final String kind;
  final String title;
  final int time;
  bool done = false;
}

class ReminderItem {
  ReminderItem({
    required this.id,
    required this.title,
    required this.category,
    required this.due,
    this.done = false,
    this.sample = true,
    this.priority = 'normal',
  });
  final String id;
  final String title;
  final String category;
  final int due;
  bool done;
  final bool sample;
  final String priority;
}

class ActivityItem {
  ActivityItem({
    required this.kind,
    required this.title,
    required this.input,
    required this.output,
    required this.at,
    this.app,
    this.langs,
  });
  final String kind;
  final String title;
  final String input;
  final String output;
  final int at;
  final String? app;
  final String? langs;
}

class VoiceNoteItem {
  VoiceNoteItem({required this.id, required this.title, required this.mode, required this.subject, required this.createdAt, required this.duration});
  final String id;
  final String title;
  final String mode;
  final String subject;
  final int createdAt;
  final int duration;
}

class AppNotice {
  AppNotice({required this.title, required this.body, required this.at, required this.icon, this.read = false});
  final String title;
  final String body;
  final int at;
  final String icon;
  bool read;
}

int _today(int h, [int m = 0]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day, h, m).millisecondsSinceEpoch;
}

int _daysAgo(int n, [int h = 10, int m = 0]) => _today(h, m) - n * 86400000;

class AppModel extends ChangeNotifier {
  bool signedIn = false;
  bool onboardingDone = false;
  String? method;
  String? contact;
  String name = 'Priya';
  String email = 'priya@example.com';
  String phone = '+91 98765 43210';
  String theme = 'system';
  String mode = 'on-device';
  bool floating = true;
  bool notificationsOn = true;
  String language = 'English';
  double textSize = 1;
  double voiceSpeed = 1;
  int reminderLead = 10;
  bool autoFollowUp = false;
  String? toast;
  String? pendingEmail;
  bool emailVerified = false;

  late List<ChatThread> chats;
  late List<NoteItem> notes;
  late List<FutureItem> future;
  late List<TodayEvent> today;
  late List<ReminderItem> reminders;
  late List<ActivityItem> activity;
  late List<VoiceNoteItem> voiceNotes;
  late List<AppNotice> notices;
  final Set<String> pinnedHistory = {};
  final Set<String> hiddenHistory = {};
  final Map<String, String> connected = {
    'gmail': 'priya@example.com',
    'google-calendar': 'priya@example.com',
    'whatsapp-business': 'Business number +91 98765 43210',
  };

  AppModel() {
    final now = DateTime.now().millisecondsSinceEpoch;
    chats = [
      ChatThread(id: 'c-goa', title: 'Goa trip plan', updatedAt: _today(10, 24), messages: [
        ChatMsg(from: 'me', text: 'Plan a 3-day Goa trip with beach stays under ₹15k', at: _today(10, 22)),
        ChatMsg(
          from: 'akaya',
          text:
              'Here is a relaxed 3-day plan:\n• Day 1: North Goa: Baga & Anjuna, sunset at Chapora Fort\n• Day 2: Old Goa churches, Fontainhas walk, Panjim food trail\n• Day 3: South Goa: Palolem beach & kayaking\nStays: beach huts in Palolem and guesthouses in Anjuna fit your budget.',
          at: _today(10, 24),
        ),
      ]),
      ChatThread(id: 'c-neha', title: 'Reply to Neha · Hindi → English', updatedAt: _daysAgo(1, 18, 5), messages: [
        ChatMsg(from: 'me', text: 'हाँ, कल 6 बजे मिलते हैं — translate to English', at: _daysAgo(1, 18, 4)),
        ChatMsg(from: 'akaya', text: 'Sure, see you at 6 tomorrow!', at: _daysAgo(1, 18, 5)),
      ]),
      ChatThread(id: 'c-grocery', title: 'Weekly grocery list', updatedAt: _daysAgo(4, 9, 15), messages: [
        ChatMsg(from: 'me', text: 'Make my weekly grocery list', at: _daysAgo(4, 9, 14)),
        ChatMsg(
          from: 'akaya',
          text: 'Milk, eggs, atta, tomatoes, onions, coffee, bananas and paneer. Want me to save it as a Smart Note?',
          at: _daysAgo(4, 9, 15),
        ),
      ]),
    ];
    notes = [
      NoteItem(id: 'n1', text: 'Gift ideas for Neha: scented candles, a planner, the novel she mentioned', createdAt: _daysAgo(2), color: 'violet'),
      NoteItem(id: 'n2', text: 'Wi-Fi password for the studio: akaya-guest-2026', createdAt: _daysAgo(5), color: 'blue'),
    ];
    future = [
      FutureItem(id: 'sample-f1', to: 'Neha', text: 'Happy birthday, Neha! Wishing you a year full of laughter and big wins 🎉', when: _today(23, 59) + 60000, status: 'scheduled', channels: ['whatsapp'], repeat: 'yearly', createdAt: _daysAgo(1, 22, 15)),
      FutureItem(id: 'sample-f2', to: 'My account', text: 'Akaya now schedules messages and posts across 20 channels. Write once, send at the right time.', when: _today(24 + 10), status: 'scheduled', channels: ['linkedin', 'x'], createdAt: _today(9, 40)),
      FutureItem(id: 'sample-f3', to: 'Rahul', text: 'Hi Rahul, a gentle reminder that the invoice for September is due on Friday. Thanks!', when: _daysAgo(1, 18), status: 'sent', channels: ['gmail'], subject: 'Invoice reminder', createdAt: _daysAgo(2, 11)),
    ];
    today = [
      TodayEvent(id: 't4', kind: 'calendar', title: 'Team sync', time: _today(11, 30)),
      TodayEvent(id: 't5', kind: 'calendar', title: 'Dinner with Neha', time: _today(20, 30)),
      TodayEvent(id: 't6', kind: 'followup', title: 'Reply to Neha about Friday', time: _today(12)),
      TodayEvent(id: 't7', kind: 'followup', title: 'Send invoice to Rahul', time: _today(16)),
    ];
    reminders = [
      ReminderItem(id: 's1', title: 'Take BP medicine', category: 'health', due: now + 90 * 60000),
      ReminderItem(id: 's2', title: 'Drink water', category: 'health', due: now + 45 * 60000),
      ReminderItem(id: 's3', title: 'Call Rahul about the invoice', category: 'work', due: now + 120 * 60000),
      ReminderItem(id: 's4', title: 'Pay electricity bill ₹1,240', category: 'finance', due: now + 180 * 60000),
      ReminderItem(id: 's5', title: 'Study 1 hour', category: 'personal', due: now + 150 * 60000),
      ReminderItem(id: 's6', title: 'Morning exercise', category: 'personal', due: now - 3 * 3600000, done: true),
      ReminderItem(id: 's7', title: "Priya's birthday", category: 'dates', due: now + 4 * 86400000),
      ReminderItem(id: 's8', title: 'Reply to Neha about Friday', category: 'work', due: now - 2 * 3600000),
    ];
    activity = [
      ActivityItem(kind: 'voice', title: 'Voice Chat', input: "What's on my schedule today?", output: 'You have Team sync at 11:30 AM, a call with Rahul at 5 PM and dinner with Neha at 8:30 PM.', at: _today(9, 15)),
      ActivityItem(kind: 'floating', title: 'Reply to Rahul', input: 'हाँ, 4 बजे ठीक है। तब बात करते हैं।', output: 'Sure, 4 PM works for me. Talk then!', at: _today(8, 52), app: 'WhatsApp'),
      ActivityItem(kind: 'translation', title: 'Translate to Hindi', input: 'Dreams are not what you see in sleep, they are the ones that do not let you sleep.', output: 'सपने वो नहीं जो आप सोते समय देखते हैं, सपने वो हैं जो आपको सोने नहीं देते।', at: _today(8, 45), langs: 'English → Hindi'),
    ];
    voiceNotes = [
      VoiceNoteItem(id: 'vn-calc', title: 'Calculus – Derivatives', mode: 'lecture', subject: 'Mathematics', createdAt: _daysAgo(1, 11, 15), duration: 1712),
      VoiceNoteItem(id: 'vn-sales', title: 'Weekly sales sync', mode: 'business', subject: 'Sales', createdAt: _daysAgo(2, 14, 45), duration: 1240),
      VoiceNoteItem(id: 'vn-diwali', title: 'Diwali campaign ideas', mode: 'ideas', subject: 'Marketing', createdAt: _daysAgo(3, 9, 30), duration: 312),
    ];
    notices = [
      AppNotice(title: 'Reminder in 30 min', body: 'Call Rahul at 5:00 PM', at: _today(9, 30), icon: 'alarm'),
      AppNotice(title: 'Morning brief is ready', body: '2 meetings, 3 reminders and 1 follow-up today', at: _today(8), icon: 'agent'),
      AppNotice(title: 'Future Message scheduled', body: 'Birthday wish to Neha sends at 12:00 AM', at: _daysAgo(1, 21), icon: 'future', read: true),
    ];
  }

  int get unread => notices.where((n) => !n.read).length;

  void showToast(String message) {
    toast = message;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (toast == message) {
        toast = null;
        notifyListeners();
      }
    });
  }

  void signIn(String method, String contact) {
    signedIn = true;
    this.method = method;
    this.contact = contact;
    if (method == 'email') email = contact;
    notifyListeners();
  }

  void finishOnboarding() {
    onboardingDone = true;
    notifyListeners();
  }

  void logout() {
    signedIn = false;
    onboardingDone = false;
    method = null;
    contact = null;
    pendingEmail = null;
    emailVerified = false;
    notifyListeners();
  }

  void setTheme(String v) {
    theme = v;
    notifyListeners();
  }

  void setMode(String v) {
    mode = v;
    notifyListeners();
  }

  void setFloating(bool v) {
    floating = v;
    notifyListeners();
  }

  void setTextSize(double v) {
    textSize = v;
    notifyListeners();
  }

  void setNotifications(bool v) {
    notificationsOn = v;
    notifyListeners();
  }

  void setLanguage(String v) {
    language = v;
    notifyListeners();
  }

  void setVoiceSpeed(double v) {
    voiceSpeed = v;
    notifyListeners();
  }

  void setReminderLead(int v) {
    reminderLead = v;
    notifyListeners();
  }

  void setAutoFollowUp(bool v) {
    autoFollowUp = v;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in notices) {
      n.read = true;
    }
    notifyListeners();
  }

  void addNote(String text, String color) {
    notes.insert(0, NoteItem(id: 'n${notes.length + 1}', text: text, createdAt: DateTime.now().millisecondsSinceEpoch, color: color));
    notifyListeners();
  }

  void deleteNote(String id) {
    notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  String mockReply(String input) {
    final q = input.toLowerCase();
    if (q.contains('remind')) return 'Done! I\'ve added a reminder. I\'ll nudge you on time.';
    if (q.contains('translate') || q.contains('hindi')) return 'Here you go: "See you tomorrow at 6, I\'ll bring the documents." Want me to copy it or send it?';
    if (q.contains('trip') || q.contains('goa')) return 'Here is a quick plan: Day 1 explore the old town, Day 2 beaches and a sunset cruise, Day 3 local food trail.';
    if (q.contains('summar') || q.contains('day')) return 'Summary: 2 meetings today (Team sync 11:30 AM, Dinner with Neha 8:30 PM), 3 reminders and 2 follow-ups pending.';
    if (RegExp(r'hi|hello|hey|namaste').hasMatch(q)) return 'Hi Priya! I can chat, set reminders, translate in 99+ languages, read your screen and schedule messages. What shall we do?';
    final clip = input.length > 60 ? input.substring(0, 60) : input;
    return 'Got it! Here\'s a thought on "$clip": I\'d start by breaking it into 3 small steps. Want me to set a reminder for the first one?';
  }

  String sendChat(String? id, String text, {List<ChatAttachment> attachments = const [], List<String> modes = const []}) {
    ChatThread thread;
    final title = text.trim().isEmpty ? (attachments.isEmpty ? 'Attachment' : attachments.first.name) : text.trim();
    if (id == null || chats.every((c) => c.id != id)) {
      final nid = 'c${DateTime.now().millisecondsSinceEpoch}';
      thread = ChatThread(id: nid, title: title.length > 32 ? '${title.substring(0, 30)}…' : title, updatedAt: DateTime.now().millisecondsSinceEpoch, messages: []);
      chats.insert(0, thread);
      id = nid;
    } else {
      thread = chats.firstWhere((c) => c.id == id);
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    thread.messages.add(ChatMsg(from: 'me', text: text, at: now, attachments: attachments, modes: modes));
    thread.updatedAt = now;
    notifyListeners();
    final action = text.trim().isEmpty ? null : detectLinkAction(text);
    final deep = modes.contains('deep');
    Future.delayed(Duration(milliseconds: deep ? 1600 : 700), () {
      final base = action != null ? actionReply(action) : mockReply(text.isEmpty ? title : text);
      final extra = attachments.isEmpty ? '' : '\n\nI can see ${attachments.map((a) => a.name).join(', ')}.';
      final modeNote = modes.contains('web') ? ' I checked the web for this.' : (deep ? ' I thought this through carefully.' : '');
      final gen = modes.contains('image')
          ? [ChatAttachment(id: 'gen$now', kind: 'generated', name: '${text.trim().isEmpty ? 'Akaya image' : (text.trim().length > 28 ? text.trim().substring(0, 28) : text.trim())}.jpg', meta: 'Sample', visual: true)]
          : const <ChatAttachment>[];
      thread.messages.add(ChatMsg(from: 'akaya', text: '$base$modeNote$extra', at: DateTime.now().millisecondsSinceEpoch, action: action, attachments: gen));
      thread.updatedAt = DateTime.now().millisecondsSinceEpoch;
      notifyListeners();
    });
    return id;
  }

  void addReminder(String title, String category, {String priority = 'normal', int? due}) {
    reminders.insert(0, ReminderItem(id: 'r${DateTime.now().millisecondsSinceEpoch}', title: title, category: category, due: due ?? DateTime.now().millisecondsSinceEpoch + 3600000, sample: false, priority: priority));
    notifyListeners();
  }

  void toggleReminder(String id) {
    for (final r in reminders) {
      if (r.id == id) r.done = !r.done;
    }
    notifyListeners();
  }

  void cancelFuture(String id) {
    future.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void sendFutureNow(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final m in future) {
      if (m.id == id) {
        m.status = 'sent';
        m.when = now;
      }
    }
    notifyListeners();
  }

  void scheduleFuture({
    required String to,
    required String text,
    required int when,
    required List<String> channels,
    String repeat = 'once',
    String? subject,
    String? id,
  }) {
    if (id != null) {
      for (final m in future) {
        if (m.id == id) {
          m.to = to;
          m.text = text;
          m.when = when;
          m.channels = channels;
          m.repeat = repeat;
          m.subject = subject;
          m.status = 'scheduled';
        }
      }
    } else {
      future.insert(
        0,
        FutureItem(
          id: 'f${DateTime.now().millisecondsSinceEpoch}',
          to: to,
          text: text,
          when: when,
          status: 'scheduled',
          channels: List.of(channels),
          repeat: repeat,
          subject: subject,
        ),
      );
    }
    notifyListeners();
  }

  void toggleHistoryPin(String key) {
    if (!pinnedHistory.add(key)) pinnedHistory.remove(key);
    notifyListeners();
  }

  void hideHistory(String key) {
    hiddenHistory.add(key);
    pinnedHistory.remove(key);
    notifyListeners();
  }

  void connect(String id, String account) {
    connected[id] = account;
    notifyListeners();
  }

  void disconnect(String id) {
    connected.remove(id);
    notifyListeners();
  }

  void toggleToday(String id) {
    for (final t in today) {
      if (t.id == id) t.done = !t.done;
    }
    notifyListeners();
  }

  void enterPreview() {
    signedIn = true;
    onboardingDone = true;
    method = 'google';
    contact = email;
  }
}

class AkayaScope extends InheritedNotifier<AppModel> {
  const AkayaScope({super.key, required AppModel model, required super.child}) : super(notifier: model);

  static AppModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AkayaScope>();
    assert(scope != null, 'AkayaScope missing');
    return scope!.notifier!;
  }
}
