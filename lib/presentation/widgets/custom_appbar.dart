part of widget;

class CustomAppBar extends StatelessWidget {
  final String? title;
  final IconData? iconBack;
  final List<CustomOptionAppBar>? options;
  final GestureTapCallback? onWillPop;

  CustomAppBar({this.title, this.iconBack, this.options, this.onWillPop});

  Widget _buildIcon(int index, Color color) {
    CustomOptionAppBar model = options![index];
    return CustomIconButton(
        onTap: model.onTap, iconData: model.icon, color: model.color ?? color);
  }

  @override
  Widget build(BuildContext context) {
    bool canPop = CustomNavigator.canPop(context);
    Color color = AppColors.black;
    Color optionColor = AppColors.black;
    return SizedBox(
      height: kToolbarHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppSizes.minPadding +
                    ((options == null || options!.length == 0)
                        ? (canPop ? kMinInteractiveDimension : 0.0)
                        : (options!.length * kMinInteractiveDimension))),
            child: Center(
              child: CustomText(
                text: title,
                fontSize: AppTextSizes.subTitle,
                color: color,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Row(
            children: [
              Opacity(
                child: CustomIconButton(
                  iconData: iconBack ?? Icons.arrow_back_ios,
                  color: color,
                  onTap: canPop
                      ? (onWillPop ?? () => CustomNavigator.pop(context))
                      : null,
                ),
                opacity: canPop ? 1.0 : 0.0,
              ),
              Expanded(
                child: Container(),
              ),
              if (options == null || options!.length == 0)
                Container()
              else
                ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options!.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) => _buildIcon(index, optionColor))
            ],
          )
        ],
      ),
    );
  }
}

class CustomOptionAppBar {
  final IconData icon;
  final GestureTapCallback? onTap;
  final Color? color;

  CustomOptionAppBar({required this.icon, this.onTap,this.color, });
}
