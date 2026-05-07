part of widget;

class CustomBottomOption extends StatefulWidget {
  final List<CustomBottomOptionModel>? options;
  final CustomRefreshCallback? onRefresh;
  final bool shrinkWrap;
  final GestureTapCallback? onConfirm;

  CustomBottomOption(
      {this.options, this.onRefresh, this.shrinkWrap = true, this.onConfirm});

  @override
  CustomBottomOptionState createState() => CustomBottomOptionState();
}

class CustomBottomOptionState extends State<CustomBottomOption> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  _onSelected(CustomBottomOptionModel model) {
    model.isSelected = !(model.isSelected ?? false);
    setState(() {});
  }

  Widget _buildContainer(List<Widget> children) {
    return CustomListView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.maxPadding),
        shrinkWrap: widget.shrinkWrap,
        separator: CustomLine(),
        children: children);
  }

  @override
  Widget build(BuildContext context) {
    return ContainerDataBuilder(
      data: widget.options,
      emptyShrinkWrap: widget.shrinkWrap,
      bodyBuilder: () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: _buildContainer(widget.options!
              .map((e) => InkWell(
            child: Container(
              padding:
              EdgeInsets.symmetric(vertical: AppSizes.maxPadding),
              child: Row(
                children: [
                  if (e.icon != null || e.image != null)
                    Container(
                      padding:
                      EdgeInsets.only(right: AppSizes.minPadding),
                      child: e.icon != null
                          ? CustomImageIcon(
                        icon: e.icon!,
                        size: AppSizes.icon,
                        color:
                        e.textColor ?? AppColors.hint,
                      )
                          : Image.asset(
                        e.image!,
                        width: AppSizes.icon,
                      ),
                    ),
                  Expanded(
                    child: CustomText(
                      text: e.text,
                      color: e.textColor,
                    ),
                  ),
                  if (e.isSelected != null && e.isSelected!)
                    Container(
                      padding:
                      EdgeInsets.only(left: AppSizes.minPadding),
                      child: Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: AppSizes.icon,
                      ),
                    )
                ],
              ),
            ),
            onTap: widget.onConfirm == null
                ? e.onTap
                : () => _onSelected(e),
          ))
              .toList())),
          if (widget.onConfirm != null)
            Padding(
              padding: EdgeInsets.all(AppSizes.maxPadding),
              child: CustomButton(
                text: LangKey.current.confirm,
                onTap: widget.onConfirm,
              ),
            )
        ],
      ),
      onRefresh: widget.onRefresh,
    );
  }
}

class CustomBottomOptionModel {
  dynamic id;
  String? icon;
  String? image;
  String? text;
  Color? textColor;
  bool? isSelected;
  GestureTapCallback? onTap;

  CustomBottomOptionModel(
      {this.id,
      this.icon,
      this.image,
      this.text,
      this.textColor,
      this.isSelected,
      this.onTap});
}
