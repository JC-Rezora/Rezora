import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:booking_app/pages/register_page.dart';
import 'dart:math' as m;

double _cos(double x) => m.cos(x);
double _sin(double x) => m.sin(x);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zkdvfsetootvxxzplbpv.supabase.co',
    anonKey: 'sb_publishable_68UGxLMwIMDDf7_eklJqlg_MSoq2Udq',
  );

print('Supabase initialized');

  runApp(const BookingApp());
}

bool isVenueOpenNow(String openTime, String closeTime) {
  final now = TimeOfDay.now();

  final openParts = openTime.split(':');
  final closeParts = closeTime.split(':');

  final openMinutes =
      int.parse(openParts[0]) * 60 + int.parse(openParts[1]);

  final closeMinutes =
      int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);

  final nowMinutes = now.hour * 60 + now.minute;

  if (openMinutes <= closeMinutes) {
    return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
  }

  return nowMinutes >= openMinutes || nowMinutes <= closeMinutes;
}

class BookingApp extends StatelessWidget {
  const BookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Booking',
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF1E6B45),
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF3F4F6),

    // ✅ меньше и аккуратнее (влезет на экран)
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28, // было 34
        fontWeight: FontWeight.w900,
        height: 1.05,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16, // было 18
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(
        fontSize: 14, // было 16
        fontWeight: FontWeight.w600,
      ),
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // было 18
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E6EF)),
      ),
      focusedBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: const BorderSide(color: Color(0xFF1E6B45), width: 1.6),
),
    ),

    filledButtonTheme: FilledButtonThemeData(
  style: FilledButton.styleFrom(
    backgroundColor: const Color(0xFF1E6B45),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48), // было 52
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16, // было 18
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48), // было 52
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: const BorderSide(color: Color(0xFFE2E6EF)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16, // было 18
        ),
      ),
    ),
  ),

  // ✅ фикс масштаба текста, чтобы не разъезжалось на разных телефонах
  builder: (context, child) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: child!,
    );
  },

  home: const AuthPage(),
);
  }
}

/* =========================
   MODELS
========================= */

class UserBooking {
  final String id;
  final Venue venue;
  final TableModel table;
  final DateTime date;
  final TimeOfDay time;
  final int guests;

  UserBooking({
    required this.id,
    required this.venue,
    required this.table,
    required this.date,
    required this.time,
    required this.guests,
  });
}

class Venue {
  final String id;
  final String name;
  final String category;
  final String cuisine;
  final String address;
  final double rating;
  final int reviews;
  final int avgCheckKzt;
  final double distanceKm;
  final String openTime;
  final String closeTime;
  final String imageUrl;
  final List<TableModel> tables;

  const Venue({
    required this.id,
    required this.name,
    required this.category,
    required this.cuisine,
    required this.address,
    required this.rating,
    required this.reviews,
    required this.avgCheckKzt,
    required this.distanceKm,
    required this.openTime,
    required this.closeTime,
    required this.imageUrl,
    required this.tables,
  });
}

class PromoBanner {
  final String id;
  final String venueId;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isSponsored;
  final DateTime? validUntil;

  const PromoBanner({
    required this.id,
    required this.venueId,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isSponsored = true,
    this.validUntil,
  });
}

class TableModel {
  final String id;
  final int seats;
  final bool isAvailableNow;
  final int? minGuests;
  final int? maxGuests;
  final String locationLabel;

  const TableModel({
    required this.id,
    required this.seats,
    required this.isAvailableNow,
    required this.locationLabel,
    this.minGuests,
    this.maxGuests,
  });
}

enum SortBy { recommended, distance, rating, avgCheck }
enum VenueDetailsTab { booking, photos, reviews }

/* =========================
   MOCK DATA
========================= */

const _venues = <Venue>[
  Venue(
    id: 'pivovaroff',
    name: 'Пивоварофф',
    category: 'Ресторан',
    cuisine: 'Пивной ресторан',
    address: 'Астана, пр. Мангилик Ел 10',
    rating: 4.6,
    reviews: 1243,
    avgCheckKzt: 8500,
    distanceKm: 2.1,
    openTime: '12:00',
    closeTime: '02:00',
    imageUrl:
        'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=format&fit=crop&w=1400&q=70',
    tables: [
  TableModel(
    id: 'T1',
    seats: 2,
    isAvailableNow: true,
    locationLabel: 'У окна',
  ),
  TableModel(
    id: 'T2',
    seats: 4,
    isAvailableNow: true,
    locationLabel: 'Возле бара',
  ),
  TableModel(
    id: 'T3',
    seats: 6,
    isAvailableNow: false,
    locationLabel: 'В центре зала',
  ),
  TableModel(
    id: 'T4',
    seats: 4,
    isAvailableNow: true,
    locationLabel: 'Возле сцены',
  ),
  TableModel(
    id: 'T5',
    seats: 8,
    isAvailableNow: true,
    locationLabel: 'VIP зона',
  ),
],
  ),
  Venue(
    id: 'coffee_roasters',
    name: 'Coffee Roasters',
    category: 'Ресторан',
    cuisine: 'Кофейня',
    address: 'Астана, ул. Туран 22',
    rating: 4.7,
    reviews: 531,
    avgCheckKzt: 4500,
    distanceKm: 0.8,
    openTime: '08:00',
    closeTime: '23:00',
    imageUrl:
        'https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=1400&q=70',
    tables: [
  TableModel(
    id: 'T1',
    seats: 2,
    isAvailableNow: true,
    locationLabel: 'У окна',
  ),
  TableModel(
    id: 'T2',
    seats: 2,
    isAvailableNow: true,
    locationLabel: 'У стойки',
  ),
  TableModel(
    id: 'T3',
    seats: 4,
    isAvailableNow: true,
    locationLabel: 'В центре зала',
  ),
  TableModel(
    id: 'T4',
    seats: 4,
    isAvailableNow: false,
    locationLabel: 'В тихой зоне',
  ),
],
  ),
  Venue(
    id: 'italiano',
    name: 'Italiano',
    category: 'Ресторан',
    cuisine: 'Итальянская кухня',
    address: 'Астана, ул. Достык 5',
    rating: 4.8,
    reviews: 1045,
    avgCheckKzt: 15000,
    distanceKm: 3.4,
    openTime: '11:00',
    closeTime: '23:30',
    imageUrl:
        'https://images.unsplash.com/photo-1528137871618-79d2761e3fd5?auto=format&fit=crop&w=1400&q=70',
    tables: [
  TableModel(
    id: 'T1',
    seats: 2,
    isAvailableNow: true,
    locationLabel: 'У окна',
  ),
  TableModel(
    id: 'T2',
    seats: 4,
    isAvailableNow: true,
    locationLabel: 'Основной зал',
  ),
  TableModel(
    id: 'T3',
    seats: 4,
    isAvailableNow: false,
    locationLabel: 'Возле сцены',
  ),
  TableModel(
    id: 'T4',
    seats: 6,
    isAvailableNow: true,
    locationLabel: 'Семейная зона',
  ),
  TableModel(
    id: 'T5',
    seats: 8,
    isAvailableNow: true,
    locationLabel: 'VIP зона',
  ),
],
  ),
];

