part of widget;

class CustomScaffold extends StatelessWidget {
  final Widget? body;
  final Widget? bodyTablet;
  final Widget? bodyDesktop;
  final String? title;
  final List<CustomOptionAppBar>? options;
  final CustomRefreshCallback? onRefresh;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final GestureTapCallback? onWillPop;
  final bool isBottomSheet;
  final String? backgroundImage;

  CustomScaffold(
      {this.body,
      this.bodyTablet,
      this.bodyDesktop,
      this.title,
      this.options,
      this.onRefresh,
      this.backgroundColor,
      this.floatingActionButton,
      this.onWillPop,
      this.isBottomSheet = false,
      this.backgroundImage});

  Widget _buildChild() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppSizes.sizeDesktop) {
          return bodyDesktop ?? bodyTablet ?? body ?? SizedBox();
        } else if (constraints.maxWidth >= AppSizes.sizeTablet) {
          return bodyTablet ?? body ?? SizedBox();
        }
        return body ?? SizedBox();
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        if (title == null)
          Container()
        else
          Container(
            height: context.appbar,
            width: double.infinity,
            padding: EdgeInsets.only(top: context.top),
            child: CustomAppBar(
              title: title,
              options: options,
              onWillPop: onWillPop,
            ),
          ),
        Expanded(
            child:
                ContainerScrollable(child: _buildChild(), onRefresh: onRefresh))
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.white,
      appBar: (body != null && body is CupertinoPageScaffold)
          ? null
          : PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox(),
            ),
      body: backgroundImage == null
          ? SafeArea(
              top: false,
              left: false,
              right: false,
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildContent(context)),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  child: Container(
                    width: context.width,
                    height: context.height,
                    child: Image.asset(
                      backgroundImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                _buildContent(context)
              ],
            ),
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: !isBottomSheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return onWillPop == null
        ? _buildBody(context)
        : PopScope(
            child: _buildBody(context),
            canPop: false,
            onPopInvokedWithResult: (event, _) {
              if (!event) {
                onWillPop!();
              }
            },
          );
  }
}
