import 'package:esi_tfg_app/src/bloc/bloc.dart';
import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:esi_tfg_app/src/screens/login_screen.dart';
import 'package:esi_tfg_app/src/screens/registration_screen.dart';
import 'package:esi_tfg_app/src/screens/verification_email.dart';
import 'package:esi_tfg_app/src/screens/welcome_screen.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

Future<void> addDelay(int ms) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
}

Future<void> logout(WidgetTester tester) async {
  await addDelay(8000); 

  await tester.tap(find.byKey(
    const ValueKey('LogoutKey'),
  ));

  await addDelay(5000);
  tester.printToConsole('Welcome screen opens');
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // ignore: unnecessary_type_check
  if (binding is LiveTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  }

  group('end-to-end test', () {
     late NavigatorObserver mockObserver;

    setUp(() {
      mockObserver = MockNavigatorObserver();
    });

    final timeBasedEmail = '${DateTime.now().microsecondsSinceEpoch}@uclm.es'; 
    final scaffoldKey = GlobalKey<ScaffoldState>();
    testWidgets('Authentication Testing', (WidgetTester tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      await addDelay(2000);
      

      await tester.pumpWidget(
        Provider(
          create: (context) => Bloc(),
          child: MaterialApp(
            key: scaffoldKey,
            home: const WelcomeScreen(),
            navigatorObservers: [mockObserver],
            routes: <String, WidgetBuilder>{
              Home.routeName: (BuildContext context) => const Home(),
              WelcomeScreen.routeName: (BuildContext context) => const WelcomeScreen(),
              RegistrationScreen.routeName: (BuildContext context) => const RegistrationScreen(),
              VerifyEmail.routeName:  (BuildContext context) => const VerifyEmail(),
              LoginScreen.routeName: (BuildContext context) => const LoginScreen(),
            },
          )
        )
      );

      tester.printToConsole('Welcome screen opens');

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('emailSignUpOpener')));
      
      tester.printToConsole('SignUp screen opens');
      
      await tester.pumpAndSettle();
      
      expect(find.byType(RegistrationScreen), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('emailSignUpField')), timeBasedEmail);
      await addDelay(1000);

      await tester.tap(find.byType(PopupMenuButton<Menu>));
      await tester.pumpAndSettle();

      await addDelay(1000);

      await tester.tap(find.text('Profesor'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppButton));

      await addDelay(5000);
      await tester.pumpAndSettle(); 

      tester.printToConsole('Verification screen opens');

      expect(find.text('¡Bienvenido/a!'), findsOneWidget);

      await logout(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('emailSignInOpener')));
      
      tester.printToConsole('SignIn screen opens');
      await tester.pumpAndSettle();
      await addDelay(2000);

      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('emailSignInField')), "prueba9@uclm.es");
      await tester.enterText(find.byKey(const ValueKey('passwordSignInField')), "1Aaaaaaa");
      
      await tester.pumpAndSettle(); 
      await addDelay(2000);
      await tester.tap(find.byType(AppButton));

      await tester.pumpAndSettle(); 
      await addDelay(8000);
      tester.printToConsole('Home screen opens');

      await tester.dragFrom(tester.getTopLeft(find.byType(MaterialApp)), const Offset(300, 0));
      await tester.pumpAndSettle(); 
      await addDelay(2000);

      await tester.tap(find.text("Cerrar sesión"));
      await tester.pumpAndSettle(); 
      await addDelay(2000);
      
      tester.printToConsole('Welcome screen opens');
    });
  });
}