final _promoBanners = <PromoBanner>[
  PromoBanner(
    id: 'promo_1',
    venueId: 'coffee_roasters',
    title: 'Скидка 20% на завтраки',
    subtitle: 'До 12:00 каждый день',
    imageUrl:
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=80',
    validUntil: DateTime(2026, 12, 31),
  ),
  PromoBanner(
    id: 'promo_2',
    venueId: 'italiano',
    title: 'Вечер итальянской кухни',
    subtitle: 'Комплимент от шефа при брони',
    imageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1200&q=80',
    validUntil: DateTime(2026, 12, 31),
  ),
  PromoBanner(
    id: 'promo_3',
    venueId: 'pivovaroff',
    title: '2+1 на фирменные напитки',
    subtitle: 'Только по пятницам',
    imageUrl:
        'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=1200&q=80',
    validUntil: DateTime(2026, 12, 31),
  ),
];

/* =========================
   MAIN SHELL
========================= */

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final Set<String> _favorites = <String>{};
  final List<UserBooking> _bookings = [];

  Future<void> _toggleFavorite(String venueId) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) return;

  final isFavNow = _favorites.contains(venueId);

  try {
    if (!isFavNow) {
      await supabase.from('favorites').insert({
        'user_id': user.id,
        'venue_id': venueId,
      });
      setState(() => _favorites.add(venueId));
    } else {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('venue_id', venueId);
      setState(() => _favorites.remove(venueId));
    }
  } catch (e) {
    debugPrint('Favorites error: $e');
  }
}

 @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final rows = await supabase
          .from('favorites')
          .select('venue_id')
          .eq('user_id', user.id);

      final ids = rows.map((e) => e['venue_id'] as String).toSet();

      setState(() {
        _favorites
          ..clear()
          ..addAll(ids);
      });
    } catch (e) {
      debugPrint('Load favorites error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
  HomePage(
  favorites: _favorites,
  onToggleFavorite: _toggleFavorite,
  onAddBooking: (_) {},   // ← просто пустая функция
),

const MyBookingsPage(),

FavoritesPage(
  favorites: _favorites,
  onToggleFavorite: _toggleFavorite,
  onAddBooking: (_) {},   // ← тоже пустая
),

  ProfilePage(
    onLogout: () async {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
          (r) => false,
        );
      }
    },
  ),
];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: Container(
  decoration: const BoxDecoration(
    color: Colors.white,
    border: Border(
      top: BorderSide(
        color: Color(0xFFE8EDF2),
        width: 1,
      ),
    ),
  ),
  child: BottomNavigationBar(
    currentIndex: _index,
    onTap: (i) {
      setState(() {
        _index = i;
      });
    },
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    elevation: 0,
    selectedItemColor: const Color(0xFF1E6B45),
    unselectedItemColor: const Color(0xFF6B7280),
    selectedFontSize: 11,
    unselectedFontSize: 11,
    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w700,
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w600,
    ),
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Главная',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        activeIcon: Icon(Icons.calendar_month_rounded),
        label: 'Брони',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border_rounded),
        activeIcon: Icon(Icons.favorite_rounded),
        label: 'Избранные',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Профиль',
      ),
    ],
  ),
),
    );
  }
}

/* =========================
   HOME
========================= */

class HomePage extends StatefulWidget {
  final Set<String> favorites;
  final void Function(String venueId) onToggleFavorite;
  final void Function(UserBooking booking) onAddBooking;

  const HomePage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onAddBooking,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();

  final List<double?> _distanceOptions = const [null, 1, 3, 5, 10];
  double? _selectedMaxDistance;
  bool _openNowOnly = false;
  bool _favoritesOnly = false;
  SortBy _sortBy = SortBy.recommended;

  final _categories = const ['Все', 'Ресторан', 'Бар', 'Караоке'];
  String _selectedCategory = 'Все';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _distanceLabel(double? km) {
    if (km == null) return 'Любая';
    if (km == 1) return 'до 1 км';
    return 'до ${km.toStringAsFixed(0)} км';
  }

  String _distanceChipLabel(double? km) {
    if (km == null) return 'Любая';
    return '${km.toStringAsFixed(0)}км';
  }

  String _sortLabel(SortBy s) {
    switch (s) {
      case SortBy.recommended:
        return 'Рекоменд.';
      case SortBy.distance:
        return 'Ближе';
      case SortBy.rating:
        return 'Рейтинг';
      case SortBy.avgCheck:
        return 'Средний чек';
    }
  }

  List<Venue> get _filteredVenues {
    final q = _searchCtrl.text.trim().toLowerCase();

    final items = _venues.where((v) {
      final matchesSearch = q.isEmpty ||
          v.name.toLowerCase().contains(q) ||
          v.cuisine.toLowerCase().contains(q) ||
          v.address.toLowerCase().contains(q);

      final matchesCategory =
          _selectedCategory == 'Все' || v.category == _selectedCategory;

      final matchesDistance = _selectedMaxDistance == null
          ? true
          : v.distanceKm <= _selectedMaxDistance!;

      final matchesOpen =
    !_openNowOnly || isVenueOpenNow(v.openTime, v.closeTime);
      final matchesFav = !_favoritesOnly || widget.favorites.contains(v.id);

      return matchesSearch &&
          matchesCategory &&
          matchesDistance &&
          matchesOpen &&
          matchesFav;
    }).toList();

    items.sort((a, b) {
      switch (_sortBy) {
        case SortBy.distance:
          return a.distanceKm.compareTo(b.distanceKm);
        case SortBy.rating:
          return b.rating.compareTo(a.rating);
        case SortBy.avgCheck:
          return a.avgCheckKzt.compareTo(b.avgCheckKzt);
        case SortBy.recommended:
          final sa = (a.rating * 10) - a.distanceKm;
          final sb = (b.rating * 10) - b.distanceKm;
          return sb.compareTo(sa);
      }
    });

    return items;
  }

