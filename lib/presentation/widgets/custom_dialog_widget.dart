part of widget;

class CustomDialogWidget extends StatelessWidget {
  final Widget screen;
  final bool cancelable;

  CustomDialogWidget({
    required this.screen,
    this.cancelable = true,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: SingleChildScrollView(
        child: Container(
          height: context.height,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              GestureDetector(
                onTap: cancelable ? () => CustomNavigator.pop(context) : null,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin:
                        EdgeInsets.symmetric(horizontal: AppSizes.maxPadding),
                    child: screen,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
