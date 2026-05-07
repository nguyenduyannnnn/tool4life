import 'dart:async';
import 'package:flutter/material.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/meeting_model.dart';
import 'package:changmeeting/data/repository/meeting_repository.dart';
import 'package:changmeeting/data/repository/delete_meeting_repository.dart';
import 'package:rxdart/rxdart.dart';

enum MeetingAnimationState { normal, animating_out, removed, animating_in }

class MeetingsBloc {
  final TextEditingController searchController = TextEditingController();

  // Data streams
  final BehaviorSubject<List<MeetingModel>> _meetingsSubject =
      BehaviorSubject<List<MeetingModel>>.seeded([]);
  final BehaviorSubject<String> _searchQuerySubject =
      BehaviorSubject<String>.seeded('');
  final BehaviorSubject<bool> _isLoadingSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _isLoadingMoreSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _errorSubject =
      BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<Set<String>> _deletingMeetingsSubject =
      BehaviorSubject<Set<String>>.seeded({});
  final BehaviorSubject<Map<String, MeetingAnimationState>>
      _animationStatesSubject =
      BehaviorSubject<Map<String, MeetingAnimationState>>.seeded({});
  
  // Date filter streams
  final BehaviorSubject<DateTime?> _startDateSubject =
      BehaviorSubject<DateTime?>.seeded(null);
  final BehaviorSubject<DateTime?> _endDateSubject =
      BehaviorSubject<DateTime?>.seeded(null);

  // Pagination state
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  List<MeetingModel> _allMeetings = [];
  List<MeetingModel> _filteredMeetings = [];

  // Getters
  Stream<List<MeetingModel>> get meetingsStream => _meetingsSubject.stream;
  Stream<String> get searchQueryStream => _searchQuerySubject.stream;
  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;
  Stream<bool> get isLoadingMoreStream => _isLoadingMoreSubject.stream;
  Stream<String?> get errorStream => _errorSubject.stream;
  Stream<Set<String>> get deletingMeetingsStream =>
      _deletingMeetingsSubject.stream;
  Stream<Map<String, MeetingAnimationState>> get animationStatesStream =>
      _animationStatesSubject.stream;
  Stream<DateTime?> get startDateStream => _startDateSubject.stream;
  Stream<DateTime?> get endDateStream => _endDateSubject.stream;

  MeetingsBloc() {
    print("🔄 DEBUG: MeetingsBloc constructor called");
    loadInitialMeetings();
    _setupSearchListener();
  }

  Future<void> loadInitialMeetings() async {
    if (_isLoadingSubject.value) return;

    try {
      _isLoadingSubject.add(true);
      _errorSubject.add(null);
      _currentPage = 1;
      _allMeetings.clear();

      Utilities.customPrint("🔄 MEETINGS BLOC: Loading initial meetings...");
      print("🔄 DEBUG: Starting initial meetings load");

      final repository = MeetingRepository(
        page: _currentPage,
        pageSize: _pageSize,
        startDate: _startDateSubject.value,
        endDate: _endDateSubject.value,
      );
      final result = await repository.getMeetings();

      print("🔄 DEBUG: API call completed with result: ${result.isSuccess}");
      print("🔄 DEBUG: Message: ${result.message}");

      if (result.isSuccess && result.data != null) {
        _allMeetings = result.data!.items;
        _hasMorePages = result.data!.paging.hasMorePages;
        _updateFilteredMeetings();

        Utilities.customPrint(
            "✅ MEETINGS BLOC: Loaded ${_allMeetings.length} meetings");
      } else {
        _errorSubject.add(result.message ?? 'Không thể tải danh sách cuộc họp');
        Utilities.customPrint(
            "❌ MEETINGS BLOC: Failed to load meetings - ${result.message}");
      }
    } catch (e) {
      _errorSubject.add('Lỗi kết nối mạng. Vui lòng thử lại.');
      Utilities.customPrint("❌ MEETINGS BLOC: Exception - ${e.toString()}");
    } finally {
      _isLoadingSubject.add(false);
    }
  }

