part of widget;

class CustomAuthenScreen extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> inputForm;
  final String button1;
  final String? button2;
  final GestureTapCallback onButton1;
  final GestureTapCallback? onButton2;
  final String? logoAsset;
  final Widget? belowForm;
  final Widget? belowButton1;

  CustomAuthenScreen(
      {super.key,
      required this.title,
      required this.content,
      required this.inputForm,
      required this.button1,
      this.button2,
      required this.onButton1,
      this.onButton2,
      this.logoAsset,
      this.belowForm,
      this.belowButton1});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomListView(
        shrinkWrap: true,
        separatorPadding: AppSizes.ultraPadding,
        physics: ClampingScrollPhysics(),
        children: [
          _buildHeader(),
          _buildContent(),
          if(belowForm != null) belowForm!,
          _buildButton1(),
          if(belowButton1 != null) belowButton1!,
          if(button2 != null)
            ...[
              _buildOr(),
              _buildButton2()
            ]
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return CustomAuthenHeader(title: title, content: content, logoAsset: logoAsset);
  }

  Widget _buildContent() {
    return CustomListView(
      separatorPadding: AppSizes.maxPadding,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: inputForm,
    );
  }

  Widget _buildButton1() {
    return CustomButton(
      text: button1,
      onTap: onButton1,
    );
  }

  Widget _buildOr() {
    return Row(
      children: [
        Expanded(child: CustomLine()),
        SizedBox(
          width: AppSizes.maxPadding,
        ),
        CustomText(text: LangKey.current.or.toLowerCase()),
        SizedBox(
          width: AppSizes.maxPadding,
        ),
        Expanded(child: CustomLine()),
      ],
    );
  }

  Widget _buildButton2() {
    return CustomButton(
      text: button2,
      isMain: false,
      onTap: onButton2,
    );
  }
}
