import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onPressed;

  const AppCard({
    super.key,
    required this.title,
    required this.children,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 140,
            color: Colors.green,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  Row(
                    children: [
                      const Text("# ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  ...children,

                  const SizedBox(height: 10),

                  if (onPressed != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onPressed,
                        child: const Text("Commencer"),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}