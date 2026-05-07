part of widget;

class CustomChip extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? textColor;
  final AppTextSizes? fontSize;
  final Color? iconColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  CustomChip(
      {super.key,
      this.text,
      this.icon,
      this.iconColor,
      this.borderColor,
      this.backgroundColor,
      this.textColor,
      this.onTap,
      this.fontSize});

  factory CustomChip.selected(
      {Key? key,
      bool isSelected = true,
      String? text,
      IconData? icon,
      Color? iconColor,
      VoidCallback? onTap}) {
    Color? borderColor, backgroundColor, textColor;

    if (!isSelected) {
      borderColor = AppColors.grey;
      backgroundColor = Colors.white;
      textColor = Colors.black;
    } else {
      iconColor = Colors.white;
    }

    return CustomChip(
      key: key,
      text: text,
      icon: icon,
      iconColor: iconColor,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: icon != null
          ? Icon(
              icon,
              color: iconColor ?? Colors.white,
            )
          : null,
      label: CustomText(
        text: text,
        color: textColor ?? Colors.white,
        fontSize: fontSize ?? AppTextSizes.body,
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(
            horizontal: AppSizes.minPadding * 1.5,
            vertical: AppSizes.minPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
          side: BorderSide(
            color: borderColor ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}
