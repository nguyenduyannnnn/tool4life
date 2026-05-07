part of widget;

class CustomColumnInformation extends StatelessWidget {
  final String? title;
  final Widget? child;
  final String? content;
  final bool isRequire;

  CustomColumnInformation(
      {super.key,
      this.title,
      this.child,
      this.content,
      this.isRequire = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
            text: title,
            style: TextStyle(
                fontSize: AppTextSizes.body.value,
                fontWeight: FontWeight.bold,
                color: AppColors.black),
            children: [
              if (isRequire)
                TextSpan(
                  text: "*",
                  style: TextStyle(
                      fontSize: AppTextSizes.body.value,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                )
            ])),
        SizedBox(
          height: AppSizes.minPadding,
        ),
        child ??
            CustomText(
              text: content,
            )
      ],
    );
  }
}
