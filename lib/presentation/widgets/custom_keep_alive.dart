part of widget;

class CustomKeepAlive extends StatefulWidget {
  final Widget child;

  const CustomKeepAlive({Key? key, required this.child}) : super(key: key);

  @override
  _CustomKeepAliveState createState() => _CustomKeepAliveState();
}

class _CustomKeepAliveState extends State<CustomKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
