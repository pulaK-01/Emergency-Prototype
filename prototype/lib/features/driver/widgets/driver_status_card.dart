import 'package:medirapid/widgets/status_card.dart';

class DriverStatusCard extends StatusCard {
  const DriverStatusCard({
    super.key,
    required super.title,
    required super.message,
    required super.icon,
    required super.color,
  });

  /*   @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),

          Text(title, style: const TextStyle(fontSize: 20)),

          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  } */
}
