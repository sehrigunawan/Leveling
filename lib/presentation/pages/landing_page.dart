import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/auth_widgets.dart'; // Menggunakan GradientButton

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi Lebar Layar untuk Responsivitas
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgBlue, AppColors.bgPurple, AppColors.bgPink],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- HEADER ---
              _buildHeader(context, isDesktop),

              // --- HERO SECTION ---
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 24, 
                  vertical: 24
                ),
                child: isDesktop 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _buildLeftContent(context, isDesktop)),
                        const SizedBox(width: 48),
                        Expanded(child: _buildRightContent()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildLeftContent(context, isDesktop),
                        const SizedBox(height: 48),
                        _buildRightContent(),
                      ],
                    ),
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo "Leveling" Gradient Text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.brandPurple, AppColors.brandPink, Colors.orange],
            ).createShader(bounds),
            child: Text(
              "Leveling",
              style: TextStyle(
                fontSize: isDesktop ? 30 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
              ),
            ),
          ),

          // Tombol Login/Register
          Row(
            children: [
              TextButton(
                onPressed: () => context.push('/login'),
                child: const Text("Login", style: TextStyle(color: AppColors.textPrimary)),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                height: 40,
                child: GradientButton(
                  text: "Register",
                  onPressed: () => context.push('/register'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLeftContent(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 60 : 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
              fontFamily: 'Inter', // Pastikan font diset di pubspec.yaml
            ),
            children: [
              const TextSpan(text: "Upgrade Skill-mu, \n"),
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.brandPurple, AppColors.brandPink, Colors.orange],
                  ).createShader(bounds),
                  child: Text(
                    "Hari demi Hari",
                    style: TextStyle(
                      fontSize: isDesktop ? 60 : 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Deskripsi
        Text(
          "Belajar skill favorit-mu dengan teman virtual yang berkembang bersama progresmu. Mulai dari kucing buluk yang lucu hingga menjadi pahlawan yang keren!",
          style: TextStyle(
            fontSize: isDesktop ? 20 : 16, 
            color: AppColors.textMuted, 
            height: 1.5
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Buttons: Masuk Sekarang & Daftar Gratis
        Flex(
          direction: isDesktop ? Axis.horizontal : Axis.vertical,
          // HAPUS parameter 'gap: 16' yang error
          children: [
            SizedBox(
              width: isDesktop ? 200 : double.infinity,
              child: GradientButton(
                text: "Masuk Sekarang →",
                onPressed: () => context.push('/login'),
              ),
            ),
            
            // PENGGANTI GAP: Gunakan SizedBox kondisional
            SizedBox(
              width: isDesktop ? 16 : 0, 
              height: isDesktop ? 0 : 16
            ),

            SizedBox(
              width: isDesktop ? 150 : double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.push('/register'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Daftar Gratis", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 48),

        // Features Grid
        Container(
          padding: const EdgeInsets.only(top: 32),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: const Wrap(
            spacing: 40,
            runSpacing: 20,
            children: [
              _FeatureItem(emoji: "365", title: "Hari Belajar", color: AppColors.textPrimary),
              _FeatureItem(emoji: "∞", title: "Skill Tersedia", color: AppColors.brandPink),
              _FeatureItem(emoji: "🎮", title: "Gamified", color: Colors.orange),
              _FeatureItem(emoji: "🐱", title: "Pet Evolution", color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightContent() {
    return Center(
      child: SizedBox(
        width: 350,
        height: 350,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative Circles (Blur Effect)
            Positioned(
              top: 50, right: 50,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: AppColors.brandPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
              ).blur(30),
            ),
            Positioned(
              bottom: 50, left: 50,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
              ).blur(30),
            ),

            // Pet Illustration & Card
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating Emoji Cat (Menggunakan Text Emoji besar)
                const _FloatingCat(),
                
                const SizedBox(height: 24),
                
                // Character Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text("Anak Kucing Buluk", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Level 1 • Siap Belajar", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Badges
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BadgeItem(emoji: "✨", color: Colors.orange),
                    SizedBox(width: 8),
                    _BadgeItem(emoji: "🎯", color: AppColors.brandPurple),
                    SizedBox(width: 8),
                    _BadgeItem(emoji: "🔥", color: Colors.green),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Pembantu untuk Efek Blur (Extensi Sederhana)
extension BlurEffect on Container {
  Widget blur(double sigma) {
    return ImageFiltered(
      imageFilter:  ColorFilter.mode(Colors.transparent, BlendMode.clear) as dynamic, // Placeholder simple blur logic in Flutter is BackdropFilter usually
      // Karena BackdropFilter memblur background, untuk memblur Container itu sendiri kita gunakan Masking atau simpan sebagai Stack layer.
      // Cara termudah di Flutter untuk "Glowing Blob":
      child: Container(
        width: constraints?.maxWidth,
        height: constraints?.maxHeight,
        decoration: BoxDecoration(
          color: decoration is BoxDecoration ? (decoration as BoxDecoration).color : null,
          borderRadius: BorderRadius.circular(1000),
          boxShadow: [
             BoxShadow(
               color: (decoration as BoxDecoration).color ?? Colors.transparent,
               blurRadius: sigma,
               spreadRadius: 10,
             )
          ]
        ),
      ),
    );
  }
}

// Komponen Item Fitur
class _FeatureItem extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;

  const _FeatureItem({required this.emoji, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: color)),
        Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

// Komponen Badge Bulat
class _BadgeItem extends StatelessWidget {
  final String emoji;
  final Color color;

  const _BadgeItem({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
    );
  }
}

// Animasi Floating Kucing
class _FloatingCat extends StatefulWidget {
  const _FloatingCat();

  @override
  State<_FloatingCat> createState() => _FloatingCatState();
}

class _FloatingCatState extends State<_FloatingCat> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, 0),
    end: const Offset(0, -0.1), // Bergerak sedikit ke atas
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: const Text("😸", style: TextStyle(fontSize: 100)),
    );
  }
}