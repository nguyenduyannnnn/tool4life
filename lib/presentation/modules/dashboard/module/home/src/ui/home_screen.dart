import 'package:flutter/material.dart';
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/bloc/dashboard_bloc.dart';
import 'package:changmeeting/presentation/widgets/widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final DashboardBloc _dashboardBloc = DashboardBloc();

  @override
  void dispose() {
    _dashboardBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomListView(
      children: [
        SizedBox(
            // height: context.padding.top,
            ),
        _buildHeader(),
        // Action Buttons
        _buildGroupCategory(),
        // Shipment
        _buildShipment(),
        // Debts
        _buildDebts(),
        // Recordings
        _buildRecordings(),
        // Floating Button
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.maxPadding),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: Globals.bloc!.onProfile,
                child: Icon(
                  Icons.account_circle,
                  size: 40,
                  color: AppColors.white,
                ),
              ),
              CustomIconButton(
                onTap: Globals.bloc!.onNotification,
                iconData: Icons.notifications,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
          SizedBox(height: AppSizes.minPadding),
          CustomText(
            text: "Xin chào, Admin",
            color: Colors.white,
            fontSize: AppTextSizes.title,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: AppSizes.minPadding),
          CustomText(
            text: "Theo dõi vận đơn",
            color: Colors.white70,
          ),
          SizedBox(height: AppSizes.minPadding),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.minPadding * 1.5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: Globals.bloc!.searchController,
              decoration: InputDecoration(
                hintText: "Nhập tracking number cần tìm",
                hintStyle: TextStyle(
                    color: AppColors.white, fontSize: AppTextSizes.body.value),
                border: InputBorder.none,
                suffixIcon: IconButton(
                    onPressed: () {
                      Globals.bloc!
                          .onSearch(Globals.bloc!.searchController.text);
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    )),
              ),
              onSubmitted: (value) {
                Globals.bloc!.onSearch(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCategory() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.minPadding,
      crossAxisSpacing: AppSizes.maxPadding,
      // padding: EdgeInsets.only(bottom: AppSizes.maxPadding),
      childAspectRatio: 1,
      children: [
        actionButton(
            "Tạo Label", Icons.local_shipping, Globals.bloc!.onCreateLabel),
        actionButton(
            "Người nhận hàng", Icons.people, Globals.bloc!.onReceiverList),
        actionButton(
            "Công nợ", Icons.account_balance, Globals.bloc!.onDebtsManagement),
        actionButton("Liên hệ", Icons.phone, Globals.bloc!.onContact),
        actionButton(
            "Ghi âm", Icons.mic, () => _dashboardBloc.onRecordings(context)),
      ],
    );
  }

  Widget actionButton(String title, IconData icon, Function() function) {
    return InkWell(
      onTap: function,
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.sizeOf(context).width / 6,
        height: MediaQuery.sizeOf(context).width / 6,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 30),
            SizedBox(
              height: AppSizes.minPadding,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: AppTextSizes.tiny.value,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitleSeeAll(String title, IconData icon, Function() function) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24.0),
        SizedBox(
          width: AppSizes.minPadding,
        ),
        Expanded(
            child: Text(
          title,
          style: TextStyle(
            fontSize: AppTextSizes.subTitle.value,
            fontWeight: FontWeight.w600,
          ),
        )),
        CustomTextButton(
          onTap: function,
          text: "Xem tất cả",
        )
      ],
    );
  }

  Widget packageCard(Function() function) {
    return InkWell(
      onTap: function,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_shipping,
                        color: AppColors.primary, size: 24),
                    SizedBox(width: 10),
                    Text(
                      "The pair of sneakers",
                      style: TextStyle(
                          fontSize: AppTextSizes.subTitle.value,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 5),
            const Text("W94235675472RD", style: TextStyle(color: Colors.grey)),
            const Divider(height: 20, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("From:", style: TextStyle(color: Colors.grey)),
                    Text("San Diego",
                        style: TextStyle(
                            fontSize: AppTextSizes.body.value,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("To:", style: TextStyle(color: Colors.grey)),
                    Text("New York",
                        style: TextStyle(
                            fontSize: AppTextSizes.body.value,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Status:", style: TextStyle(color: Colors.grey)),
                    Text("On way",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("Price:", style: TextStyle(color: Colors.grey)),
                    Text("\$66.00",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipment() {
    return Column(
      children: [
        buildTitleSeeAll("Shipment gần nhất", Icons.local_shipping,
            Globals.bloc!.onLabelsManagement),
        SizedBox(height: AppSizes.minPadding),
        packageCard(Globals.bloc!.onShipmentCurrent),
      ],
    );
  }

  Widget _buildDebts() {
    return Column(
      children: [
        buildTitleSeeAll("Công nợ gần nhất", Icons.account_balance,
            Globals.bloc!.onDebtsManagement),
        SizedBox(height: AppSizes.minPadding),
      ],
    );
  }

  Widget _buildRecordings() {
    return Column(
      children: [
        buildTitleSeeAll("Ghi âm gần nhất", Icons.mic,
            () => _dashboardBloc.onRecordings(context)),
        SizedBox(height: AppSizes.minPadding),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
