import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const GameCenterApp());

const bg = Color(0xFF090D1A);
const panel = Color(0xFF141B2E);
const muted = Color(0xFF98A4BD);
const accent = Color(0xFF8B5CF6);

class GameCenterApp extends StatelessWidget {
  const GameCenterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'GameCenter',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark),
      fontFamily: 'Arial',
      useMaterial3: true,
    ),
    home: const HomePage(),
  );
}

class Game {
  Game(this.name, this.category, this.emoji, this.colors, this.url, {this.description = 'משחק מהנה שמחכה לך'});
  final String name, category, emoji, description, url;
  final List<Color> colors;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final search = TextEditingController();
  String category = 'הכול';
  final categories = ['הכול', 'חשיבה', 'קלפים', 'אסטרטגיה', 'יצירה', 'מילים', 'עוד'];
  final games = <Game>[
    Game('סוליטר', 'קלפים', '🃏', [Color(0xFF2563EB), Color(0xFF7C3AED)], 'https://www.mattegames.com/games/solitaire/', description: 'משחק קלפים קלאסי'),
    Game('סודוקו', 'חשיבה', '🔢', [Color(0xFF0F9D8A), Color(0xFF22C55E)], 'https://www.mattegames.com/games/sudoku/', description: 'חדדו את החשיבה עם מספרים'),
    Game('שחמט', 'אסטרטגיה', '♟️', [Color(0xFFEA580C), Color(0xFFDC2626)], 'https://www.mattegames.com/games/chess/', description: 'שחקו שחמט נגד המחשב'),
    Game('ארקייד וזריזות', 'עוד', '🐍', [Color(0xFF475569), Color(0xFF7C3AED)], 'https://visu.network/games/', description: 'גלו משחקי ארקייד וזריזות'),
    Game('2048', 'חשיבה', '🔢', [Color(0xFF0891B2), Color(0xFF2563EB)], 'https://www.mattegames.com/games/2048/', description: 'מזגו מספרים והגיעו ל־2048'),
    Game('צביעה לפי מספרים', 'יצירה', '🎨', [Color(0xFFDB2777), Color(0xFF9333EA)], 'https://www.mattegames.com/games/coloring/', description: 'צבעו תמונות לפי מספרים'),
    Game('אתגר מילים יומי', 'מילים', '🔤', [Color(0xFF0D9488), Color(0xFF0EA5E9)], 'https://www.mattegames.com/games/matte/', description: 'אתגר מילים בסגנון Wordle'),
    Game('עוד משחקים', 'עוד', '🎮', [Color(0xFF6D28D9), Color(0xFF0891B2)], 'https://www.mattegames.com/', description: 'גלו משחקים נוספים בחינם'),
  ];

  List<Game> get visible => games.where((g) =>
    (category == 'הכול' || g.category == category) &&
    ('${g.name} ${g.category}'.toLowerCase().contains(search.text.toLowerCase()))
  ).toList();

