part of widget;

class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? body;
  final CustomRefreshCallback? onRefresh;
  final bool? isBottomSheet;
  final List<CustomOptionAppBar>? options;

  CustomBottomSheet({
    this.title,
    this.body,
    this.onRefresh,
    this.isBottomSheet,
    this.options
  });

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Colors.transparent,
      isBottomSheet: isBottomSheet ?? true,
      body: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(height: context.appbar,),
            Flexible(
              fit: FlexFit.loose,
              child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: AppSizes.minPadding/ 2),
                        alignment: Alignment.center,
                        child: Container(
                          width: AppSizes.onTap,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(100.0)
                          ),
                        ),
                      ),
                      title == null?Container():Container(
                        height: kToolbarHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.line)
                          )
                        ),
                        child: CustomAppBar(
                          title: title,
                          options: options,
                          iconBack: Icons.close,
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: onRefresh == null?(body??Container()):ContainerScrollable(
                            child: body??Container(),
                            onRefresh: onRefresh
                        ),
                      )
                    ],
                  ),
                ),
                onTap: Utilities.hideKeyboard,
              ),
            ),
          ],
        ),
        onTap: () => CustomNavigator.pop(context),
      ),
    );
  }
}