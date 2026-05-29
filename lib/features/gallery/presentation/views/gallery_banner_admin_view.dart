import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class GalleryBannerAdminView extends StatefulWidget {
  const GalleryBannerAdminView({super.key});

  @override
  State<GalleryBannerAdminView> createState() => _GalleryBannerAdminViewState();
}

class _GalleryBannerAdminViewState extends State<GalleryBannerAdminView> {
  final List<_BannerDraft> _drafts = [
    const _BannerDraft(
      eyebrow: 'TENDENCIA DE LA SEMANA',
      title: 'FADES TEXTURIZADOS',
      caption: 'Lineas suaves, terminacion natural.',
    ),
    const _BannerDraft(
      eyebrow: 'RITUAL DE BARBA',
      title: 'BARBA LUXURY',
      caption: 'Toalla caliente y aceites premium.',
    ),
    const _BannerDraft(
      eyebrow: 'EDICION LIMITADA',
      title: 'DISENO Y PLATINADOS',
      caption: 'Tatuajes capilares y decoloraciones.',
    ),
  ];

  void _addDraft() {
    setState(() => _drafts.add(const _BannerDraft(
          eyebrow: 'NUEVO PROMOCIONAL',
          title: 'TITULO',
          caption: 'Subtitulo descriptivo.',
        )));
  }

  void _remove(int index) {
    setState(() => _drafts.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CREAR PUBLICIDAD',
          style: TextStyle(
            color: Color(0xFFF5F5DC),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: gold.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: gold, size: 16),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Estos slots aparecen rotando arriba del buscador. Pronto se guardaran en backend.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                itemCount: _drafts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, i) => _DraftCard(
                  draft: _drafts[i],
                  index: i + 1,
                  onRemove: () => _remove(i),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDraft,
        backgroundColor: gold,
        foregroundColor: Colors.black,
        icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
        label: const Text(
          'NUEVO SLOT',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _BannerDraft {
  final String eyebrow;
  final String title;
  final String caption;
  const _BannerDraft({
    required this.eyebrow,
    required this.title,
    required this.caption,
  });
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.index,
    required this.onRemove,
  });

  final _BannerDraft draft;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: gold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'SLOT $index',
                  style: TextStyle(
                    color: gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            draft.eyebrow,
            style: TextStyle(
              color: gold,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            draft.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            draft.caption,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
