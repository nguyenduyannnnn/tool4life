import 'package:flutter/material.dart';
import 'package:changmeeting/data/models/meeting_model.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/bloc/meetings_bloc.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/widgets/meeting_item_widget.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final MeetingsBloc _bloc = MeetingsBloc();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _bloc.searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm cuộc họp...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Meetings list
          Expanded(
            child: StreamBuilder<List<MeetingModel>>(
              stream: _bloc.meetingsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final meetings = snapshot.data!;

                  if (meetings.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không tìm thấy cuộc họp nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = meetings[index];
                      return MeetingItemWidget(
                        meeting: meeting,
                        onTap: () => _bloc.onMeetingTap(meeting),
                        onOptions: () => _bloc.onMeetingOptions(meeting),
                      );
                    },
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
