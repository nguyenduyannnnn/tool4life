part of widget;

class CustomButton extends StatelessWidget {
  final String? text;
  final bool enable;
  final bool expand;
  final Color? color;
  final Color? textColor;
  final GestureTapCallback? onTap;
  final bool isMain;

  CustomButton(
      {this.text,
      this.enable = true,
      this.expand = true,
      this.color,
      this.onTap,
      this.textColor,
      this.isMain = true});

  Widget _buildBody() {
    return ElevatedButton(
      child: CustomText(
        text: text,
        fontSize: AppTextSizes.body,
        color: enable
            ? (isMain ? (textColor ?? AppColors.white) : AppColors.primary)
            : AppColors.black,
        fontWeight: FontWeight.bold,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: enable
            ? (color ?? (isMain ? AppColors.primary : AppColors.white))
            : null,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.all(AppSizes.maxPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
          side: enable
              ? BorderSide(
                  color: color ?? AppColors.primary,
                )
              : BorderSide.none,
        ),
      ),
      onPressed: enable ? onTap : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return expand
        ? SizedBox(
            width: double.infinity,
            child: _buildBody(),
          )
        : _buildBody();
  }
}

class CustomIconButton extends StatelessWidget {
  final GestureTapCallback? onTap;
  final IconData? iconData;
  final String? icon;
  final Color? color;
  final double? size;

  CustomIconButton({this.icon, this.iconData, this.onTap, this.color, this.size})
      : assert(iconData != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.all(AppSizes.minPadding),
        ),
        icon: icon != null
            ? CustomImageIcon(
                icon: icon!,
                color: color,
              )
            : Icon(
                iconData,
                color: color ?? AppColors.primary,
                size: size?? AppSizes.icon,
              ));
  }
}

class CustomTextButton extends StatelessWidget {
  final GestureTapCallback? onTap;
  final String text;
  final Color? color;

  CustomTextButton({required this.text, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.all(AppSizes.minPadding),
        ),
        child: CustomText(
          text: text,
          color: color ?? AppColors.primary,
        ));
  }
}
