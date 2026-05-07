part of widget;

class ContainerScrollable extends StatelessWidget {

  final Widget child;
  final CustomRefreshCallback? onRefresh;

  ContainerScrollable({required this.child, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return onRefresh == null
        ? child
        : RefreshIndicator(
        child: child,
        onRefresh: onRefresh!
    );
  }
}
