import 'package:flutter/material.dart';
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/localization/l10n.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/presentation/widgets/widget.dart';

class AccountScreen extends StatefulWidget {
  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen>
    with AutomaticKeepAliveClientMixin {
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
        child: Column(
      children: [
        Expanded(child: _buildContent()),
        _buildBottom(),
      ],
    ));
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.zero,
      physics: ClampingScrollPhysics(),
      children: [
        _buildHeader(),
        SizedBox(
          height: AppSizes.maxPadding,
        ),
        _buildOptions(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.maxPadding),
      child: Row(
        children: [
          Icon(
            Icons.account_circle,
            size: 80,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSizes.maxPadding,),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Trần Văn A",
                fontWeight: FontWeight.bold,
                fontSize: AppTextSizes.header,
              ),
              SizedBox(
                height: AppSizes.maxPadding,
              ),
              CustomText(
                text: "+84 987 654 321",
                color: AppColors.grey,
              )
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return CustomListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      separator: CustomLine(),
      children: [
        Padding(
          padding: EdgeInsets.all(AppSizes.maxPadding),
          child: CustomText(
            text: LangKey.current.options,
          ),
        ),
        // _buildMenu(Icons.manage_accounts, LangKey.current.account_information,
        //     Globals.bloc!.onAccountInformation),
        // _buildMenu(Icons.lock_reset, LangKey.current.change_password,
        //     Globals.bloc!.onChangePassword),
        // _buildMenu(Icons.support_agent, LangKey.current.support,
        //     Globals.bloc!.onSupport),
      ],
    );
  }

  Widget _buildMenu(IconData icon, String text, GestureTapCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.all(AppSizes.maxPadding),
      dense: true,
      leading: Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: AppColors.grey),
        width: AppSizes.onTap,
        height: AppSizes.onTap,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      title: CustomText(
        text: text,
        fontWeight: FontWeight.bold,
      ),
      trailing: Icon(
        Icons.navigate_next,
        color: AppColors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottom() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.maxPadding),
      child: CustomButton(
        text: LangKey.current.log_out,
        // onTap: Globals.bloc!.onLogout,
      ),
    );
  }
}
