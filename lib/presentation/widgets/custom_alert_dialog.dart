part of widget;

class CustomAlertDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final bool showSubmitted;
  final String? textSubmitted;
  final GestureTapCallback? onSubmitted;
  final String? textSubSubmitted;
  final GestureTapCallback? onSubSubmitted;
  final bool enableCancel;
  final CustomAlertDialogType type;

  CustomAlertDialog(
      {required this.title,
      this.content,
      this.showSubmitted = true,
      this.onSubmitted,
      this.textSubmitted,
      this.onSubSubmitted,
      this.textSubSubmitted,
      this.enableCancel = false,
      this.type = CustomAlertDialogType.info});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if(type == CustomAlertDialogType.success) {
      icon = Icons.check_circle;
      color = Colors.green;
    }
    else if(type == CustomAlertDialogType.warning) {
      icon = Icons.warning;
      color = Colors.orangeAccent;
    }
    else if(type == CustomAlertDialogType.error) {
      icon = Icons.error;
      color = Colors.red;
    }
    else {
      icon = Icons.info;
      color = AppColors.primary;
    }

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              color: Colors.white),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.maxPadding),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 80,
                    ),
                    Container(
                      height: AppSizes.minPadding,
                    ),
                    CustomText(
                      text: title,
                      textAlign: TextAlign.center,
                      fontSize: AppTextSizes.title,
                      fontWeight: FontWeight.bold,
                    ),
                    Container(
                      height: AppSizes.minPadding,
                    ),
                    CustomText(
                      text: content,
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: AppSizes.minPadding,
                    ),
                    if (showSubmitted)
                      Padding(
                        padding: EdgeInsets.only(top: AppSizes.minPadding),
                        child: CustomButton(
                          text: textSubmitted ?? LangKey.current.i_get_it,
                          color: AppColors.primary,
                          onTap:
                          onSubmitted ?? () => CustomNavigator.pop(context),
                        ),
                      ),
                    if (textSubSubmitted != null)
                      Padding(
                          padding: EdgeInsets.only(top: AppSizes.minPadding),
                          child: CustomButton(
                            text: textSubSubmitted,
                            color: AppColors.accent,
                            onTap: onSubSubmitted ??
                                () => CustomNavigator.pop(context),
                          )),
                    if(enableCancel)
                      Padding(
                        padding: EdgeInsets.only(top: AppSizes.minPadding),
                        child: CustomButton(
                          text: LangKey.current.close,
                          color: AppColors.white,
                          textColor: AppColors.black,
                          onTap: () => CustomNavigator.pop(context),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

enum CustomAlertDialogType { success, warning, error, info }