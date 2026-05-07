import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favBox = Hive.box<Recipe>('favorites');

    return Scaffold(
      backgroundColor: const Color(0xFFFDE8E9), // Light pinkish background
      appBar: AppBar(
        backgroundColor: Colors.pink,
        elevation: 0,
        title: const Text(
          'Resep Favorit ❤️',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder<Box<Recipe>>(
        valueListenable: favBox.listenable(),
        builder: (ctx, box, _) {
          final recipes = box.values.toList().cast<Recipe>();

          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      color: Colors.pink.withValues(alpha: 0.3), size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum ada resep favorit',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tambahkan resep favorit Anda\ndari halaman detail',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: recipes.length,
            itemBuilder: (ctx, i) {
              final recipe = recipes[i];
              return _FavoriteItem(
                recipe: recipe,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(mealId: recipe.id),
                  ),
                ),
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Hapus Favorit',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold)),
                      content: Text(
                        'Hapus "${recipe.title}" dari favorit?',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, false),
                          child: const Text('Batal',
                              style: TextStyle(color: Colors.black54)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Hapus',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    favBox.delete(recipe.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FavoriteItem({
    required this.recipe,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18)),
                child: Image.network(
                  recipe.imageUrl,
                  width: 100,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 100,
                    height: 90,
                    color: Colors.pink.withValues(alpha: 0.05),
                    child: const Icon(Icons.broken_image,
                        color: Colors.black26, size: 32),
                  ),
                ),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (recipe.category != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.category_outlined,
                                color: Colors.black38, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              recipe.category!,
                              style: const TextStyle(
                                  color: Colors.black38, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                      if (recipe.area != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.public_outlined,
                                color: Colors.black38, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              recipe.area!,
                              style: const TextStyle(
                                  color: Colors.black38, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Delete button
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.pink, size: 26),
                  onPressed: onDelete,
                  tooltip: 'Hapus dari Favorit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