  Future<void> _pickSort() async {
    final res = await showModalBottomSheet<SortBy>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Сортировка')),
              RadioListTile(
                value: SortBy.recommended,
                groupValue: _sortBy,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: const Text('Рекомендуемые'),
              ),
              RadioListTile(
                value: SortBy.distance,
                groupValue: _sortBy,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: const Text('По расстоянию'),
              ),
              RadioListTile(
                value: SortBy.rating,
                groupValue: _sortBy,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: const Text('По рейтингу'),
              ),
              RadioListTile(
                value: SortBy.avgCheck,
                groupValue: _sortBy,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: const Text('По среднему чеку'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (res != null) setState(() => _sortBy = res);
  }

  void _openFiltersSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        double? tempDistance = _selectedMaxDistance;
        bool tempOpen = _openNowOnly;
        bool tempFav = _favoritesOnly;
        SortBy tempSort = _sortBy;

        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Фильтры',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    const Text('Расстояние'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _distanceOptions.map((km) {
                        return ChoiceChip(
  label: Text(_distanceLabel(km)),
  selected: tempDistance == km,
  selectedColor: const Color(0xFF1E6B45),
  labelStyle: TextStyle(
    color: tempDistance == km ? Colors.white : Colors.black,
    fontWeight: FontWeight.w700,
  ),
  onSelected: (_) => setLocal(() => tempDistance = km),
);
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Открыто сейчас'),
                      value: tempOpen,
                      onChanged: (v) => setLocal(() => tempOpen = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Только избранное'),
                      value: tempFav,
                      onChanged: (v) => setLocal(() => tempFav = v),
                    ),
                    const SizedBox(height: 6),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.sort_rounded),
                      title: const Text('Сортировка'),
                      subtitle: Text(_sortLabel(tempSort)),
                      onTap: () async {
                        final picked = await showModalBottomSheet<SortBy>(
                          context: ctx,
                          showDragHandle: true,
                          builder: (ctx2) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const ListTile(title: Text('Сортировка')),
                                RadioListTile(
                                  value: SortBy.recommended,
                                  groupValue: tempSort,
                                  onChanged: (v) =>
                                      Navigator.pop(ctx2, v),
                                  title: const Text('Рекомендуемые'),
                                ),
                                RadioListTile(
                                  value: SortBy.distance,
                                  groupValue: tempSort,
                                  onChanged: (v) =>
                                      Navigator.pop(ctx2, v),
                                  title: const Text('По расстоянию'),
                                ),
                                RadioListTile(
                                  value: SortBy.rating,
                                  groupValue: tempSort,
                                  onChanged: (v) =>
                                      Navigator.pop(ctx2, v),
                                  title: const Text('По рейтингу'),
                                ),
                                RadioListTile(
                                  value: SortBy.avgCheck,
                                  groupValue: tempSort,
                                  onChanged: (v) =>
                                      Navigator.pop(ctx2, v),
                                  title: const Text('По среднему чеку'),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                        if (picked != null) {
                          setLocal(() => tempSort = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setLocal(() {
                                tempDistance = null;
                                tempOpen = false;
                                tempFav = false;
                                tempSort = SortBy.recommended;
                              });
                            },
                            child: const Text('Сбросить'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _selectedMaxDistance = tempDistance;
                                _openNowOnly = tempOpen;
                                _favoritesOnly = tempFav;
                                _sortBy = tempSort;
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Применить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final venues = _filteredVenues;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.table_restaurant_rounded),
            SizedBox(width: 8),
            Text('Rezora', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Фильтры',
            icon: const Icon(Icons.tune_rounded),
            onPressed: _openFiltersSheet,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          _SearchBar(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            onClear: () {
              _searchCtrl.clear();
              setState(() {});
            },
          ),
          const SizedBox(height: 10),

          // Категории + distance + sort
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 2,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index < _categories.length) {
                  final cat = _categories[index];
                  final selected = _selectedCategory == cat;

                  return ChoiceChip(
  label: Text(cat),
  selected: selected,
  backgroundColor: Colors.white,
  selectedColor: const Color(0xFF1E6B45),
  checkmarkColor: Colors.white,
  side: const BorderSide(
    color: Color(0xFFE2E6EF),
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  labelStyle: TextStyle(
    color: selected ? Colors.white : Colors.black87,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  ),
  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  onSelected: (_) => setState(() => _selectedCategory = cat),
);
                }

                if (index == _categories.length) {
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place_outlined,
                            size: 15, color: cs.onSurface),
                        const SizedBox(width: 6),
                        Text(_distanceChipLabel(_selectedMaxDistance)),
                      ],
                    ),
                    selected: true,
                    onSelected: (_) => _openFiltersSheet(),
                    backgroundColor: Colors.white,
                    selectedColor: Colors.white,
                    side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }

                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_rounded,
                          size: 15, color: cs.onSurface),
                      const SizedBox(width: 6),
                      Text(_sortLabel(_sortBy)),
                    ],
                  ),
                  selected: false,
                  onSelected: (_) => _pickSort(),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

_PromoCarousel(promos: _promoBanners),

const SizedBox(height: 14),

if (venues.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: _EmptyState(),
            )
          else
            ...venues.map((v) {
              final isFav = widget.favorites.contains(v.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _VenueCard(
                  venue: v,
                  isFavorite: isFav,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VenueDetailsPage(
                          venue: v,
                          isFavorite: isFav,
                          onToggleFavorite: () => widget.onToggleFavorite(v.id),
                          onAddBooking: widget.onAddBooking,
                        ),
                      ),
                    );
                  },
                  onToggleFavorite: () => widget.onToggleFavorite(v.id),
                ),
              );
            }),
        ],
      ),
    );
  }
}

/* =========================
   VENUE DETAILS
========================= */

class VenueDetailsPage extends StatefulWidget {
  final Venue venue;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final void Function(UserBooking booking) onAddBooking;

  const VenueDetailsPage({
    super.key,
    required this.venue,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddBooking,
  });

  @override
  State<VenueDetailsPage> createState() => _VenueDetailsPageState();
}

class _VenueDetailsPageState extends State<VenueDetailsPage> {
  
  TableModel? _selected;
  VenueDetailsTab _activeTab = VenueDetailsTab.booking;

  DateTime? _selectedDate;
TimeOfDay? _selectedTime;

bool _loadingAvailability = false;

Set<String> _blockedTableIds = <String>{};

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

DateTime _combineDateTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

Future<void> _loadBlockedTables() async {
  if (_selectedDate == null || _selectedTime == null) return;

  setState(() => _loadingAvailability = true);

  try {
    final supabase = Supabase.instance.client;
    final selectedAt = _combineDateTime(_selectedDate!, _selectedTime!);

    final dayStart = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      0,
      0,
      0,
    );

    final dayEnd = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      23,
      59,
      59,
    );

    final rows = await supabase
        .from('bookings')
        .select()
        .eq('venue_id', widget.venue.id)
        .inFilter('status', ['pending', 'approved'])
        .gte('booking_date', dayStart.toIso8601String().substring(0, 10))
        .lte('booking_date', dayEnd.toIso8601String().substring(0, 10));

    final blocked = <String>{};

    for (final row in rows) {
      final bookingDate = row['booking_date'] as String;
      final bookingTime = row['booking_time'] as String;

      final partsDate = bookingDate.split('-');
      final partsTime = bookingTime.split(':');

      final bookedAt = DateTime(
        int.parse(partsDate[0]),
        int.parse(partsDate[1]),
        int.parse(partsDate[2]),
        int.parse(partsTime[0]),
        int.parse(partsTime[1]),
      );

      final blockedFrom = bookedAt.subtract(const Duration(hours: 4));
      final blockedTo = bookedAt.add(const Duration(hours: 5));

      final isInsideBlockedWindow =
          !selectedAt.isBefore(blockedFrom) && !selectedAt.isAfter(blockedTo);

      if (isInsideBlockedWindow) {
        blocked.add(row['table_id'] as String);
      }
    }

    final manualRows = await supabase
        .from('table_manual_openings')
        .select()
        .eq('venue_id', widget.venue.id);

    for (final row in manualRows) {
      final openFrom = DateTime.parse(row['open_from']);
      final openTo = DateTime.parse(row['open_to']);

      final isOpenNow =
          !selectedAt.isBefore(openFrom) && !selectedAt.isAfter(openTo);

      if (isOpenNow) {
        blocked.remove(row['table_id'] as String);
      }
    }

    setState(() {
      _blockedTableIds = blocked;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка проверки столов: $e')),
    );
  }

  if (mounted) {
    setState(() => _loadingAvailability = false);
  }
}

  @override
