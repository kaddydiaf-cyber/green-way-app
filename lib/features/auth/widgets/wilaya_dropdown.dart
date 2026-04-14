import 'package:flutter/material.dart';
import 'package:green_way_new/data/wilayas.dart';
import 'package:green_way_new/theme/app_colors.dart';

class WilayaDropdown extends StatelessWidget {
  final String? selectedWilaya;
  final ValueChanged<String?> onChanged;
  final Map<String, String> translations;

  const WilayaDropdown({
    super.key,
    required this.selectedWilaya,
    required this.onChanged,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Row(
            children: [
              const Icon(Icons.location_city_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Text(
                translations['choose_wilaya']!,
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
            ],
          ),
          value: selectedWilaya,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade500),
          items: Wilayas.list.map((wilaya) {
            return DropdownMenuItem<String>(
              value: wilaya['code'],
              child: Text(
                '${wilaya['code']} - ${wilaya['name']}',
                style: const TextStyle(fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
