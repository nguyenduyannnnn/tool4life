part of widget;

class CustomPlaceholder extends StatelessWidget {

  final double? width;
  final double? height;

  CustomPlaceholder({
    this.width,
    this.height
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey,
    );
    // return Image.asset(
    //   Globals.config.iconApp!,
    //   fit: BoxFit.contain,
    //   width: width,
    //   height: height,
    // );
  }
}
