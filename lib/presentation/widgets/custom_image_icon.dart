part of widget;

class CustomImageIcon extends StatelessWidget {
  final String icon;
  final Color? color;
  final double? size;

  CustomImageIcon({required this.icon, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return ImageIcon(
          AssetImage(icon),
          color: color ?? AppColors.primary,
          size: size ?? AppSizes.icon,
        );
  }
}
