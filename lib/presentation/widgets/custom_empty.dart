part of widget;

class CustomEmpty extends StatelessWidget {

  final String? title;
  final EdgeInsetsGeometry? padding;
  final GestureTapCallback? onTap;

  CustomEmpty({this.title, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(
          vertical: AppSizes.ultraPadding,
          horizontal: AppSizes.maxPadding),
      child: Column(
        children: [
          CustomText(
            text: title ?? LangKey.current.data_empty,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }
}
