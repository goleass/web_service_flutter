import 'package:http/http.dart' as http;
import 'package:web_service/models/result_cep.dart';

class ViaCepService {
  static Future<ResultCep> fetchCep({String? cep}) async {
    final Uri uri = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      ResultCep r = ResultCep.fromJson(response.body);
      if (r.cep != null) {
        return r;
      } else {
        throw Exception('Requisição inválida!');
      }
    } else {
      throw Exception('Requisição inválida!');
    }
  }
}