Widget build(BuildContext context) {
  final v = widget.venue;
  final isOpen = isVenueOpenNow(v.openTime, v.closeTime);

  return Scaffold(
      appBar: AppBar(
        title: Text(v.name),
        actions: [
          IconButton(
  tooltip: widget.isFavorite ? 'Убрать из избранного' : 'В избранное',
  onPressed: () async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final venueId = widget.venue.id;

    try {
      if (!widget.isFavorite) {
        await supabase.from('favorites').insert({
          'user_id': user.id,
          'venue_id': venueId,
        });
      } else {
        await supabase
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('venue_id', venueId);
      }

      widget.onToggleFavorite();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  },
  icon: Icon(
  widget.isFavorite
      ? Icons.favorite_rounded
      : Icons.favorite_border_rounded,
  color: widget.isFavorite
      ? const Color(0xFFCC2E2E)
      : const Color(0xFF374151),
),
),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          children: [
            _HeroImage(url: v.imageUrl),
            const SizedBox(height: 12),

            Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: const Color(0xFFE8EDF2),
    ),
    boxShadow: [
      BoxShadow(
        blurRadius: 20,
        offset: const Offset(0, 10),
        color: Colors.black.withOpacity(0.06),
      ),
    ],
  ),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        Expanded(
          child: Text(
            v.cuisine,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isOpen
                ? const Color(0xFFEAF7EE)
                : const Color(0xFFFDECEC),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isOpen
                  ? const Color(0xFFCFE9D8)
                  : const Color(0xFFF5CACA),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 15,
                color: isOpen
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
              const SizedBox(width: 6),
              Text(
                isOpen ? 'Открыто' : 'Закрыто',
                style: TextStyle(
                  color: isOpen
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ),

    const SizedBox(height: 12),

    Row(
  children: [
    Icon(
      Icons.star_rounded,
      size: 18,
      color: const Color(0xFFF59E0B),
    ),
    const SizedBox(width: 4),
    Text(
      v.rating.toStringAsFixed(1),
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),

    const SizedBox(width: 16),

    Icon(
      Icons.route_rounded,
      size: 18,
      color: const Color(0xFF2563EB),
    ),
    const SizedBox(width: 4),
    Text(
      '${v.distanceKm.toStringAsFixed(1)} км',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),

    const SizedBox(width: 16),

    Icon(
      Icons.payments_rounded,
      size: 18,
      color: const Color(0xFF16A34A),
    ),
    const SizedBox(width: 4),
    Text(
  '₸${v.avgCheckKzt.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ' ',
  )}',
  style: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: Color(0xFF111827),
  ),
),
  ],
),

    const SizedBox(height: 14),

    Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          '${v.openTime} – ${v.closeTime}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),

    const SizedBox(height: 10),

    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.place_outlined,
          size: 18,
          color: Color(0xFFEF4444),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            v.address,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  ],
),
),

            const SizedBox(height: 16),

_DetailsTabs(
  activeTab: _activeTab,
  onChanged: (tab) {
    setState(() {
      _activeTab = tab;
    });
  },
),

const SizedBox(height: 16),

if (_activeTab == VenueDetailsTab.booking) ...[
  _ActionTile(
    icon: Icons.calendar_month_rounded,
    title: 'Дата',
    value: _selectedDate == null
        ? 'Выберите дату'
        : _fmtDate(_selectedDate!),
    onTap: () async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: now.add(const Duration(days: 90)),
        initialDate: _selectedDate ?? now,
      );
      if (picked != null) {
        setState(() {
          _selectedDate = picked;
          _selected = null;
        });
        if (_selectedTime != null) {
          await _loadBlockedTables();
        }
      }
    },
  ),

  _ActionTile(
    icon: Icons.schedule_rounded,
    title: 'Время',
    value: _selectedTime == null
        ? 'Выберите время'
        : _fmtTime(_selectedTime!),
    onTap: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? const TimeOfDay(hour: 19, minute: 0),
      );
      if (picked != null) {
        setState(() {
          _selectedTime = picked;
          _selected = null;
        });
        if (_selectedDate != null) {
          await _loadBlockedTables();
        }
      }
    },
  ),

  const SizedBox(height: 12),

  if (_selectedDate == null || _selectedTime == null)
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Сначала выберите дату и время, чтобы увидеть доступные столы.',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    )
  else if (_loadingAvailability)
    const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    )
  else
    _TablesList(
      tables: v.tables,
      selectedTableId: _selected?.id,
      blockedTableIds: _blockedTableIds,
      onSelect: (t) => setState(() => _selected = t),
    ),

  const SizedBox(height: 12),

],

if (_activeTab == VenueDetailsTab.photos) ...[
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Фото заведения',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            v.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    ),
  ),
],

if (_activeTab == VenueDetailsTab.reviews) ...[
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: const Text(
      'Отзывы скоро появятся.',
      style: TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
],
FilledButton(
  onPressed: (_selected == null || _selectedDate == null || _selectedTime == null)
      ? null
      : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingPage(
                venue: widget.venue,
                selectedTable: _selected!,
                initialDate: _selectedDate!,
                initialTime: _selectedTime!,
                onBookingCreated: widget.onAddBooking,
              ),
            ),
          );
        },
  child: Text(
    _selected == null
        ? 'Выберите стол'
        : 'Продолжить: стол ${_selected!.id} (${_selected!.seats} мест)',
  ),
),
          ],
        ),
      ),
    );
  }
}

/* =========================
   BOOKING PAGE
========================= */

class BookingPage extends StatefulWidget {
  final Venue venue;
  final TableModel selectedTable;
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final void Function(UserBooking booking) onBookingCreated;

  const BookingPage({
    super.key,
    required this.venue,
    required this.selectedTable,
    required this.initialDate,
    required this.initialTime,
    required this.onBookingCreated,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _date;
  TimeOfDay? _time;
  int _guests = 2;

  @override
void initState() {
  super.initState();
  _date = widget.initialDate;
  _time = widget.initialTime;
  _guests = widget.selectedTable.seats >= 2 ? 2 : 1;
}

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  bool get _canSubmit => _date != null && _time != null && _guests >= 1;

DateTime _combineDateTime(DateTime date, TimeOfDay time) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

Future<bool> _isTableStillAvailable() async {
  final supabase = Supabase.instance.client;

  final selectedAt = _combineDateTime(_date!, _time!);

  final rows = await supabase
      .from('bookings')
      .select()
      .eq('venue_id', widget.venue.id)
      .eq('table_id', widget.selectedTable.id)
      .inFilter('status', ['pending', 'approved'])
      .eq('booking_date', _date!.toIso8601String().substring(0, 10));

  for (final row in rows) {
    final bookingDate = row['booking_date'] as String;
    final bookingTime = row['booking_time'] as String;

    final dateParts = bookingDate.split('-');
    final timeParts = bookingTime.split(':');

    final bookedAt = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final blockedFrom = bookedAt.subtract(const Duration(hours: 4));
    final blockedTo = bookedAt.add(const Duration(hours: 5));

    final isInsideBlockedWindow =
        !selectedAt.isBefore(blockedFrom) && !selectedAt.isAfter(blockedTo);

    if (isInsideBlockedWindow) {
      final manualRows = await supabase
          .from('table_manual_openings')
          .select()
          .eq('venue_id', widget.venue.id)
          .eq('table_id', widget.selectedTable.id);

      bool manuallyOpened = false;

      for (final manual in manualRows) {
        final openFrom = DateTime.parse(manual['open_from']);
        final openTo = DateTime.parse(manual['open_to']);

        final isInsideManualOpen =
            !selectedAt.isBefore(openFrom) && !selectedAt.isAfter(openTo);

        if (isInsideManualOpen) {
          manuallyOpened = true;
          break;
        }
      }

      if (!manuallyOpened) {
        return false;
      }
    }
  }

  return true;
}

  @override
  Widget build(BuildContext context) {
    final v = widget.venue;
    final table = widget.selectedTable;

    return Scaffold(
      appBar: AppBar(title: const Text('Оформление брони')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          children: [
            _InfoCard(
              title: v.name,
              subtitle: '${v.address}\nСтол: ${table.id} • ${table.seats} мест',
              icon: Icons.restaurant_rounded,
            ),
            const SizedBox(height: 12),
            _InfoCard(
  title: 'Дата и время',
  subtitle: '${_fmtDate(_date!)} • ${_fmtTime(_time!)}',
  icon: Icons.schedule_rounded,
),
            const SizedBox(height: 10),
            _GuestsPicker(
              guests: _guests,
              min: 1,
              max: table.seats,
              onChanged: (v) => setState(() => _guests = v),
            ),
            const SizedBox(height: 14),
            FilledButton(
  onPressed: _canSubmit
    ? () async {
        try {
          final supabase = Supabase.instance.client;
          final user = supabase.auth.currentUser;

          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Нужно войти в аккаунт')),
            );
            return;
          }

          final isAvailable = await _isTableStillAvailable();

          if (!isAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Этот стол только что заняли. Выберите другой.'),
              ),
            );
            Navigator.pop(context);
            return;
          }

          await supabase.from('bookings').insert({
            'user_id': user.id,
            'venue_id': v.id,
            'table_id': table.id,
            'booking_date': _date!.toIso8601String().substring(0, 10),
            'booking_time':
                '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}:00',
            'guests': _guests,
            'status': 'pending',
          });

          final booking = UserBooking(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            venue: v,
            table: table,
            date: _date!,
            time: _time!,
            guests: _guests,
          );

          widget.onBookingCreated(booking);

          Navigator.popUntil(context, (r) => r.isFirst);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Бронь успешно создана')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка брони: $e')),
          );
        }
      }
    : null,
  child: const Text('Подтвердить бронь'),
),
            const SizedBox(height: 8),
            Text(
              'Демо-логика: подтверждение показывает SnackBar и возвращает на главную.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   WIDGETS: HOME
========================= */

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
  child: Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Поиск по названию, кухне, адресу...',
        prefixIcon: const Icon(Icons.search_rounded, size: 22),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Очистить',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        border: InputBorder.none,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
  ),
);
  }
}

