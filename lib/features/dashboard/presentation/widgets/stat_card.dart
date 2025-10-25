// lib/features/dashboard/presentation/widgets/stat_card.dart
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Kart içeriği için mevcut yükseklik
            final double h = constraints.maxHeight.isFinite ? constraints.maxHeight : 120;
            // Mevcut yüksekliğe göre padding ve ikon boyutlarını ayarla
            final double verticalPadding = h < 70 ? 8 : 12;
            final double horizontalPadding = h < 70 ? 8 : 12;
            final double iconSize = h < 70 ? 18 : 24;
            final double iconContainerPadding = h < 70 ? 6 : 8;

            // Temel metin stilleri
            final TextStyle valueStyleBase = Theme.of(context).textTheme.headlineMedium ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
            final TextStyle titleStyleBase = Theme.of(context).textTheme.bodyMedium ??
                const TextStyle(fontSize: 14);

            final TextStyle valueStyle = valueStyleBase.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            );

            final TextStyle titleStyle = titleStyleBase.copyWith(
              color: Colors.grey,
            );

            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding,
                horizontal: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Column'un dikey alanı doldurmasını sağla ki Expanded çalışsın
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(iconContainerPadding),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: iconSize),
                      ),
                      if (onTap != null)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: iconSize * 0.7,
                          color: Colors.grey,
                        ),
                    ],
                  ),

                  // Esnek boşluk
                  SizedBox(height: h < 70 ? 6 : 10),

                  // Kalan alanı doldurmak için metin alanını genişlet.
                  // Expanded, dikey alan dar olduğunda Column'un taşmasını engeller.
                  Expanded(
                    // 👈 DEĞİŞİKLİK BURADA BAŞLIYOR
                    // Column'un tamamını FittedBox ile sarmak, taşmayı önler.
                    // Alan yetersiz olduğunda tüm metin bloğunu orantılı olarak küçültür.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: valueStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          ),
                        ],
                      ),
                    ),
                    // 👈 DEĞİŞİKLİK BURADA BİTİYOR
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}