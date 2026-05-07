part of widget;

class CustomTextField extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? hintText;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final GestureTapCallback? onSuffixIconTap;
  final Widget? prefixIcon;
  final int? maxLines;
  final bool isText;
  final String? text;
  final GestureTapCallback? onTap;

  CustomTextField(
      {this.focusNode,
      this.controller,
      this.hintText,
      this.suffixIcon,
      this.keyboardType,
      this.inputFormatters,
      this.textInputAction,
      this.onSubmitted,
      this.obscureText = false,
      this.onSuffixIconTap,
      this.prefixIcon,
      this.maxLines,
      this.isText = false,
      this.text,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isText) {
      return InkWell(
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(100.0)),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(AppSizes.maxPadding),
                child: CustomText(
                  text: (text ?? "").isEmpty ? hintText : text,
                  color: (text ?? "").isEmpty ? AppColors.hint : Colors.black,
                ),
              )),
              if (suffixIcon != null)
                IconButton(
                    onPressed: onSuffixIconTap,
                    icon: Icon(
                      suffixIcon,
                      size: 20,
                      color: AppColors.grey,
                    ))
            ],
          ),
        ),
        onTap: onTap,
      );
    }

    return TextField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.line),
            borderRadius:
                BorderRadius.circular((maxLines ?? 1) > 1 ? 10.0 : 100.0)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
            borderRadius:
                BorderRadius.circular((maxLines ?? 1) > 1 ? 10.0 : 100.0)),
        isDense: true,
        contentPadding: EdgeInsets.all(AppSizes.maxPadding),
        hintText: hintText,
        hintStyle:
            TextStyle(color: AppColors.hint, fontSize: AppTextSizes.body.value),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                onPressed: onSuffixIconTap,
                icon: Icon(
                  suffixIcon,
                  size: 20,
                  color: AppColors.grey,
                )),
      ),
      style: TextStyle(fontSize: AppTextSizes.body.value, color: Colors.black),
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      maxLines: maxLines ?? 1,
    );
  }
}

class CustomPhoneField extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  CustomPhoneField(
      {super.key,
      required this.focusNode,
      required this.controller,
      this.textInputAction,
      this.onSubmitted});

  @override
  CustomPhoneFieldState createState() => CustomPhoneFieldState();
}

class CustomPhoneFieldState extends State<CustomPhoneField> {
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

  _onTap(BuildContext context) {
    CustomDialog.showBottom(
        context,
        CustomBottomSheet(
            body: CustomBottomOption(
          options: Globals.countryModels
              .map((e) => CustomBottomOptionModel(
                  image: e.image,
                  text: e.name,
                  onTap: () async {
                    Globals.streamCountryModel.set(e);
                    await Globals.prefs
                        .setInt(SharedPrefsKey.country_code, e.countryCode);
                    CustomNavigator.pop(context);
                    setState(() {});
                  }))
              .toList(),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      hintText: LangKey.current.phone_number,
      suffixIcon: Icons.phone,
      keyboardType: TextInputType.phone,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      prefixIcon: IconButton(
          onPressed: () => _onTap(context),
          icon: StreamBuilder(
              stream: Globals.streamCountryModel.output,
              initialData: Globals.streamCountryModel.value,
              builder: (_, snapshot) {
                CountryModel model = snapshot.data!;
                return Image.asset(
                  model.image,
                  width: 20,
                );
              })),
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  final String? hintText;
  final BehaviorSubject<bool> stream;
  final FocusNode focusNode;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final bool isShowValidation;

  CustomPasswordField(
      {super.key,
      this.hintText,
      required this.stream,
      required this.focusNode,
      required this.controller,
      this.textInputAction,
      this.onSubmitted,
      this.isShowValidation = true});

  @override
  CustomPasswordFieldState createState() => CustomPasswordFieldState();
}

class CustomPasswordFieldState extends State<CustomPasswordField> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isShowValidation) {
      widget.controller.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder(
            stream: widget.stream.output,
            initialData: true,
            builder: (_, snapshot) {
              bool event = snapshot.data!;
              return CustomTextField(
                focusNode: widget.focusNode,
                controller: widget.controller,
                hintText: widget.hintText ?? LangKey.current.password,
                suffixIcon: event
                    ? Icons.remove_red_eye_outlined
                    : Icons.remove_red_eye,
                keyboardType: TextInputType.visiblePassword,
                obscureText: snapshot.data!,
                textInputAction: widget.textInputAction,
                onSubmitted: widget.onSubmitted,
                onSuffixIconTap: () => widget.stream.set(!event),
              );
            }),
        if (widget.isShowValidation)
          CustomListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
                top: AppSizes.minPadding,
                right: AppSizes.maxPadding,
                left: AppSizes.maxPadding),
            children: Globals.passwordValidationModels.map((e) {
              bool isValidated =
                  Utilities.validate(e.regPattern, widget.controller.text);
              Color color = isValidated ? Colors.green : AppColors.grey;

              return Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 12,
                  ),
                  SizedBox(
                    width: AppSizes.minPadding,
                  ),
                  Expanded(
                      child: CustomText(
                    text: e.title,
                    fontSize: AppTextSizes.subBody,
                    color: color,
                  ))
                ],
              );
            }).toList(),
          )
      ],
    );
  }
}