class _PromoCarousel extends StatelessWidget {
  final List<PromoBanner> promos;

  const _PromoCarousel({
    required this.promos,
  });

  Venue? _findVenue(String venueId) {
    for (final v in _venues) {
      if (v.id == venueId) return v;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (promos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: promos.length,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final promo = promos[index];
          final venue = _findVenue(promo.venueId);

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (venue == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VenueDetailsPage(
                    venue: venue,
                    isFavorite: false,
                    onToggleFavorite: () {},
                    onAddBooking: (_) {},
                  ),
                ),
              );
            },
            child: Container(
              width: 290,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      promo.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.10),
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (promo.isSponsored)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Акция',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          const Spacer(),
                          if (venue != null)
                            Text(
                              venue.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            promo.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            promo.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  final Venue venue;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _VenueCard({
    required this.venue,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
Widget build(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final hasFreeTables = venue.tables.any((t) => t.isAvailableNow);
  final isOpen = isVenueOpenNow(venue.openTime, venue.closeTime);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE8EDF2),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 145,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      venue.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: cs.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported_outlined,
                            size: 30),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: cs.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                    Positioned(
  top: 10,
  right: 10,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: isOpen
          ? const Color(0xFF1E6B45)
          : const Color(0xFFCC2E2E),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      isOpen ? 'Открыто' : 'Закрыто',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  ),
),
                  ],
                ),
              ),
            ),
            Padding(
  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              venue.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              venue.category,
              style: const TextStyle(
                color: Color(0xFF25624A),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE6EAEE),
              ),
            ),
            child: IconButton(
              tooltip: isFavorite
                  ? 'Убрать из избранного'
                  : 'В избранное',
              onPressed: onToggleFavorite,
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? const Color(0xFFCC2E2E)
                    : const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
  venue.cuisine,
  style: TextStyle(
    color: cs.onSurfaceVariant.withOpacity(0.95),
    fontSize: 14,
    fontWeight: FontWeight.w600,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),

const SizedBox(height: 6),

Row(
  children: [
    _InlineInfo(
      icon: Icons.star_rounded,
      iconColor: const Color(0xFFF59E0B),
      text: venue.rating.toStringAsFixed(1),
    ),
    const SizedBox(width: 12),
    _InlineInfo(
      icon: Icons.route_rounded,
      iconColor: const Color(0xFF2563EB),
      text: '${venue.distanceKm.toStringAsFixed(1)} км',
    ),
    const SizedBox(width: 12),
    _InlineInfo(
      icon: Icons.payments_rounded,
      iconColor: const Color(0xFF16A34A),
      text: '₸${venue.avgCheckKzt.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ' ',
      )}',
    ),
  ],
),
      const SizedBox(height: 8),
      Row(
  children: [
    Icon(
      Icons.schedule_rounded,
      size: 16,
      color: cs.onSurfaceVariant,
    ),
    const SizedBox(width: 5),
    Text(
      '${venue.openTime} – ${venue.closeTime}',
      style: TextStyle(
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    ),
    const SizedBox(width: 10),
    Icon(
      Icons.place_outlined,
      size: 16,
      color: const Color(0xFFEF4444),
    ),
    const SizedBox(width: 5),
    Expanded(
      child: Text(
        venue.address,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
),
    ],
  ),
),
          ],
        ),
      ),
    ),
  );
}
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const _Pill({
    required this.icon,
    required this.text,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(
      color: const Color(0xFFE5E7EB),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 16,
        color: iconColor ?? cs.onSurfaceVariant,
      ),
      const SizedBox(width: 6),
      Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Color(0xFF111827),
        ),
      ),
    ],
  ),
);
  }
}