  Future<void> loadMoreMeetings() async {
    if (!_hasMorePages || _isLoadingMore || _isLoadingSubject.value) return;

    try {
      _isLoadingMore = true;
      _isLoadingMoreSubject.add(true);
      _currentPage++;

      Utilities.customPrint(
          "🔄 MEETINGS BLOC: Loading more meetings page $_currentPage...");

      final repository = MeetingRepository(
        page: _currentPage,
        pageSize: _pageSize,
        startDate: _startDateSubject.value,
        endDate: _endDateSubject.value,
      );
      final result = await repository.getMeetings();

      if (result.isSuccess && result.data != null) {
        _allMeetings.addAll(result.data!.items);
        _hasMorePages = result.data!.paging.hasMorePages;
        _updateFilteredMeetings();

        Utilities.customPrint(
            "✅ MEETINGS BLOC: Loaded ${result.data!.items.length} more meetings. Total: ${_allMeetings.length}");
      } else {
        _currentPage--; // Rollback page number on failure
        Utilities.customPrint(
            "❌ MEETINGS BLOC: Failed to load more meetings - ${result.message}");
      }
    } catch (e) {
      _currentPage--; // Rollback page number on failure
      Utilities.customPrint(
          "❌ MEETINGS BLOC: Exception loading more - ${e.toString()}");
    } finally {
      _isLoadingMore = false;
      _isLoadingMoreSubject.add(false);
    }
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      final query = searchController.text;
      _searchQuerySubject.add(query);
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    _updateFilteredMeetings(query);
  }

  void _updateFilteredMeetings([String? searchQuery]) {
    final query = searchQuery ?? searchController.text;

    if (query.isEmpty) {
      _filteredMeetings = List.from(_allMeetings);
    } else {
      _filteredMeetings = _allMeetings.where((meeting) {
        return meeting.title.toLowerCase().contains(query.toLowerCase()) ||
            (meeting.meetingId?.toLowerCase().contains(query.toLowerCase()) ==
                true);
      }).toList();
    }

    _meetingsSubject.add(_filteredMeetings);
  }

  Future<void> retryLoad() async {
    await loadInitialMeetings();
  }

  Future<void> refreshMeetings() async {
    Utilities.customPrint("🔄 MEETINGS BLOC: Pull to refresh triggered");
    await loadInitialMeetings();
  }

  void onSearchChanged(String query) {
    searchController.text = query;
  }

  void onMeetingTap(MeetingModel meeting) {
    Utilities.customPrint('Tapped on meeting: ${meeting.title}');
  }

  void _startDeleteAnimation(String meetingId) {
    print("🎬 ANIMATION: Starting delete animation for meeting ID: $meetingId");

    // Set animation state to animating_out
    final currentStates =
        Map<String, MeetingAnimationState>.from(_animationStatesSubject.value);
    currentStates[meetingId] = MeetingAnimationState.animating_out;
    _animationStatesSubject.add(currentStates);

    // Schedule completion after animation duration (500ms)
    Timer(const Duration(milliseconds: 500), () {
      _completeDeleteAnimation(meetingId);
    });
  }

