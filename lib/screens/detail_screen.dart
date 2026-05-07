import 'package:flutter/material.dart';
import '../api_service/meal_api_service.dart';
import '../models/recipe.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DetailScreen extends StatefulWidget {
  final String mealId;

  const DetailScreen({super.key, required this.mealId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _apiService = MealApiService();

  Map<String, dynamic>? _meal;
  bool _isLoading = true;
  String? _errorMessage;

  late Box<Recipe> _favBox;

  @override
  void initState() {
    super.initState();
    _favBox = Hive.box<Recipe>('favorites');
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final detail = await _apiService.fetchMealDetail(widget.mealId);
      if (!mounted) return;
      setState(() {
        _meal = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat detail resep.';
        _isLoading = false;
      });
    }
  }

  bool get _isFavorite => _favBox.containsKey(widget.mealId);

  void _toggleFavorite() {
    if (_meal == null) return;
    if (_isFavorite) {
      _favBox.delete(widget.mealId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dihapus dari favorit'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey[800],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      final recipe = Recipe(
        id: widget.mealId,
        title: _meal!['strMeal'] ?? '',
        imageUrl: _meal!['strMealThumb'] ?? '',
        category: _meal!['strCategory'],
        area: _meal!['strArea'],
      );
      _favBox.put(widget.mealId, recipe);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ditambahkan ke favorit ❤️'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE94560),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    setState(() {});
  }

  List<String> _getIngredients(Map<String, dynamic> meal) {
    final List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty) {
        final measureStr =
            (measure != null && measure.toString().trim().isNotEmpty)
                ? measure.toString().trim()
                : '';
        ingredients.add('$measureStr ${ingredient.toString().trim()}'.trim());
      }
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE94560)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.white38, size: 64),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE94560),
                        ),
                        child: const Text('Coba Lagi',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final meal = _meal!;
    final ingredients = _getIngredients(meal);
    final instructions = (meal['strInstructions'] ?? '').toString();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: const Color(0xFF16213E),
          foregroundColor: Colors.white,
          actions: [
            ValueListenableBuilder(
              valueListenable: _favBox.listenable(),
              builder: (ctx, box, _) {
                final isFav = _favBox.containsKey(widget.mealId);
                return IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFav),
                      color: isFav ? const Color(0xFFE94560) : Colors.white,
                      size: 28,
                    ),
                  ),
                  onPressed: _toggleFavorite,
                  tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  meal['strMealThumb'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF16213E),
                    child: const Icon(Icons.broken_image,
                        color: Colors.white24, size: 60),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF1A1A2E).withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['strMeal'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (meal['strCategory'] != null)
                      _InfoChip(
                          icon: Icons.category_outlined,
                          label: meal['strCategory']),
                    if (meal['strArea'] != null)
                      _InfoChip(
                          icon: Icons.public_outlined,
                          label: meal['strArea']),
                  ],
                ),
                const SizedBox(height: 28),

                _SectionTitle(title: 'Bahan-bahan', icon: Icons.list_alt),
                const SizedBox(height: 12),
                ...ingredients.map(
                  (ing) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle,
                            color: Color(0xFFE94560), size: 8),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ing,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                _SectionTitle(
                    title: 'Cara Memasak', icon: Icons.menu_book_outlined),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Text(
                    instructions,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.7),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE94560).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFFE94560).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFE94560), size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFFE94560),
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE94560), size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
