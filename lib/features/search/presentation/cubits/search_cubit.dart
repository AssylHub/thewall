import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/search/domain/search_repo.dart';
import 'package:social_media_app/features/search/presentation/cubits/search_states.dart';

class SearchCubit extends Cubit<SearchStates> {
  final SearchRepo searchRepo;

  SearchCubit({required this.searchRepo}) : super(SearchInitial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    try {
      emit(SearchLoading());
      final users = await searchRepo.searchUsers(query);
      emit(SearchLoaded(users: users));
    } catch (e) {
      emit(SearchError(message: "Error fetching search results."));
    }
  }
}
