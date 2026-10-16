/// Chat commerce intents, matching @akaya/affiliate detectIntent for the catalog aliases.
class LinkAction {
  const LinkAction({
    required this.platform,
    required this.name,
    required this.intent,
    required this.summary,
    required this.url,
    required this.earn,
  });
  final String platform;
  final String name;
  final String intent;
  final String summary;
  final String url;
  final bool earn;
}

class _Plat {
  const _Plat(this.id, this.name, this.category, this.aliases, {this.hotel = false, this.flight = false, this.exp = false, this.earn = true});
  final String id, name, category;
  final List<String> aliases;
  final bool hotel, flight, exp, earn;
}

const _filler = {
  'se', 'pe', 'par', 'on', 'from', 'via', 'in', 'mein', 'me', 'order', 'karo', 'kar', 'kardo', 'do', 'mangao', 'mangwa', 'mangwao', 'book', 'khareedo', 'buy', 'get', 'search', 'find', 'open', 'chahiye', 'please', 'plz', 'ek', 'the', 'a', 'an', 'for', 'jana', 'hai', 'hain', 'ko', 'tak', 'to', 'app', 'wala', 'wali', 'ka', 'ki', 'ke', 'mujhe', 'i', 'want', 'need', 'some',
};

const _plats = <_Plat>[
  _Plat('amazon', 'Amazon', 'shopping', ['amazon.in', 'amazon', 'amzn']),
  _Plat('flipkart', 'Flipkart', 'shopping', ['flipkart']),
  _Plat('myntra', 'Myntra', 'shopping', ['myntra']),
  _Plat('ajio', 'Ajio', 'shopping', ['ajio']),
  _Plat('nykaa', 'Nykaa', 'shopping', ['nykaa']),
  _Plat('croma', 'Croma', 'shopping', ['croma']),
  _Plat('tata-cliq', 'Tata CLiQ', 'shopping', ['tata cliq', 'tatacliq']),
  _Plat('meesho', 'Meesho', 'shopping', ['meesho']),
  _Plat('booking', 'Booking.com', 'travel', ['booking.com'], hotel: true),
  _Plat('agoda', 'Agoda', 'travel', ['agoda'], hotel: true),
  _Plat('expedia', 'Expedia', 'travel', ['expedia'], hotel: true),
  _Plat('hotels-com', 'Hotels.com', 'travel', ['hotels.com', 'hotels com'], hotel: true),
  _Plat('tripadvisor', 'Tripadvisor', 'travel', ['tripadvisor', 'trip advisor'], hotel: true, exp: true),
  _Plat('makemytrip', 'MakeMyTrip', 'travel', ['makemytrip', 'make my trip', 'mmt'], hotel: true, flight: true),
  _Plat('goibibo', 'Goibibo', 'travel', ['goibibo', 'go ibibo'], hotel: true, flight: true),
  _Plat('cleartrip', 'Cleartrip', 'travel', ['cleartrip', 'clear trip'], flight: true),
  _Plat('skyscanner', 'Skyscanner', 'travel', ['skyscanner', 'sky scanner'], flight: true),
  _Plat('aviasales', 'Aviasales', 'travel', ['aviasales'], flight: true),
  _Plat('klook', 'Klook', 'travel', ['klook'], exp: true),
  _Plat('getyourguide', 'GetYourGuide', 'travel', ['getyourguide', 'get your guide', 'gyg'], exp: true),
  _Plat('swiggy', 'Swiggy', 'food', ['swiggy'], earn: false),
  _Plat('zomato', 'Zomato', 'food', ['zomato'], earn: false),
  _Plat('instamart', 'Swiggy Instamart', 'grocery', ['swiggy instamart', 'instamart'], earn: false),
  _Plat('blinkit', 'Blinkit', 'grocery', ['blinkit', 'grofers'], earn: false),
  _Plat('zepto', 'Zepto', 'grocery', ['zepto'], earn: false),
  _Plat('bigbasket', 'bigbasket', 'grocery', ['big basket', 'bigbasket'], earn: false),
  _Plat('amazon-fresh', 'Amazon Fresh', 'grocery', ['amazon fresh', 'amazonfresh']),
  _Plat('uber', 'Uber', 'ride', ['uber'], earn: false),
  _Plat('ola', 'Ola', 'ride', ['ola cabs', 'ola'], earn: false),
];

