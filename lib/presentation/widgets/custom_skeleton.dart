part of widget;

class CustomSkeleton extends StatelessWidget {
  const CustomSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.maxPadding),
      child: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
