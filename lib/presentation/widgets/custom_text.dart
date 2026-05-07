part of widget;

class CustomText extends StatelessWidget {
  final String? text;

  /// Mặc định: [AppTextSizes.body]
  final AppTextSizes? fontSize;

  /// Mặc định: [FontWeight.normal]
  final FontWeight? fontWeight;

  /// Mặc định: [AppColors.black]
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  CustomText(
      {super.key,
      this.text,
      this.fontSize,
      this.fontWeight,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      style: TextStyle(
          fontSize: (fontSize ?? AppTextSizes.body).value,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? AppColors.black),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class CustomAutoSizeText extends StatelessWidget {
  final String? text;

  /// Mặc định: [AppTextSizes.body]
  final AppTextSizes? fontSize;

  /// Mặc định: [FontWeight.normal]
  final FontWeight? fontWeight;

  /// Mặc định: [AppColors.black]
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? minFontSize;

  CustomAutoSizeText(
      {super.key,
        this.text,
        this.fontSize,
        this.fontWeight,
        this.color,
        this.textAlign,
        this.maxLines,
        this.overflow,
        this.minFontSize});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text ?? "",
      style: TextStyle(
          fontSize: (fontSize ?? AppTextSizes.body).value,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? AppColors.black),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      minFontSize: minFontSize ?? 1,
    );
  }
}