import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const violet = Color(0xFF7C3AED);
  static const blue = Color(0xFF2563EB);
  static const bg = Color(0xFF0B1020);
  static const surface = Color(0xFF111827);
  static const surfaceLight = Color(0xFF1B2437);
  static const border = Color(0xFF2A3550);
  static const text = Color(0xFFF8FAFC);
  static const textMuted = Color(0xFF94A3B8);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static const gradient = LinearGradient(
    colors: [violet, blue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.violet,
          secondary: AppColors.blue,
          surface: AppColors.surface,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.violet.withOpacity(0.25),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, color: AppColors.text),
          ),
        ),
      );
}

enum EngagementStatus { invited, accepted, inProgress, done, overdue, cancelled }

extension EngagementStatusX on EngagementStatus {
  String get label => switch (this) {
        EngagementStatus.invited => 'Invité',
        EngagementStatus.accepted => 'Accepté',
        EngagementStatus.inProgress => 'En cours',
        EngagementStatus.done => 'Terminé',
        EngagementStatus.overdue => 'En retard',
        EngagementStatus.cancelled => 'Annulé',
      };

  Color get color => switch (this) {
        EngagementStatus.invited => AppColors.blue,
        EngagementStatus.accepted => AppColors.violet,
        EngagementStatus.inProgress => AppColors.blue,
        EngagementStatus.done => AppColors.success,
        EngagementStatus.overdue => AppColors.danger,
        EngagementStatus.cancelled => AppColors.textMuted,
      };
}

enum EngagementCategory { money, object, service }

extension EngagementCategoryX on EngagementCategory {
  String get label => switch (this) {
        EngagementCategory.money => 'Argent',
        EngagementCategory.object => 'Objet',
        EngagementCategory.service => 'Service',
      };

  IconData get icon => switch (this) {
        EngagementCategory.money => Icons.account_balance_wallet_outlined,
        EngagementCategory.object => Icons.inventory_2_outlined,
        EngagementCategory.service => Icons.handshake_outlined,
      };
}

class Engagement {
  final String id;
  final String title;
  final EngagementCategory category;
  final DateTime dueDate;
  final EngagementStatus status;
  final String counterpart;

  const Engagement({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.status,
    required this.counterpart,
  });
}

// Données de démonstration. À remplacer par Firestore.
final List<Engagement> sampleEngagements = [
  Engagement(
    id: '1',
    title: 'Remboursement de 25 000 GNF',
    category: EngagementCategory.money,
    dueDate: DateTime(2025, 4, 12),
    status: EngagementStatus.inProgress,
    counterpart: 'Mamadou Diallo',
  ),
  Engagement(
    id: '2',
    title: 'Prêt d\'un ordinateur',
    category: EngagementCategory.object,
    dueDate: DateTime(2025, 4, 15),
    status: EngagementStatus.accepted,
    counterpart: 'Aminata Sow',
  ),
  Engagement(
    id: '3',
    title: 'Service rendu',
    category: EngagementCategory.service,
    dueDate: DateTime(2025, 4, 20),
    status: EngagementStatus.invited,
    counterpart: 'Ahmed Diallo',
  ),
  Engagement(
    id: '4',
    title: 'Remboursement repas',
    category: EngagementCategory.money,
    dueDate: DateTime(2025, 1, 12),
    status: EngagementStatus.done,
    counterpart: 'Fatou Camara',
  ),
];

class StatusChip extends StatelessWidget {
  final EngagementStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onPressed,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _months = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
];

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  int _count(bool Function(Engagement) test) =>
      sampleEngagements.where(test).length;

  @override
  Widget build(BuildContext context) {
    final inProgress = _count((e) => e.status == EngagementStatus.inProgress);
    final upcoming = _count((e) =>
        e.status == EngagementStatus.accepted ||
        e.status == EngagementStatus.invited);
    final done = _count((e) => e.status == EngagementStatus.done);
    final overdue = _count((e) => e.status == EngagementStatus.overdue);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _header(),
          const SizedBox(height: 20),
          const Text('Bonjour, Thierno 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Voici un résumé de vos engagements.',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 18),
          _summaryCard(inProgress),
          const SizedBox(height: 12),
          Row(
            children: [
              _statTile('$upcoming', 'À venir', Icons.event, AppColors.blue),
              const SizedBox(width: 10),
              _statTile('$done', 'Terminés', Icons.check_circle,
                  AppColors.success),
              const SizedBox(width: 10),
              _statTile('$overdue', 'En retard', Icons.warning_amber_rounded,
                  AppColors.danger),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mes engagements récents',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              TextButton(onPressed: () {}, child: const Text('Voir tout')),
            ],
          ),
          ...sampleEngagements.take(3).map(_engagementTile),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Créer un engagement',
            icon: Icons.add,
            onPressed: () {
              // TODO: ouvrir l'écran "Nouvel engagement"
            },
          ),
        ],
      ),
    );
  }

  Widget _header() => Row(
        children: [
          ShaderMask(
            shaderCallback: (r) => AppColors.gradient.createShader(r),
            child: const Text('PROMIZ',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Colors.white)),
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.violet,
            child: Text('T', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      );

  Widget _summaryCard(int count) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text('$count',
                style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(width: 14),
            const Expanded(
              child: Text('Engagements en cours',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      );

  Widget _statTile(String value, String label, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      );

  Widget _engagementTile(Engagement e) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.violet.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(e.category.icon, color: AppColors.violet, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(formatDate(e.dueDate),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            StatusChip(status: e.status),
          ],
        ),
      );
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Bientôt disponible',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    PlaceholderScreen(title: 'Engagements'),
    PlaceholderScreen(title: 'Notifications'),
    PlaceholderScreen(title: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil'),
          NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'Engagements'),
          NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Notifications'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const PromizApp());
}

class PromizApp extends StatelessWidget {
  const PromizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PROMIZ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}