  Future<void> openGame(Game game) async {
    final uri = Uri.tryParse(game.url);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http') || uri.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('קישור המשחק אינו תקין')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GamePlayerPage(game: game),
    ));
  }

  void addGame() {
    final name = TextEditingController();
    final link = TextEditingController();
    showDialog(context: context, builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: panel,
        title: const Text('הוספת משחק חדש'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'שם המשחק')),
          const SizedBox(height: 10),
          TextField(controller: link, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'קישור למשחק (מתחיל ב־https://)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ביטול')),
          FilledButton(onPressed: () {
            final uri = Uri.tryParse(link.text.trim());
            if (name.text.trim().isNotEmpty && uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty) {
              setState(() => games.insert(0, Game(name.text.trim(), 'עוד', '🎮', [accent, const Color(0xFF2563EB)], uri.toString())));
              Navigator.pop(ctx);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('יש להזין שם וקישור תקין שמתחיל ב־https://')));
            }
          }, child: const Text('הוספה')),
        ],
      ),
    ));
  }

  @override
  void dispose() { search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 760;
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addGame, backgroundColor: accent,
        icon: const Icon(Icons.add_rounded), label: const Text('הוסף משחק'),
      ),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(wide ? 34 : 18, 20, wide ? 34 : 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [accent, Color(0xFF22D3EE)]),
                  borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 27)),
                const SizedBox(width: 12),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('GAMECENTER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.4)),
                  Text('כל המשחקים במקום אחד', style: TextStyle(color: muted, fontSize: 12)),
                ]),
                const Spacer(),
                if (wide) TextButton.icon(onPressed: addGame, icon: const Icon(Icons.add), label: const Text('הוסף משחק')),
                IconButton(onPressed: () => setState(() { category = 'הכול'; search.clear(); }), icon: const Icon(Icons.home_rounded), tooltip: 'דף הבית'),
              ]),
              const SizedBox(height: 28),
              Container(
                width: double.infinity, padding: EdgeInsets.all(wide ? 30 : 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft,
                    colors: [Color(0xFF31216D), Color(0xFF17264B), Color(0xFF102C3D)]),
                  border: Border.all(color: Colors.white.withValues(alpha: .08)),
                ),
                child: Stack(children: [
                  Positioned(left: 10, top: -14, child: Icon(Icons.videogame_asset_rounded, size: wide ? 130 : 90, color: Colors.white.withValues(alpha: .07))),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(30)),
                      child: const Text('🎮  ברוכים הבאים ל־GameCenter', style: TextStyle(fontSize: 12))),
                    const SizedBox(height: 15),
                    Text('המשחק הבא שלך\nמתחיל כאן', style: TextStyle(fontSize: wide ? 35 : 29, height: 1.15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 9),
                    const Text('מגלים, משחקים ונהנים — כל עולם הגיימינג במקום אחד.', style: TextStyle(color: Color(0xFFD1D5E8), fontSize: 14)),
                    const SizedBox(height: 19),
                    FilledButton.icon(onPressed: () => setState(() => category = 'הכול'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                      icon: const Icon(Icons.explore_rounded), label: const Text('גלו את המשחקים')),
                  ]),
                ]),
              ),
              const SizedBox(height: 25),
              TextField(controller: search, onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'חיפוש משחקים...',
                  hintStyle: const TextStyle(color: muted),
                  prefixIcon: const Icon(Icons.search_rounded, color: muted),
                  filled: true, fillColor: panel,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                )),
              const SizedBox(height: 22),
              const Text('קטגוריות משחקים', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal,
                itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) => ChoiceChip(label: Text(categories[i]), selected: category == categories[i],
                  onSelected: (_) => setState(() => category = categories[i]),
                  selectedColor: accent, backgroundColor: panel, side: BorderSide.none,
                  labelStyle: TextStyle(color: category == categories[i] ? Colors.white : const Color(0xFFCBD5E1), fontWeight: FontWeight.w600)))),
              const SizedBox(height: 25),
              Row(children: [
                const Text('🎮  המשחקים שלנו', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                const Spacer(), Text('${visible.length} משחקים', style: const TextStyle(color: muted, fontSize: 12)),
              ]),
              const SizedBox(height: 14),
            ]),
          )),
          SliverPadding(padding: EdgeInsets.fromLTRB(wide ? 34 : 18, 0, wide ? 34 : 18, 100),
            sliver: SliverLayoutBuilder(builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              final count = width > 900 ? 4 : width > 580 ? 3 : 2;
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: wide ? 1.13 : .91),
                delegate: SliverChildBuilderDelegate((ctx, i) => GameCard(game: visible[i], onTap: () => openGame(visible[i])), childCount: visible.length),
              );
            }),
          ),
        ]),
      ))),
    ));
  }
}

class GamePlayerPage extends StatefulWidget {
  const GamePlayerPage({super.key, required this.game});
  final Game game;

  @override
  State<GamePlayerPage> createState() => _GamePlayerPageState();
}

class _GamePlayerPageState extends State<GamePlayerPage> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'gamecenter-iframe-${widget.game.hashCode}-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final frame = html.IFrameElement()
        ..src = widget.game.url
        ..title = widget.game.name
        ..allow = 'fullscreen; autoplay; gamepad'
        ..setAttribute('allowfullscreen', 'true')
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
      return frame;
    });
  }

  Future<void> _openOutside() async {
    final uri = Uri.tryParse(widget.game.url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('לא הצלחנו לפתוח את המשחק בחלון חדש.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: panel,
        title: Text(widget.game.name),
        leading: IconButton(
          tooltip: 'חזרה למשחקים',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _openOutside,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('פתיחה באתר המשחק'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: HtmlElementView(viewType: _viewType),
          ),
          Container(
            width: double.infinity,
            color: panel,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: const Text(
              'אם המשחק לא נטען, ייתכן שהאתר שלו חוסם הצגה בתוך חלון. אפשר לפתוח אותו באתר המקורי.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ),
        ],
      ),
    ),
  );
}

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, required this.onTap});
  final Game game;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: panel, borderRadius: BorderRadius.circular(20), clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: game.colors)),
        child: Stack(children: [
          Positioned(left: -15, bottom: -22, child: Icon(Icons.blur_circular, size: 115, color: Colors.white.withValues(alpha: .10))),
          Center(child: Text(game.emoji, style: const TextStyle(fontSize: 54))),
          Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: .22), borderRadius: BorderRadius.circular(20)),
            child: Text(game.category, style: const TextStyle(fontSize: 10, color: Colors.white)))),
        ]),
      )),
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 12), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(game.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 3), Text(game.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 10)),
        ])),
        const SizedBox(width: 5), const Icon(Icons.open_in_new_rounded, color: Color(0xFFA78BFA), size: 22),
      ])),
    ])),
  );
}
