import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';

class SectionPage extends StatefulWidget {
  const SectionPage({super.key, required this.section, required this.database});
  final AppSection section;
  final AppDatabase database;

  @override
  State<SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  final _scoreA = TextEditingController();
  final _scoreB = TextEditingController();
  final _post = TextEditingController();
  late Future<List<Map<String, Object?>>> _items;

  @override
  void initState() {
    super.initState();
    _items = _load();
  }

  Future<List<Map<String, Object?>>> _load() {
    final table = switch (widget.section) {
      AppSection.announcements => 'announcements',
      AppSection.events => 'events',
      _ => 'social_posts',
    };
    return widget.database.getItems(table);
  }

  @override
  void dispose() {
    _scoreA.dispose(); _scoreB.dispose(); _post.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.section == AppSection.calculator) return _calculator(context);
    return FutureBuilder<List<Map<String, Object?>>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Non è stato possibile caricare i contenuti.'));
        final items = snapshot.data ?? [];
        return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 28), children: [
          _intro(context),
          if (widget.section == AppSection.social) ...[
            const SizedBox(height: 20),
            TextField(controller: _post, maxLines: 3, decoration: const InputDecoration(hintText: 'Condividi qualcosa con il quartiere…')),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerRight, child: FilledButton.icon(
              onPressed: _publish, icon: const Icon(Icons.send_rounded, size: 17), label: const Text('Pubblica'),
            )),
          ],
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(child: Padding(padding: const EdgeInsets.all(19), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (widget.section == AppSection.events) _dateBadge(item['starts_at'] as String),
                if (widget.section == AppSection.events) const SizedBox(width: 13),
                Expanded(child: Text(item['title'] as String? ?? item['author'] as String? ?? 'Dal quartiere', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                if (item['pinned'] == 1) const Icon(Icons.push_pin_rounded, size: 17, color: AppTheme.coral),
              ]),
              const SizedBox(height: 11),
              Text(item['body'] as String? ?? item['details'] as String? ?? '', style: TextStyle(height: 1.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              if (widget.section == AppSection.events) ...[
                const SizedBox(height: 13),
                Row(children: [Icon(Icons.place_outlined, size: 16, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 5), Text(item['location'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]),
              ],
            ]))),
          )),
        ]);
      },
    );
  }

  Widget _intro(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(23)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(switch (widget.section) { AppSection.announcements => 'Restiamo in contatto.', AppSection.events => 'Ci vediamo in giro.', _ => 'Una piazza digitale.' }, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 21)),
      const SizedBox(height: 7),
      Text(switch (widget.section) { AppSection.announcements => 'Informazioni e aggiornamenti dalla comunità.', AppSection.events => 'Occasioni per stare bene, insieme.', _ => 'Idee, domande e piccoli gesti di ogni giorno.' }, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]),
  );

  Widget _dateBadge(String iso) {
    final date = DateTime.tryParse(iso)?.toLocal() ?? DateTime.now();
    const months = ['GEN', 'FEB', 'MAR', 'APR', 'MAG', 'GIU', 'LUG', 'AGO', 'SET', 'OTT', 'NOV', 'DIC'];
    return Container(width: 45, padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: AppTheme.coral.withOpacity(.15), borderRadius: BorderRadius.circular(12)), child: Column(children: [
      Text('${date.day}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.ink)),
      Text(months[date.month - 1], style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppTheme.ink)),
    ]));
  }

  Future<void> _publish() async {
    final text = _post.text.trim();
    if (text.isEmpty) return;
    await widget.database.addPost(text);
    if (!mounted) return;
    _post.clear();
    setState(() => _items = _load());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messaggio pubblicato')));
  }

  Widget _calculator(BuildContext context) {
    final a = int.tryParse(_scoreA.text) ?? 0;
    final b = int.tryParse(_scoreB.text) ?? 0;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 28), children: [
      _intro(context), const SizedBox(height: 22),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Il tabellone', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 5), Text('Segnate i punti e scoprite il risultato.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 22),
        Row(children: [
          Expanded(child: _scoreInput('Squadra A', _scoreA)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('—', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300))),
          Expanded(child: _scoreInput('Squadra B', _scoreB)),
        ]),
        const SizedBox(height: 22),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: AppTheme.ink, borderRadius: BorderRadius.circular(18)), child: Column(children: [
          Text(a == b ? 'IN PAREGGIO' : a > b ? 'VINCE SQUADRA A' : 'VINCE SQUADRA B', style: const TextStyle(color: AppTheme.softRed, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7), Text('$a  —  $b', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 30)),
        ])),
        const SizedBox(height: 12),
        TextButton.icon(onPressed: () => setState(() { _scoreA.clear(); _scoreB.clear(); }), icon: const Icon(Icons.refresh_rounded, size: 17), label: const Text('Azzera punteggio')),
      ]))),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.coral), const SizedBox(width: 12),
        Expanded(child: Text('Pensato per una partita improvvisata in piazza. Il punteggio resta sul dispositivo mentre usi l’app.', style: TextStyle(height: 1.45, fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
      ]))),
    ]);
  }

  Widget _scoreInput(String label, TextEditingController controller) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    TextField(controller: controller, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700), decoration: const InputDecoration(hintText: '0'), onChanged: (_) => setState(() {})),
  ]);
}