  Future<void> _completeDeleteAnimation(String meetingId) async {
    try {
      print(
          "🎬 ANIMATION: Completing delete animation for meeting ID: $meetingId");

      // Find and store meeting before removal
      final meetingToDelete = _allMeetings.firstWhere((m) => m.id == meetingId);

      // Remove from local list after animation
      _allMeetings.removeWhere((meeting) => meeting.id == meetingId);
      _updateFilteredMeetings();

      // Set state to removed
      final currentStates = Map<String, MeetingAnimationState>.from(
          _animationStatesSubject.value);
      currentStates[meetingId] = MeetingAnimationState.removed;
      _animationStatesSubject.add(currentStates);

      // Add to deleting set for API call tracking
      final currentDeleting = _deletingMeetingsSubject.value;
      _deletingMeetingsSubject.add({...currentDeleting, meetingId});

      Utilities.customPrint(
          "🗑️ MEETINGS BLOC: Animation completed, calling delete API for: ${meetingToDelete.title}");

      // Call delete API
      final repository = DeleteMeetingRepository(meetingId: meetingId);
      final result = await repository.deleteMeeting();

      if (result.isSuccess) {
        Utilities.customPrint(
            "✅ MEETINGS BLOC: Successfully deleted meeting $meetingId");
        // Clean up animation state
        currentStates.remove(meetingId);
        _animationStatesSubject.add(currentStates);
      } else {
        Utilities.customPrint(
            "❌ MEETINGS BLOC: Failed to delete meeting - ${result.message}");
        // Restore the meeting with animation
        _restoreDeletedMeeting(meetingToDelete);
      }

      // Remove from deleting set
      final updatedDeleting = _deletingMeetingsSubject.value;
      updatedDeleting.remove(meetingId);
      _deletingMeetingsSubject.add(Set.from(updatedDeleting));
    } catch (e) {
      Utilities.customPrint(
          "❌ MEETINGS BLOC: Exception during delete API - ${e.toString()}");
      // Restore meeting on exception
      final meetingToRestore =
          _allMeetings.firstWhere((m) => m.id == meetingId, orElse: () {
        // If meeting was already removed, we need to restore it from backup
        // For now, we'll handle this case separately
        return MeetingModel(
          id: meetingId,
          title: "Restored Meeting",
          dateTime: DateTime.now(),
          status: "Hoàn thành",
          type: "other",
        );
      });
      _restoreDeletedMeeting(meetingToRestore);
    }
  }

  void _restoreDeletedMeeting(MeetingModel meeting) {
    print("🎬 ANIMATION: Restoring deleted meeting: ${meeting.title}");

    // Add meeting back to list
    _allMeetings.add(meeting);
    _allMeetings
        .sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Maintain order
    _updateFilteredMeetings();

    // Set animation state to animating_in
    final currentStates =
        Map<String, MeetingAnimationState>.from(_animationStatesSubject.value);
    currentStates[meeting.id] = MeetingAnimationState.animating_in;
    _animationStatesSubject.add(currentStates);

    // Clean up animation state after fade in
    Timer(const Duration(milliseconds: 500), () {
      currentStates[meeting.id] = MeetingAnimationState.normal;
      _animationStatesSubject.add(currentStates);
    });
  }

  // Legacy method for backward compatibility - now triggers animation
  Future<void> deleteMeeting(String meetingId) async {
    _startDeleteAnimation(meetingId);
  }

  void onEditMeeting(MeetingModel meeting) {
    Utilities.customPrint('Edit meeting: ${meeting.title}');
    // TODO: Navigate to edit meeting screen
  }

  void onMeetingOptions(MeetingModel meeting) {
    Utilities.customPrint('Options for meeting: ${meeting.title}');
    // This method will be called by popup menu, actual handling is in UI
  }

  // Date filter methods
  void applyDateFilter(DateTime? startDate, DateTime? endDate) {
    _startDateSubject.add(startDate);
    _endDateSubject.add(endDate);
    
    // Reset and reload with filter
    _currentPage = 1;
    _allMeetings.clear();
    loadInitialMeetings();
    
    Utilities.customPrint('📅 Date filter applied: ${startDate != null ? startDate.toString() : 'null'} to ${endDate != null ? endDate.toString() : 'null'}');
  }

  void clearDateFilter() {
    _startDateSubject.add(null);
    _endDateSubject.add(null);
    
    // Reset and reload without filter
    _currentPage = 1;
    _allMeetings.clear();
    loadInitialMeetings();
    
    Utilities.customPrint('📅 Date filter cleared');
  }

  void dispose() {
    searchController.dispose();
    _meetingsSubject.close();
    _searchQuerySubject.close();
    _isLoadingSubject.close();
    _isLoadingMoreSubject.close();
    _errorSubject.close();
    _deletingMeetingsSubject.close();
    _animationStatesSubject.close();
    _startDateSubject.close();
    _endDateSubject.close();
  }
}
