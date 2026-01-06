import 'api_repository.dart';

// Small example usage functions for the new APIs. These can be used in debug flows or unit tests.

Future<void> exampleCheckPosition() async {
  await ApiRepository.checkPosition(
    refCode: 'AB12CD34',
    joinPosition: 'left',
  );
  // print('Check position response: $resp');
}

Future<void> exampleGetMlmTree() async {
  final resp = await ApiRepository.getMlmTree(1, usedMyReferenceCode: 'all');
  if (resp != null) {
    // print('MLM tree nodes count: ${resp.data.length}');
  } else {
    // print('Failed to fetch MLM tree');
  }
}

Future<void> exampleGetRewards() async {
  final resp = await ApiRepository.getRewards();
  if (resp != null) {
    // print('Rewards count: ${resp.data.length}');
  } else {
    // print('Failed to fetch rewards');
  }
}
