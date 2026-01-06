import 'dart:convert';
import 'package:http/http.dart' as http;

const baseUrl = 'https://propel.hoomaservice.com';

Future<Map<String, dynamic>> post(String endpoint, Map body, {Map<String,String>? headers}) async {
  final uri = Uri.parse('$baseUrl$endpoint');
  final resp = await http.post(uri, headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (headers != null) ...headers,
  }, body: json.encode(body));
  return _parse(resp);
}

Future<Map<String, dynamic>> get(String endpoint, {Map<String,String>? headers, Map<String,String>? query}) async {
  var uri = Uri.parse('$baseUrl$endpoint');
  if (query != null) uri = uri.replace(queryParameters: query);
  final resp = await http.get(uri, headers: {
    'Accept': 'application/json',
    if (headers != null) ...headers,
  });
  return _parse(resp);
}

Map<String, dynamic> _parse(http.Response resp) {
  final ct = resp.headers['content-type'] ?? '';
  if (ct.contains('application/json')) {
    try {
      return json.decode(resp.body) as Map<String,dynamic>;
    } catch (e) {
      return {'status': false, 'code': resp.statusCode, 'message': 'invalid_json', 'body': resp.body};
    }
  }
  return {'status': false, 'code': resp.statusCode, 'message': 'non_json_response', 'body': resp.body};
}

void prettyPrint(String title, Map map) {
  print('\n=== $title ===');
  print(json.encode(map));
}

Future<void> main() async {
  // Credentials from user
  final email = '111975prathamesh@gmail.com';
  final password = 'Kiranm@123';

  print('Logging in...');
  final login = await post('/admin/user/login', {'email': email, 'password': password});
  prettyPrint('login', login);

  final token = (login['data'] != null && login['data']['token'] != null) ? login['data']['token'] as String : null;
  final userId = (login['data'] != null && login['data']['user'] != null)
      ? (login['data']['user']['id'] ?? login['data']['user']['user_id'] ?? login['data']['user']['userId'])
      : null;

  print('token: ${token != null}  userId: $userId');

  final authHeaders = token != null ? {'Authorization': 'Bearer $token'} : null;

  if (userId == null) {
    print('No user id found in login response; aborting further checks.');
    return;
  }

  // List of checks
  final checks = <String, Future<Map<String,dynamic>> Function()> {
    'userProfile (POST)': () => post('/api/user-profile', {'user_id': userId}, headers: authHeaders),
    'dashboard (GET)': () => get('/api/v1/user-get/dashboard/$userId', headers: authHeaders),
    'globalTurnover (GET)': () => get('/api/dashboard/global-turnover/$userId', headers: authHeaders),
    'matchingIncome (GET)': () => get('/api/dashboard/matching-income/$userId', headers: authHeaders),
    'directIncome (GET)': () => get('/api/dashboard/direct-income/$userId', headers: authHeaders),
    'myTeam (GET)': () => get('/api/dashboard/my-team/$userId', headers: authHeaders),
    'walletHistory (GET)': () => get('/api/dashboard/wallet-history/$userId', headers: authHeaders),
    'getDeposits (GET)': () => get('/api/user-deposit', headers: authHeaders, query: {'user_id': userId.toString()}),
    'getWithdraws (GET)': () => get('/api/withdraw-amount', headers: authHeaders, query: {'user_id': userId.toString()}),
    'rewards (GET)': () => get('/api/rewards', headers: authHeaders),
    'mlmTree (GET)': () => get('/api/mlm/tree/$userId', headers: authHeaders, query: {'usedmyrefrencecode': 'all'}),
  };

  for (final entry in checks.entries) {
    try {
      final res = await entry.value();
      prettyPrint(entry.key, res);
    } catch (e) {
      print('Error while calling ${entry.key}: $e');
    }
  }

  print('\nDone. Review outputs above to determine missing fields per screen.');
}
