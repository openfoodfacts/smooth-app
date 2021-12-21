import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';
import 'package:smooth_ui_library/widgets/smooth_text_form_field.dart';

// TODO(M123-dev): Autofill support
// TODO(M123-dev): Handle colors better
// TODO(M123-dev): internationalize everything
// TODO(M123-dev): Better validation

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color customGrey = Colors.grey;
  static Color textFieldBackgroundColor =
      const Color.fromARGB(255, 240, 240, 240);

  bool _runningQuery = false;
  bool _wrongCredentials = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _runningQuery = true;
      _wrongCredentials = false;
    });

    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final bool login =
        await UserManagementHelper(localDatabase: localDatabase).smoothieLogin(
      User(
        userId: userIdController.text,
        password: passwordController.text,
      ),
    );

    if (login) {
      Navigator.pop(context);
    } else {
      setState(() {
        _runningQuery = false;
        _wrongCredentials = true;
      });
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

    // Needs to be changed
    if (themeProvider.darkTheme) {
      textFieldBackgroundColor = Colors.white10;
    }

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

                Text(
                  'Sign in to your Open Food Facts account to save your contributions ',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline1?.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
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
                SmoothTextFormField(
                  type: TextFieldTypes.PLAIN_TEXT,
                  controller: userIdController,
                  hintText: 'Login',
                  textColor: customGrey,
                  backgroundColor: textFieldBackgroundColor,
                  prefixIcon: const Icon(Icons.person),
                  enabled: !_runningQuery,
                  textInputAction: TextInputAction.next, // Moves focus to next.
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),

                const Spacer(flex: 1),

                //Password
                SmoothTextFormField(
                  type: TextFieldTypes.PASSWORD,
                  controller: passwordController,
                  hintText: 'Password',
                  textColor: customGrey,
                  backgroundColor: textFieldBackgroundColor,
                  prefixIcon: const Icon(Icons.vpn_key),
                  enabled: !_runningQuery,
                  textInputAction: TextInputAction.done, // Hides the keyboard
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),

                const Spacer(flex: 6),

                //Sign in button
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text(
                    'Sign in',
                    style: theme.textTheme.bodyText2?.copyWith(
                      fontSize: 18.0,
                      color: theme.colorScheme.onSurface,
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
                  onPressed: () {
                    const SnackBar snackBar = SnackBar(
                      content: Text('Not implemented yet'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
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
                    onPressed: () {
                      const SnackBar snackBar = SnackBar(
                        content: Text('Not implemented yet'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
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
