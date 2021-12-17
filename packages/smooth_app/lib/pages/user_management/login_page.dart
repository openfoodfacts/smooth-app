import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_secured_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';

// TODO(Marvin): Autofill support
// TODO(Marvin): Handle colors better
// TODO(Marvin): internationalize everything
// TODO(Marvin): Validation
// TODO(Marvin): Darkmode

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color customGrey = Colors.grey;
  static const Color textFieldBackgroundColor =
      Color.fromARGB(255, 240, 240, 240);

  bool _hidePassword = true;
  bool _runningQuery = false;
  bool _wrongCredentials = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _wrongCredentials = false;
      setState(() => _runningQuery = true);

      final LocalDatabase localDatabase = context.read<LocalDatabase>();
      final DaoSecuredString daoSecuredString = DaoSecuredString(localDatabase);

      final User user = User(
        userId: userIdController.text,
        password: passwordController.text,
      );

      final bool login = await OpenFoodAPIClient.login(user);

      if (login) {
        _wrongCredentials = false;
        daoSecuredString.putUser(user);
        Navigator.pop(context, true);
      } else {
        _wrongCredentials = true;
      }

      setState(() => _runningQuery = false);
    }
  }

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: size.width * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(flex: 4),

                //Text
                Text(
                  'Sign in to your Open Food Facts account to save your contributions ',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline1?.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color:
                        themeProvider.darkTheme ? Colors.white : Colors.black,
                  ),
                ),

                const Spacer(flex: 8),

                if (_wrongCredentials) ...const <Widget>[
                  SmoothCard(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.red,
                    child: Text('Incorrect user name or password.'),
                  ),
                  Spacer(
                    flex: 1,
                  )
                ],

                //Login
                TextFormField(
                  controller: userIdController,
                  enabled: !_runningQuery,
                  textInputAction: TextInputAction.next, // Moves focus to next.
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    hintStyle: const TextStyle(
                      color: customGrey,
                      fontSize: 20.0,
                    ),
                    hintText: 'Login',
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 5.0,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                //Password
                TextFormField(
                  controller: passwordController,
                  enabled: !_runningQuery,
                  obscureText: _hidePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  textInputAction: TextInputAction.done, // Hides the keyboard
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    hintStyle: const TextStyle(
                      color: customGrey,
                      fontSize: 20.0,
                    ),
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.vpn_key),
                    suffixIcon: IconButton(
                      splashRadius: 10.0,
                      onPressed: () => setState(() {
                        _hidePassword = !_hidePassword;
                      }),
                      icon: const Icon(Icons.remove_red_eye),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 5.0,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 6),

                //Sign in button
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text(
                    'Sign in',
                    style: theme.textTheme.bodyText2?.copyWith(
                      fontSize: 18.0,
                      color:
                          themeProvider.darkTheme ? Colors.black : Colors.white,
                    ),
                  ),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                      Size(size.width * 0.5, theme.buttonTheme.height + 10),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(300.0),
                      ),
                    ),
                  ),
                ),

                //Forgot password
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password',
                    style: theme.textTheme.bodyText2?.copyWith(
                      fontSize: 18.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

                const Spacer(flex: 4),

                //Open register page
                SizedBox(
                  height: size.height * 0.06,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(
                      'Create account',
                      style: theme.textTheme.bodyText2?.copyWith(
                        fontSize: 18.0,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        BorderSide(color: theme.primaryColor, width: 2.0),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(size.width * 0.5, theme.buttonTheme.height),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(300.0),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
