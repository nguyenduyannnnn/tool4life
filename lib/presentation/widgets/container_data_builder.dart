part of widget;

class ContainerDataBuilder extends StatelessWidget {
  final dynamic data;
  final Widget? emptyBuilder;
  final bool emptyShrinkWrap;
  final Widget? skeletonBuilder;
  final CustomBodyBuilder bodyBuilder;
  final CustomRefreshCallback? onRefresh;
  final ScrollPhysics? emptyPhysics;

  ContainerDataBuilder(
      {this.data,
      this.emptyBuilder,
      this.emptyShrinkWrap = false,
      this.skeletonBuilder,
      required this.bodyBuilder,
      this.onRefresh,
      this.emptyPhysics});

  Widget? _buildBody() {
    if (data == null) {
      return skeletonBuilder ?? CustomSkeleton();
    }

    if (data is List) {
      Widget body;
      if (data.isEmpty) {
        body = ListView(
          physics: emptyPhysics ?? AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: emptyShrinkWrap,
          children: [emptyBuilder ?? CustomEmpty()],
        );
      } else {
        body = bodyBuilder();
      }

      return ContainerScrollable(
        child: body,
        onRefresh: onRefresh,
      );
    }

    return ContainerScrollable(
      child: bodyBuilder(),
      onRefresh: onRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppAnimation.duration,
      child: _buildBody(),
    );
  }
}