class _DetailStatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _DetailStatChip({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsTabs extends StatelessWidget {
  final VenueDetailsTab activeTab;
  final ValueChanged<VenueDetailsTab> onChanged;

  const _DetailsTabs({
    required this.activeTab,
    required this.onChanged,
  });

  Widget _buildTab({
    required VenueDetailsTab tab,
    required String label,
  }) {
    final selected = activeTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF7EE) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF1E6B45)
                  : const Color(0xFF111827),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab(
            tab: VenueDetailsTab.booking,
            label: 'Бронь',
          ),
          const SizedBox(width: 6),
          _buildTab(
            tab: VenueDetailsTab.photos,
            label: 'Фото',
          ),
          const SizedBox(width: 6),
          _buildTab(
            tab: VenueDetailsTab.reviews,
            label: 'Отзывы',
          ),
        ],
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InlineInfo({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: iconColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 52,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 10),
            const Text('Ничего не найдено',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              'Попробуй изменить запрос или фильтры.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   WIDGETS: DETAILS
========================= */

class _HeroImage extends StatelessWidget {
  final String url;
  const _HeroImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: cs.surfaceContainerHighest,
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported_outlined, size: 40),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: cs.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// маленький хелпер, чтобы не импортить dart:math везде

class _TablesList extends StatelessWidget {
  final List<TableModel> tables;
  final String? selectedTableId;
  final Set<String> blockedTableIds;
  final ValueChanged<TableModel> onSelect;

  const _TablesList({
    required this.tables,
    required this.selectedTableId,
    required this.blockedTableIds,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: tables.map((t) {
        final selected = selectedTableId == t.id;
        final isBlocked = blockedTableIds.contains(t.id);
        final canSelect = !isBlocked;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: canSelect ? () => onSelect(t) : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? cs.primary
                        : cs.outlineVariant.withOpacity(0.5),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: canSelect
                            ? cs.surfaceContainerHighest.withOpacity(0.35)
                            : cs.errorContainer.withOpacity(0.30),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        t.id,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Стол ${t.id}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${t.seats} мест',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.locationLabel,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      canSelect ? 'Свободен' : 'Занят',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: canSelect ? cs.primary : cs.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/* =========================
   WIDGETS: BOOKING
========================= */

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: cs.surfaceContainerHighest.withOpacity(0.35),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.5), width: 1),
            ),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(value, style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestsPicker extends StatelessWidget {
  final int guests;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _GuestsPicker({
    required this.guests,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Количество гостей',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: guests > min ? () => onChanged(guests - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          Text(
            '$guests',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          IconButton(
            onPressed: guests < max ? () => onChanged(guests + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const SizedBox(width: 6),
          Text('макс $max', style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/* =========================
   AUTH + PARTNER
========================= */

enum AppRole { user, partner }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AppRole _role = AppRole.user;

  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_role == AppRole.user) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PartnerHomePage()),
      );
    }
  }

  Future<void> _signIn() async {
  final ok = _formKey.currentState?.validate() ?? false;
  if (!ok) return;

  setState(() => _loading = true);

  try {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: _loginCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );

    if (response.user != null) {
      _goNext();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка входа: $e')),
    );
  }

  if (mounted) {
    setState(() => _loading = false);
  }
}

  Future<void> _openRegisterStub() async {
  final ok = _formKey.currentState?.validate() ?? false;
  if (!ok) return;

  setState(() => _loading = true);

  try {
    final email = _loginCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    final res = await Supabase.instance.client.auth.signUp(
      email: email,
      password: pass,
    );

    final user = res.user;

    if (user != null) {
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'role': _role == AppRole.partner ? 'partner' : 'user',
      });

      _goNext();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка регистрации: $e')),
    );
  }

  if (mounted) {
    setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  return Scaffold(
  resizeToAvoidBottomInset: true,
  body: SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset), // <-- ключ
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),

                      // ✅ дальше ВСТАВЛЯЕШЬ ТВОЙ КОНТЕНТ 1-в-1, без изменений:
                      // LOGO
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E6B45),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'RZ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Добро пожаловать',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Войдите в свой аккаунт',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: cs.onSurfaceVariant.withOpacity(0.75),
                              fontWeight: FontWeight.w700,
                            ),
                      ),

                      const SizedBox(height: 12),

                      // Карточка
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                              color: Colors.black.withOpacity(0.06),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _RoleSegmented(
                              selected: _role,
                              onChanged: (v) => setState(() => _role = v),
                            ),

                            const SizedBox(height: 10),

                            Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _AuthField(
                                    controller: _loginCtrl,
                                    hint: 'Email',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      final t = (v ?? '').trim();
                                      if (t.isEmpty) return 'Введите Email';
                                      if (!t.contains('@')) return 'Неверный формат Email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  _AuthField(
                                    controller: _passCtrl,
                                    hint: 'Пароль',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscure,
                                    suffix: IconButton(
                                      tooltip: _obscure ? 'Показать' : 'Скрыть',
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    validator: (v) {
                                      final t = (v ?? '').trim();
                                      if (t.isEmpty) return 'Введите пароль';
                                      if (t.length < 4) return 'Минимум 4 символа';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 6),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Сделаем восстановление пароля позже'),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Забыли пароль?',
                                        style: TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  SizedBox(
                                    height: 48,
                                    width: double.infinity,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E6B45),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                      onPressed: _loading ? null : _signIn,
                                      child: const Text(
                                        'Войти',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  SizedBox(
                                    height: 48,
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(color: Color(0xFFE2E6EF)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                                        );
                                      },
                                      child: const Text(
                                        'Регистрация',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  _OrDivider(text: 'или'),

                                  const SizedBox(height: 10),

                                  SizedBox(
                                    height: 46,
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(color: Color(0xFFE2E6EF)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                      onPressed: () {},
                                      icon: const Icon(Icons.g_mobiledata_rounded),
                                      label: const Text(
                                        'Войти через Google',
                                        style: TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ),
);
}
}

class _RoleSegment extends StatelessWidget {
  final AppRole value;
  final AppRole selected;
  final ValueChanged<AppRole> onChanged;

  const _RoleSegment({
    required this.value,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLeft = value == AppRole.user;
    final isSelected = selected == value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(value),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE7ECFA) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Icon(Icons.check_rounded, size: 18, color: cs.onSurface),
                const SizedBox(width: 6),
              ],
              Text(
                isLeft ? 'Клиент' : 'Партнёр',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSegmented extends StatelessWidget {
  final AppRole selected;
  final ValueChanged<AppRole> onChanged;

  const _RoleSegmented({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E6EF)),
      ),
      child: Row(
        children: [
          _RoleSegment(value: AppRole.user, selected: selected, onChanged: onChanged),
          const SizedBox(width: 6),
          _RoleSegment(value: AppRole.partner, selected: selected, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _PrettyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;

  const _PrettyField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.92),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.65)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

/* =========================
   PARTNER (DEMO)
========================= */

class PartnerHomePage extends StatefulWidget {
  const PartnerHomePage({super.key});

  @override
  State<PartnerHomePage> createState() => _PartnerHomePageState();
}

class _PartnerHomePageState extends State<PartnerHomePage> {
  int _tab = 0;

  late Venue _venue;
  late List<_PartnerTable> _partnerTables;
  late List<_PartnerBooking> _bookings;

  @override
  void initState() {
    super.initState();
    _venue = _venues.first;

    _partnerTables = _venue.tables
        .map((t) => _PartnerTable(
              id: t.id,
              seats: t.seats,
              isAvailableNow: t.isAvailableNow,
              isStopped: false,
            ))
        .toList();

    _bookings = [
      _PartnerBooking(
        id: 'B-10241',
        venueId: _venue.id,
        tableId: _partnerTables[1].id,
        guests: 4,
        date: DateTime.now(),
        time: const TimeOfDay(hour: 19, minute: 0),
        status: _BookingStatus.pending,
        customerName: 'Гость',
        phoneMasked: '+7 *** *** ** 12',
      ),
      _PartnerBooking(
        id: 'B-10242',
        venueId: _venue.id,
        tableId: _partnerTables[0].id,
        guests: 2,
        date: DateTime.now().add(const Duration(days: 1)),
        time: const TimeOfDay(hour: 20, minute: 30),
        status: _BookingStatus.pending,
        customerName: 'Алия',
        phoneMasked: '+7 *** *** ** 88',
      ),
      _PartnerBooking(
        id: 'B-10230',
        venueId: _venue.id,
        tableId: _partnerTables[2].id,
        guests: 6,
        date: DateTime.now(),
        time: const TimeOfDay(hour: 17, minute: 0),
        status: _BookingStatus.approved,
        customerName: 'Данияр',
        phoneMasked: '+7 *** *** ** 77',
      ),
    ];
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (r) => false,
    );
  }

  void _approve(_PartnerBooking b) {
    setState(() => b.status = _BookingStatus.approved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Бронь ${b.id} подтверждена')),
    );
  }

  void _decline(_PartnerBooking b) {
    setState(() => b.status = _BookingStatus.declined);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Бронь ${b.id} отклонена')),
    );
  }

  void _toggleStop(_PartnerTable t) {
    setState(() => t.isStopped = !t.isStopped);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t.isStopped ? 'Стол ${t.id} поставлен в стоп' : 'Стол ${t.id} снят со стопа',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _PartnerBookingsPage(
        venue: _venue,
        bookings: _bookings,
        fmtDate: _fmtDate,
        fmtTime: _fmtTime,
        onApprove: _approve,
        onDecline: _decline,
      ),
      _PartnerTablesPage(
        venue: _venue,
        tables: _partnerTables,
        onToggleStop: _toggleStop,
      ),
      _PartnerProfilePage(
        venue: _venue,
        onLogout: _logout,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'Брони' : _tab == 1 ? 'Столы' : 'Профиль'),
        actions: [
          if (_tab != 2)
            IconButton(
  tooltip: 'Выйти',
  icon: const Icon(
    Icons.logout_rounded,
    color: Colors.red,
  ),
  onPressed: _logout,
),
        ],
      ),
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event_note_rounded), label: 'Брони'),
          NavigationDestination(icon: Icon(Icons.table_restaurant_rounded), label: 'Столы'),
          NavigationDestination(icon: Icon(Icons.storefront_rounded), label: 'Профиль'),
        ],
      ),
    );
  }
}

