import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:web_service/models/result_cep.dart';
import 'package:web_service/services/via_cep_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCepController = TextEditingController();
  bool _loading = false;
  bool _enableField = true;
  String? _result;
  ResultCep? _resultOld;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _searchCepController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => {
              share(context,
                  'CEP: ${_resultOld!.cep}\nUF: ${_resultOld!.uf}\nLocalidade: ${_resultOld!.localidade}\nBairro: ${_resultOld!.bairro}\nLogradouro: ${_resultOld!.logradouro}\nDDD: ${_resultOld!.ddd}')
            },
            icon: const Icon(Icons.share),
          ),
        ],
        title: const Text('Consultar CEP'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildSearchCepButton(),
            _buildResultForm()
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCepTextField() {
    return Form(
      key: _formKey,
      child: TextFormField(
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: 'Cep'),
        controller: _searchCepController,
        enabled: _enableField,
        validator: (String? value) {
          bool notNumber = false;

          if (value != null && value.isEmpty) {
            return "Insira um CEP!";
          }

          for (int i = 0; i < value!.length; i++) {
            String v = value[i];
            if (v == '.' || v == ',' || v == '-') {
              notNumber = true;
              break;
            }
          }

          if (notNumber) {
            return "Digite apenas números!";
          } else if (value.length != 8) {
            return "O CEP precisa ter 8 digitos!";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        onPressed: _searchCep,
        child: _loading ? _circularLoading() : const Text('Consultar'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _searching(bool enable) {
    setState(() {
      _result = enable ? '' : _result;
      _loading = enable;
      _enableField = !enable;
    });
  }

  Widget _circularLoading() {
    return Container(
      height: 15.0,
      width: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  Future _searchCep() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _searching(true);

      final cep = _searchCepController.text;

      try {
        final resultCep = await ViaCepService.fetchCep(cep: cep);

        setState(() {
          _result = resultCep.toJson();
          _resultOld = resultCep;
        });
      } catch (e) {
        showTopSnackBar(context, "CEP inválido!");
      }

      _searching(false);
    }
  }

  Widget _buildResultForm() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(_result ?? ''),
    );
  }

  void showTopSnackBar(BuildContext context, String errorMessage) => Flushbar(
        icon: const Icon(Icons.error, size: 32, color: Colors.white),
        shouldIconPulse: false,
        title: "Erro",
        message: errorMessage,
        backgroundColor: Colors.red,
        padding: const EdgeInsets.all(24),
        borderRadius: 16,
        barBlur: 20,
        margin: const EdgeInsets.fromLTRB(8, kToolbarHeight + 8, 8, 8),
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      )..show(context);

  void share(BuildContext context, String body) {
    final RenderObject? box = context.findRenderObject();

    final String text = body;

    Share.share(text, subject: "");
  }
}