LinkAction? detectLinkAction(String input) {
  final text = input.length > 300 ? input.substring(0, 300) : input;
  final lower = text.toLowerCase();
  _Plat? plat;
  String? alias;
  for (final p in _plats) {
    final sorted = [...p.aliases]..sort((a, b) => b.length.compareTo(a.length));
    for (final a in sorted) {
      final re = RegExp('(^|[^a-z0-9.])${RegExp.escape(a)}(\$|[^a-z0-9])', caseSensitive: false);
      if (re.hasMatch(lower) && (alias == null || a.length > alias.length)) {
        plat = p;
        alias = a;
      }
    }
  }
  if (plat == null || alias == null) return null;
  final rest = lower.replaceFirst(RegExp('\\b${RegExp.escape(alias)}\\b'), ' ').replaceAll(RegExp(r'[^\p{L}\p{N}\s-]', unicode: true), ' ').split(RegExp(r'\s+')).where((w) => w.isNotEmpty && !_filler.contains(w)).toList();
  final q = rest.join(' ').trim();
  late final String intent;
  late final String summary;
  var param = q;
  final cat = plat.category;
  if (cat == 'food' || cat == 'grocery') {
    intent = q.isEmpty ? 'home' : cat;
    summary = q.isEmpty ? 'Open the app' : 'Search “$q”';
  } else if (cat == 'shopping') {
    intent = q.isEmpty ? 'home' : 'search';
    summary = q.isEmpty ? 'Open the app' : 'Search “$q”';
  } else if (cat == 'ride') {
    final drop = rest.where((w) => !const {'cab', 'ride', 'taxi', 'auto', 'book'}.contains(w)).join(' ').trim();
    intent = 'ride';
    param = drop;
    summary = drop.isEmpty ? 'Set your drop-off in the app' : 'Drop-off: $drop';
  } else if (cat == 'travel') {
    final codes = RegExp(r'\b([A-Z]{3})\b\s*(?:to|-|→|se)\s*\b([A-Z]{3})\b').firstMatch(text);
    final date = RegExp(r'\b(\d{4}-\d{2}-\d{2})\b').firstMatch(text)?.group(1);
    if (codes != null && plat.flight) {
      intent = 'flight';
      param = '${codes.group(1)}-${codes.group(2)}${date == null ? '' : '-$date'}';
      summary = ['${codes.group(1)} → ${codes.group(2)}', if (date != null) date].join(' · ');
    } else {
      final cityMatch = RegExp(r'\b(?:in|at|for|mein)\s+([a-z][a-z\s]{1,30}?)(?:\s+(?:on|from|par|pe|se|for)\b|$)').firstMatch(lower);
      final city = (cityMatch?.group(1)?.trim().isNotEmpty ?? false)
          ? cityMatch!.group(1)!.trim()
          : rest.where((w) => !const {'hotel', 'hotels', 'stay', 'stays', 'room', 'rooms', 'flight', 'flights', 'tour', 'tours', 'things', 'do'}.contains(w)).join(' ').trim();
      final wantsExp = RegExp(r'\b(tour|tours|things to do|activity|activities|experience|tickets?)\b').hasMatch(lower);
      if (wantsExp && plat.exp && city.isNotEmpty) {
        intent = 'experience';
        param = city;
        summary = 'Things to do: $city';
      } else if (plat.hotel && city.isNotEmpty) {
        intent = 'hotel';
        param = city;
        summary = 'Stays in $city';
      } else if (plat.exp && city.isNotEmpty) {
        intent = 'experience';
        param = city;
        summary = 'Things to do: $city';
      } else {
        intent = 'home';
        summary = 'Open the app';
      }
    }
  } else {
    return null;
  }
  return LinkAction(
    platform: plat.id,
    name: plat.name,
    intent: intent,
    summary: summary,
    url: _url(plat.id, intent, param),
    earn: plat.earn && intent != 'home',
  );
}

String actionReply(LinkAction a) {
  final pay = a.intent == 'ride' ? 'You confirm the ride' : (a.intent == 'home' ? 'You take it from there' : 'You check out and pay');
  return "Here's ${a.name} with that ready. $pay in ${a.name}; Akaya never orders or pays for you.";
}

String _url(String id, String intent, String param) {
  final q = Uri.encodeQueryComponent(param);
  final host = switch (id) {
    'amazon' => 'www.amazon.in',
    'flipkart' => 'www.flipkart.com',
    'swiggy' => 'www.swiggy.com',
    'zomato' => 'www.zomato.com',
    'uber' => 'm.uber.com',
    'ola' => 'book.olacabs.com',
    'booking' => 'www.booking.com',
    'makemytrip' => 'www.makemytrip.com',
    'myntra' => 'www.myntra.com',
    'blinkit' => 'blinkit.com',
    'zepto' => 'www.zeptonow.com',
    _ => 'www.$id.com',
  };
  final path = switch (intent) {
    'search' || 'food' || 'grocery' => '/search?q=$q',
    'hotel' => '/search?ss=$q',
    'flight' => '/flights?q=$q',
    'experience' => '/things-to-do?q=$q',
    'ride' => '/ride?dropoff=$q',
    _ => '/',
  };
  final sep = path.contains('?') ? '&' : '?';
  return 'https://$host$path${sep}utm_source=akaya&utm_medium=app&utm_campaign=chat';
}