class _PartnerBookingsPage extends StatelessWidget {
  final Venue venue;
  final List<_PartnerBooking> bookings;
  final String Function(DateTime) fmtDate;
  final String Function(TimeOfDay) fmtTime;
  final ValueChanged<_PartnerBooking> onApprove;
  final ValueChanged<_PartnerBooking> onDecline;

  const _PartnerBookingsPage({
    required this.venue,
    required this.bookings,
    required this.fmtDate,
    required this.fmtTime,
    required this.onApprove,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pending = bookings.where((b) => b.status == _BookingStatus.pending).toList();
    final others = bookings.where((b) => b.status != _BookingStatus.pending).toList();
    final approved = bookings.where((b) => b.status == _BookingStatus.approved).length;
    final declined = bookings.where((b) => b.status == _BookingStatus.declined).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      children: [
        _PartnerHeaderCard(
          title: venue.name,
          subtitle: '${venue.address}\nСегодня в обработке: ${pending.length}',
          icon: Icons.store_rounded,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricPill(
                label: 'Новые',
                value: '${pending.length}',
                icon: Icons.notifications_active_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricPill(
                label: 'Подтв.',
                value: '$approved',
                icon: Icons.verified_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricPill(
                label: 'Откл.',
                value: '$declined',
                icon: Icons.block_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (pending.isNotEmpty) ...[
          const Text('Новые заявки',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...pending.map((b) => _BookingCard(
                b: b,
                fmtDate: fmtDate,
                fmtTime: fmtTime,
                onApprove: () => onApprove(b),
                onDecline: () => onDecline(b),
                highlight: true,
              )),
          const SizedBox(height: 14),
        ],

        Text('История',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            )),
        const SizedBox(height: 10),

        if (others.isEmpty)
          Text('Пока пусто', style: TextStyle(color: cs.onSurfaceVariant))
        else
          ...others.map((b) => _BookingCard(
                b: b,
                fmtDate: fmtDate,
                fmtTime: fmtTime,
                onApprove: null,
                onDecline: null,
                highlight: false,
              )),
      ],
    );
  }
}

class _PartnerTablesPage extends StatelessWidget {
  final Venue venue;
  final List<_PartnerTable> tables;
  final ValueChanged<_PartnerTable> onToggleStop;

  const _PartnerTablesPage({
    required this.venue,
    required this.tables,
    required this.onToggleStop,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      children: [
        _PartnerHeaderCard(
          title: venue.name,
          subtitle: 'Управление стоп-листом столов',
          icon: Icons.table_restaurant_rounded,
        ),
        const SizedBox(height: 12),
        ...tables.map((t) {
          final statusText = t.isStopped
              ? 'СТОП'
              : (t.isAvailableNow ? 'Свободен сейчас' : 'Занят сейчас');

          final statusColor = t.isStopped
              ? cs.error
              : (t.isAvailableNow ? cs.primary : cs.onSurfaceVariant);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: cs.surfaceContainerHighest.withOpacity(0.35),
                    ),
                    child: Text(t.id, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Стол ${t.id} • ${t.seats} мест',
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (t.isStopped)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _StatusChip(
                        text: 'STOP',
                        icon: Icons.do_not_disturb_on_rounded,
                        bg: cs.errorContainer.withOpacity(0.40),
                        fg: cs.error,
                      ),
                    ),
                  Switch(
                    value: t.isStopped,
                    onChanged: (_) => onToggleStop(t),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PartnerProfilePage extends StatelessWidget {
  final Venue venue;
  final VoidCallback onLogout;

  const _PartnerProfilePage({
    required this.venue,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget kv(String k, String v) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(child: Text(k, style: const TextStyle(fontWeight: FontWeight.w700))),
            const SizedBox(width: 10),
            Flexible(child: Text(v, textAlign: TextAlign.right)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      children: [
        _PartnerHeaderCard(
          title: venue.name,
          subtitle: venue.address,
          icon: Icons.storefront_rounded,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Данные партнёра',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              kv('ID заведения', venue.id),
              kv('Кухня', venue.cuisine),
              kv('Рейтинг', '${venue.rating.toStringAsFixed(1)} (${venue.reviews})'),
              kv('Средний чек', '₸${venue.avgCheckKzt}'),
              kv(
  'Открыто сейчас',
  isVenueOpenNow(venue.openTime, venue.closeTime) ? 'Да' : 'Нет',
),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Выйти'),
          ),
        ),
      ],
    );
  }
}

class _PartnerHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PartnerHeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.95),
            cs.primaryContainer.withOpacity(0.95),
            const Color(0xFF7C3AED).withOpacity(0.25),
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 14),
            color: cs.primary.withOpacity(0.18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.16),
              border: Border.all(color: Colors.white.withOpacity(0.28)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    )),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final _PartnerBooking b;
  final String Function(DateTime) fmtDate;
  final String Function(TimeOfDay) fmtTime;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;
  final bool highlight;

  const _BookingCard({
    required this.b,
    required this.fmtDate,
    required this.fmtTime,
    required this.onApprove,
    required this.onDecline,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    late _StatusChip chip;
    switch (b.status) {
      case _BookingStatus.pending:
        chip = _StatusChip(
          text: 'Ожидает',
          icon: Icons.hourglass_top_rounded,
          bg: cs.primaryContainer,
          fg: cs.onPrimaryContainer,
        );
        break;
      case _BookingStatus.approved:
        chip = _StatusChip(
          text: 'Подтвержд.',
          icon: Icons.verified_rounded,
          bg: cs.surfaceContainerHighest.withOpacity(0.55),
          fg: cs.primary,
        );
        break;
      case _BookingStatus.declined:
        chip = _StatusChip(
          text: 'Отклонена',
          icon: Icons.block_rounded,
          bg: cs.errorContainer.withOpacity(0.40),
          fg: cs.error,
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: highlight
                ? cs.primary.withOpacity(0.35)
                : cs.outlineVariant.withOpacity(0.45),
            width: highlight ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 12),
              color: (highlight ? cs.primary : Colors.black)
                  .withOpacity(highlight ? 0.10 : 0.06),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Стол ${b.tableId} • ${b.guests} гостей',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
                chip,
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${fmtDate(b.date)} • ${fmtTime(b.time)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(b.id, style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${b.customerName} • ${b.phoneMasked}',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            if (b.status == _BookingStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDecline,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Отклонить'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Подтвердить'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _BookingStatus { pending, approved, declined }

class _PartnerBooking {
  final String id;
  final String venueId;
  final String tableId;
  final int guests;
  final DateTime date;
  final TimeOfDay time;
  _BookingStatus status;
  final String customerName;
  final String phoneMasked;

  _PartnerBooking({
    required this.id,
    required this.venueId,
    required this.tableId,
    required this.guests,
    required this.date,
    required this.time,
    required this.status,
    required this.customerName,
    required this.phoneMasked,
  });
}

class _PartnerTable {
  final String id;
  final int seats;
  final bool isAvailableNow;
  bool isStopped;

  _PartnerTable({
    required this.id,
    required this.seats,
    required this.isAvailableNow,
    required this.isStopped,
  });
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData icon;

  const _StatusChip({
    required this.text,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   FIX: MOVE FRAC EXTENSION
========================= */

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 58,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withOpacity(0.55),
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E6EF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: cs.primary.withOpacity(0.45), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  final String text;
  const _OrDivider({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant.withOpacity(0.5), thickness: 1)),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w800)),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: cs.outlineVariant.withOpacity(0.5), thickness: 1)),
      ],
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final Set<String> favorites;
  final void Function(String venueId) onToggleFavorite;

final void Function(UserBooking booking) onAddBooking;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onAddBooking,
  });

  @override
  Widget build(BuildContext context) {
    final favVenues = _venues.where((v) => favorites.contains(v.id)).toList();

    if (favVenues.isEmpty) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('Пока нет избранных заведений')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Избранные')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: favVenues.map((v) {
          final isFav = favorites.contains(v.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _VenueCard(
              venue: v,
              isFavorite: isFav,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VenueDetailsPage(
                      venue: v,
                      isFavorite: isFav,
                      onToggleFavorite: () => onToggleFavorite(v.id),
                      onAddBooking: onAddBooking,
                    ),
                  ),
                );
              },
              onToggleFavorite: () => onToggleFavorite(v.id),
            ),
          );
        }).toList(),
      ),
    );
  }
}
class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  String _fmtDate(String rawDate) {
    try {
      final d = DateTime.parse(rawDate);
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    } catch (_) {
      return rawDate;
    }
  }

  String _fmtTime(String rawTime) {
    try {
      final parts = rawTime.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return rawTime;
    } catch (_) {
      return rawTime;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'approved':
        return 'Подтверждена';
      case 'declined':
        return 'Отклонена';
      case 'cancelled':
        return 'Отменена';
      default:
        return status;
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;

    switch (status) {
      case 'pending':
        return cs.primary;
      case 'approved':
        return const Color(0xFF16A34A);
      case 'declined':
        return cs.error;
      case 'cancelled':
        return cs.onSurfaceVariant;
      default:
        return cs.onSurfaceVariant;
    }
  }

  Venue? _findVenueById(String venueId) {
    for (final v in _venues) {
      if (v.id == venueId) return v;
    }
    return null;
  }

  DateTime? _bookingDateTime(Map<String, dynamic> b) {
  try {
    final rawDate = (b['booking_date'] ?? '').toString();
    final rawTime = (b['booking_time'] ?? '').toString();

    final dateParts = rawDate.split('-');
    final timeParts = rawTime.split(':');

    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  } catch (_) {
    return null;
  }
}

bool _isActiveBooking(Map<String, dynamic> b) {
  final dt = _bookingDateTime(b);
  if (dt == null) return false;
  return !dt.isBefore(DateTime.now());
}

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final cs = Theme.of(context).colorScheme;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Нужно войти в аккаунт')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Мои брони')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('bookings')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          }

          final allBookings = snapshot.data ?? [];
