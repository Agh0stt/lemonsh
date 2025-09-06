import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

void main() async {
  print("Welcome to lemonsh (type 'exit' to quit)");

  var binDir = Directory(".bin");
  if (!binDir.existsSync()) {
    binDir.createSync();
  }

  while (true) {
    stdout.write("lemonsh: \$ ");
    var input = stdin.readLineSync();
    if (input == null) continue;
    var parts = input.trim().split(" ");
    if (parts.isEmpty || parts[0].isEmpty) continue;

    var cmd = parts[0];
    var args = parts.sublist(1);

    if (cmd == "exit") {
      print("Goodbye!");
      break;
    }

    // === Lemon Package Manager ===
    else if (cmd == "lemon" && args.isNotEmpty) {
      var sub = args[0];
      if (sub == "install" && args.length > 1) {
        await lemonInstall(args[1], binDir.path);
      } else {
        print("Usage: lemon install <pkg>");
      }
    }

    // === Built-in commands ===
    else if (cmd == "ls") {
      var entries = Directory.current.listSync();
      for (var e in entries) {
        var name = e.uri.pathSegments.last;
        if (!name.startsWith(".")) print(name);
      }
    } else if (cmd == "cd" && args.isNotEmpty) {
      var newDir = Directory(args[0]);
      if (newDir.existsSync()) {
        Directory.current = newDir.path;
      } else {
        print("cd: no such directory: ${args[0]}");
      }
    } else if (cmd == "pwd") {
      print(Directory.current.path);
    } else if (cmd == "cat" && args.isNotEmpty) {
      var file = File(args[0]);
      if (file.existsSync()) {
        print(file.readAsStringSync());
      } else {
        print("cat: no such file: ${args[0]}");
      }
    } else if (cmd == "touch" && args.isNotEmpty) {
      File(args[0]).createSync();
    } else if (cmd == "rm" && args.isNotEmpty) {
      var file = File(args[0]);
      if (file.existsSync()) file.deleteSync();
    } else if (cmd == "mkdir" && args.isNotEmpty) {
      Directory(args[0]).createSync();
    } else if (cmd == "rmdir" && args.isNotEmpty) {
      var dir = Directory(args[0]);
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    } else if (cmd == "cp" && args.length > 1) {
      File(args[0]).copySync(args[1]);
    } else if (cmd == "mv" && args.length > 1) {
      File(args[0]).renameSync(args[1]);
    } else if (cmd == "echo" && args.isNotEmpty) {
      print(args.join(" "));
    } else if (cmd == "date") {
      print(DateTime.now().toString());
    } else if (cmd == "clear") {
      stdout.write("\x1B[2J\x1B[0;0H"); // ANSI clear
    } else if (cmd == "whoami") {
      print(Platform.environment["USER"] ?? "lemon_user");
    } else if (cmd == "head" && args.isNotEmpty) {
      var file = File(args[0]);
      if (file.existsSync()) {
        var lines = file.readAsLinesSync();
        lines.take(10).forEach(print);
      }
    } else if (cmd == "tail" && args.isNotEmpty) {
      var file = File(args[0]);
      if (file.existsSync()) {
        var lines = file.readAsLinesSync();
        lines.skip((lines.length - 10).clamp(0, lines.length)).forEach(print);
      }
    } else if (cmd == "wc" && args.isNotEmpty) {
      var file = File(args[0]);
      if (file.existsSync()) {
        var text = file.readAsStringSync();
        var lines = text.split("\n").length;
        var words = text.split(RegExp(r"\s+")).length;
        var chars = text.length;
        print("$lines $words $chars ${args[0]}");
      }
    } else if (cmd == "find" && args.isNotEmpty) {
      var search = args[0];
      Directory.current.listSync(recursive: true).forEach((e) {
        if (e.uri.pathSegments.last.contains(search)) print(e.path);
      });
    } else if (cmd == "chmod" && args.length > 1) {
      Process.runSync("chmod", [args[0], args[1]]);
    }

    // === Simple text editor ===
    else if (cmd == "edit" && args.isNotEmpty) {
      var file = File(args[0]);
      var buffer = <String>[];
      print("-- EDITING ${args[0]} (type ':wq' to save & quit, ':q!' to quit without saving) --");
      while (true) {
        var line = stdin.readLineSync();
        if (line == null) continue;
        if (line.trim() == ":wq") {
          file.writeAsStringSync(buffer.join("\n"));
          print("-- saved ${args[0]} --");
          break;
        } else if (line.trim() == ":q!") {
          print("-- quit without saving --");
          break;
        } else {
          buffer.add(line);
        }
      }
    }

    // === Run from .bin ===
    else {
      var binPath = "${binDir.path}/$cmd";
      if (File(binPath).existsSync()) {
        var result = await Process.start(binPath, args);
        await stdout.addStream(result.stdout);
        await stderr.addStream(result.stderr);
        await result.exitCode;
      } else {
        print("Unknown command: $cmd");
      }
    }
  }
}

Future<void> lemonInstall(String pkgName, String binDir) async {
  var statUrl = "github.com/Agh0stt/lemon-package-repo/releases/download/public/";
  var url = "https://$statUrl/$pkgName.tar.gz";

  print('''
===
lemon-package-manager 
Repository     : $statUrl
Package        : $pkgName
------------------------------
Resolving host : $statUrl ... OK
Connecting     : $statUrl ... connected
HTTP request   : sent, awaiting response...
''');

  print("Downloading package: $pkgName ...");

  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var archive = GZipDecoder().decodeBytes(response.bodyBytes);
    var tar = TarDecoder().decodeBytes(archive);

    for (var file in tar.files) {
      if (file.isFile) {
        var filePath = "$binDir/$pkgName";
        File(filePath).writeAsBytesSync(file.content as List<int>);
        Process.runSync("chmod", ["+x", filePath]);
      }
    }

    print('''
Extracting newly installed package : $pkgName.tar.gz
Installing package : $pkgName ... done
--------------------------------------
 Successfully installed: $pkgName
''');
  } else {
    print(" Failed to download package: $pkgName (HTTP ${response.statusCode})");
  }
}
