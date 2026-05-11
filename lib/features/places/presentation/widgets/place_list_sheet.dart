import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/place_entity.dart';
import '../bloc/places_bloc.dart';
import '../bloc/places_event.dart';
import '../bloc/places_state.dart';
import 'place_item.dart';
import 'place_tag_filter.dart';

class PlaceListSheet extends StatefulWidget {
  final ValueChanged<PlaceEntity> onPlaceTap;

  const PlaceListSheet({super.key, required this.onPlaceTap});

  static Future<void> show(
    BuildContext context, {
    required PlacesBloc bloc,
    required ValueChanged<PlaceEntity> onPlaceTap,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: PlaceListSheet(onPlaceTap: onPlaceTap),
      ),
    );
  }

  @override
  State<PlaceListSheet> createState() => _PlaceListSheetState();
}

class _PlaceListSheetState extends State<PlaceListSheet> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: context.read<PlacesBloc>().state.searchKeyword,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: BlocBuilder<PlacesBloc, PlacesState>(
            builder: (context, state) {
              final items = state.filteredPlaces;
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Tìm theo tên / mô tả',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      onChanged: (v) => context
                          .read<PlacesBloc>()
                          .add(SearchPlacesEvent(v)),
                    ),
                  ),
                  PlaceTagFilter(
                    selected: state.selectedTag,
                    onChanged: (tag) => context
                        .read<PlacesBloc>()
                        .add(FilterPlacesByTag(tag)),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              'Không có địa điểm khớp',
                              style: TextStyle(color: AppColors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            itemCount: items.length,
                            itemBuilder: (context, index) => PlaceItem(
                              place: items[index],
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onPlaceTap(items[index]);
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