final bookings = allBookings.where((b) => _isActiveBooking(b)).toList();

if (bookings.isEmpty) {
  return const Center(
    child: Text('У вас нет активных бронирований'),
  );
}

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];

              final venueId = (b['venue_id'] ?? '').toString();
              final tableId = (b['table_id'] ?? '').toString();
              final bookingDate = (b['booking_date'] ?? '').toString();
              final bookingTime = (b['booking_time'] ?? '').toString();
              final guests = (b['guests'] ?? '').toString();
              final status = (b['status'] ?? 'pending').toString();

              final venue = _findVenueById(venueId);
              final venueName = venue?.name ?? venueId;
              final venueAddress = venue?.address ?? 'Адрес недоступен';

              final statusColor = _statusColor(context, status);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              venueName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: statusColor.withOpacity(0.22),
                              ),
                            ),
                            child: Text(
                              _statusLabel(status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              venueAddress,
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.table_restaurant_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Стол $tableId',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            Icons.people_alt_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$guests гост.',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_fmtDate(bookingDate)} • ${_fmtTime(bookingTime)}',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  String _fmtDate(String rawDate) {
    try {
      final d = DateTime.parse(rawDate);
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    } catch (_) {
      return rawDate;
    }
  }

  String _fmtTime(String rawTime) {
    try {
      final parts = rawTime.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return rawTime;
    } catch (_) {
      return rawTime;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'approved':
        return 'Подтверждена';
      case 'declined':
        return 'Отклонена';
      case 'cancelled':
        return 'Отменена';
      default:
        return status;
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;

    switch (status) {
      case 'pending':
        return cs.primary;
      case 'approved':
        return const Color(0xFF16A34A);
      case 'declined':
        return cs.error;
      case 'cancelled':
        return cs.onSurfaceVariant;
      default:
        return cs.onSurfaceVariant;
    }
  }

  Venue? _findVenueById(String venueId) {
    for (final v in _venues) {
      if (v.id == venueId) return v;
    }
    return null;
  }

  DateTime? _bookingDateTime(Map<String, dynamic> b) {
    try {
      final rawDate = (b['booking_date'] ?? '').toString();
      final rawTime = (b['booking_time'] ?? '').toString();

      final dateParts = rawDate.split('-');
      final timeParts = rawTime.split(':');

      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (_) {
      return null;
    }
  }

  bool _isPastBooking(Map<String, dynamic> b) {
    final dt = _bookingDateTime(b);
    if (dt == null) return false;
    return dt.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final cs = Theme.of(context).colorScheme;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Нужно войти в аккаунт')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('История бронирований')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('bookings')
            .select()
            .eq('user_id', user.id)
            .order('booking_date', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          }

          final allBookings = snapshot.data ?? [];
          final historyBookings =
              allBookings.where((b) => _isPastBooking(b)).toList();

          if (historyBookings.isEmpty) {
            return const Center(
              child: Text('История бронирований пока пуста'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            itemCount: historyBookings.length,
            itemBuilder: (context, index) {
              final b = historyBookings[index];

              final venueId = (b['venue_id'] ?? '').toString();
              final tableId = (b['table_id'] ?? '').toString();
              final bookingDate = (b['booking_date'] ?? '').toString();
              final bookingTime = (b['booking_time'] ?? '').toString();
              final guests = (b['guests'] ?? '').toString();
              final status = (b['status'] ?? 'pending').toString();

              final venue = _findVenueById(venueId);
              final venueName = venue?.name ?? venueId;
              final venueAddress = venue?.address ?? 'Адрес недоступен';

              final statusColor = _statusColor(context, status);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              venueName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: statusColor.withOpacity(0.22),
                              ),
                            ),
                            child: Text(
                              _statusLabel(status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              venueAddress,
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.table_restaurant_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Стол $tableId',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            Icons.people_alt_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$guests гост.',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_fmtDate(bookingDate)} • ${_fmtTime(bookingTime)}',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final Future<void> Function() onLogout;

  const ProfilePage({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = Supabase.instance.client.auth.currentUser;

    final email = user?.email ?? '—';
    final uid = user?.id ?? '—';

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.45)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.person_rounded, color: cs.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Мой аккаунт',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: $uid',
                          style: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.9), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _ProfileTile(
  icon: Icons.receipt_long_rounded,
  title: 'Мои брони',
  subtitle: 'История бронирований',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookingHistoryPage(),
      ),
    );
  },
),

            _ProfileTile(
              icon: Icons.favorite_rounded,
              title: 'Избранные',
              subtitle: 'Сохранённые заведения',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Открой вкладку “Избранные” снизу 🙂')),
                );
              },
            ),

            _ProfileTile(
              icon: Icons.support_agent_rounded,
              title: 'Поддержка',
              subtitle: 'Написать в поддержку',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Поддержку подключим позже')),
                );
              },
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
  style: FilledButton.styleFrom(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
  onPressed: () async {
    await onLogout();
  },
  icon: const Icon(Icons.logout_rounded),
  label: const Text('Выйти'),
),
            ),

            const SizedBox(height: 10),

            Text(
              'Демо: профиль берёт email из Supabase auth.currentUser.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.45)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}