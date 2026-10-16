import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../theme/app_theme.dart';
import 'section_page.dart';

enum AppSection { home, announcements, events, social, calculator }

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.database, required this.darkMode, required this.onThemeChanged});

  final AppDatabase database;
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection _section = AppSection.home;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  void _open(AppSection section) => setState(() => _section = section);

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const CommunitySplash();
    final section = _section;
    return Scaffold(
      appBar: section == AppSection.home
          ? AppBar(
              title: const _BrandLockup(),
              actions: [
                IconButton(
                  tooltip: widget.darkMode ? 'Tema chiaro' : 'Tema scuro',
                  onPressed: () => widget.onThemeChanged(!widget.darkMode),
                  icon: Icon(widget.darkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                ),
                const SizedBox(width: 8),
              ],
            )
          : AppBar(
              leading: IconButton(onPressed: () => _open(AppSection.home), icon: const Icon(Icons.arrow_back_rounded)),
              title: Text(_sectionTitle(section)),
              actions: [
                IconButton(
                  tooltip: widget.darkMode ? 'Tema chiaro' : 'Tema scuro',
                  onPressed: () => widget.onThemeChanged(!widget.darkMode),
                  icon: Icon(widget.darkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                ),
              ],
            ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: section == AppSection.home
            ? HomePage(key: const ValueKey('home'), onOpen: _open)
            : SectionPage(key: ValueKey(section), section: section, database: widget.database),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: section == AppSection.home ? 0 : 1,
        onDestinationSelected: (index) => index == 0 ? _open(AppSection.home) : _open(AppSection.events),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event_rounded), label: 'Agenda'),
        ],
      ),
    );
  }
}

String _sectionTitle(AppSection section) => switch (section) {
  AppSection.announcements => 'Avvisi', AppSection.events => 'Eventi',
  AppSection.social => 'Social', AppSection.calculator => 'Calcolatore punti',
  AppSection.home => 'ApPonte',
};

class CommunitySplash extends StatelessWidget {
  const CommunitySplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _BridgeMark(size: 132),
          const SizedBox(height: 26),
          const Text('ApPonte', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -1.5)),
          const SizedBox(height: 8),
          Text('QUARTIERE PONTE', style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 3)),
          const SizedBox(height: 44),
          const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.softRed)),
        ]),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();
  @override
  Widget build(BuildContext context) => Row(children: [
    const _BridgeMark(size: 48), const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ApPonte', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, height: 1.1)),
      Text('QUARTIERE PONTE', style: TextStyle(fontSize: 8, letterSpacing: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]),
  ]);
}

class _BridgeMark extends StatelessWidget {
  const _BridgeMark({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/ponte_logo.png', width: size, height: size, fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpen});
  final ValueChanged<AppSection> onOpen;

  @override
  Widget build(BuildContext context) {
    final sections = [
      _SectionInfo(AppSection.announcements, 'Avvisi', 'Le novità del quartiere', Icons.campaign_rounded, const Color(0xFFF7E3DE)),
      _SectionInfo(AppSection.events, 'Eventi', 'Cose belle da fare insieme', Icons.wb_sunny_rounded, const Color(0xFFF8DFD0)),
      _SectionInfo(AppSection.social, 'Social', 'La piazza è aperta', Icons.forum_rounded, const Color(0xFFF5DDD8)),
      _SectionInfo(AppSection.calculator, 'Calcola punti', 'Tieni il conto dei risultati', Icons.calculate_rounded, const Color(0xFFE3DFF0)),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 30), children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppTheme.ink, borderRadius: BorderRadius.circular(28)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(30)),
            child: const Text('IL TUO QUARTIERE, PIÙ VICINO', style: TextStyle(color: AppTheme.softRed, fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w700))),
          const SizedBox(height: 18),
          const Text('Ciao,\nQuartiere Ponte.', style: TextStyle(color: Colors.white, fontSize: 31, height: 1.08, fontWeight: FontWeight.w700, letterSpacing: -.7)),
          const SizedBox(height: 12),
          Text('Tutto quello che ci unisce, in un unico posto.', style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 14)),
          const SizedBox(height: 20),
          const Row(children: [Icon(Icons.location_on_outlined, color: AppTheme.softRed, size: 17), SizedBox(width: 5), Text('Quartiere Ponte', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))]),
        ]),
      ),
      const SizedBox(height: 27),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('La vita del quartiere', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -.4)),
        Text('ESPLORA', style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.primary, letterSpacing: 1.3, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 14),
      ...sections.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Material(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20), onTap: () => onOpen(item.section),
            child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(16)), child: Icon(item.icon, color: AppTheme.ink, size: 24)),
              const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4), Text(item.subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
              ])),
              Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ])),
          ),
        ),
      )),
      const SizedBox(height: 7),
      Center(child: Text('Fatto con cura, per chi vive qui.', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant))),
    ]);
  }
}

class _SectionInfo {
  const _SectionInfo(this.section, this.title, this.subtitle, this.icon, this.color);
  final AppSection section;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
