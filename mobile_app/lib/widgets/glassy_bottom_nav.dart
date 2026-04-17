import 'dart:ui';
import 'package:flutter/material.dart';

class GlassyBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<Map<String, Object>>? items;

  const GlassyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Branding Color: Deep Indigo/Navy Blue
    const Color primaryNavy = Color(0xFF1A237E);
    const Color unselectedColor = Color(0xFF64748B);

    final navItems = items ??
        const [
          {'icon': Icons.home_rounded, 'label': 'Home'},
          {'icon': Icons.description_rounded, 'label': 'Requests'},
          {'icon': Icons.person_rounded, 'label': 'Profile'},
        ];

    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000), // Gihimo nako nga mas subtle ang shadow
            blurRadius: 24,
            spreadRadius: 0,
            offset: Offset(0, 12),
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Gi-increase gamay ang blur
          child: Container(
            height: 74,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              // Puti nga naay transparency para sa glass effect
              color: Colors.white.withOpacity(0.85), 
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(navItems.length, (index) {
                final isSelected = currentIndex == index;
                final icon = navItems[index]['icon'] as IconData;
                final label = navItems[index]['label'] as String;

                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                      decoration: BoxDecoration(
                        // Selected background mogamit sa imong Navy Blue
                        color: isSelected ? primaryNavy : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: isSelected 
                          ? [BoxShadow(color: primaryNavy.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: isSelected ? Colors.white : unselectedColor,
                            size: 22,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                label,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}