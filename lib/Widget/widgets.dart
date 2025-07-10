import 'package:flutter/material.dart';

Widget searchBar(TextEditingController controller) {
  if (controller.text.isEmpty) {
    controller.text = '';
  }
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        Icon(Icons.search, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: (value) {
              // Handle search logic here
            },
            decoration: InputDecoration(
              hintText: 'Search..',
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        controller.clear();
                      },
                      child: Icon(
                        Icons.clear,
                        size: 18,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    ),
  );
}
