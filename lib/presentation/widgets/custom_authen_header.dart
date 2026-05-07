part of widget;

class CustomAuthenHeader extends StatelessWidget {
  final String title;
  final String content;
  final String? logoAsset;

  const CustomAuthenHeader({super.key, required this.title, required this.content, this.logoAsset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(logoAsset != null) ...[
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(logoAsset!),
          ),
          SizedBox(height: AppSizes.maxPadding,)
        ],
        CustomText(
          text: title,
          fontSize: AppTextSizes.header,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.minPadding,),
        CustomText(
          text: content,
          color: AppColors.grey,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
