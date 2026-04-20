import 'dart:io';

void main() async {
  print('\n' + '=' * 50);
  print('🚀 Agente Interactivo: Subir proyecto a GitHub 🚀');
  print('=' * 50 + '\n');

  // 1. Pedir el link del repositorio
  stdout.write('1. Ingresa el link de tu nuevo repositorio en GitHub:\n> ');
  final repoLink = stdin.readLineSync()?.trim();

  if (repoLink == null || repoLink.isEmpty) {
    print('❌ Error: El link del repositorio es obligatorio. Saliendo...');
    return;
  }

  // 2. Pedir el mensaje del commit
  stdout.write('\n2. Ingresa el mensaje de tu commit (Qué cambios hiciste):\n> ');
  String? commitMessage = stdin.readLineSync()?.trim();

  if (commitMessage == null || commitMessage.isEmpty) {
    commitMessage = 'Primer commit / Actualización del proyecto';
    print('ℹ️  No se ingresó mensaje, se usará por defecto: "$commitMessage"');
  }

  // 3. Pedir la rama
  stdout.write('\n3. Ingresa el nombre de la rama (Presiona Enter para usar "main" por defecto):\n> ');
  String? branchName = stdin.readLineSync()?.trim();

  if (branchName == null || branchName.isEmpty) {
    branchName = 'main';
  }

  print('\n⏳ Preparando todo para subir a GitHub...\n');

  try {
    // Paso A: Inicializar git (por si no está inicializado)
    await runGitCommand(['init'], 'Inicializando git...');

    // Paso B: Agregar todos los archivos
    await runGitCommand(['add', '.'], 'Agregando archivos...');

    // Paso C: Hacer el commit
    // Ignoramos el error si no hay nada que hacer commit (nothing to commit)
    await runGitCommand(['commit', '-m', commitMessage], 'Creando commit...', ignoreErrorIfEmpty: true);

    // Paso D: Renombrar/Asegurar el nombre de la rama
    await runGitCommand(['branch', '-M', branchName], 'Configurando la rama principal como "$branchName"...');

    // Paso E: Configurar el remote 'origin'
    // Primero removemos el origin si ya existe para evitar errores y luego lo agregamos
    await Process.run('git', ['remote', 'remove', 'origin']);
    await runGitCommand(['remote', 'add', 'origin', repoLink], 'Enlazando con el repositorio remoto...');

    // Paso F: Push al repositorio
    print('\n🚀 Subiendo archivos a $repoLink en la rama "$branchName"... (Esto puede tardar un momento)');
    await runGitCommand(['push', '-u', 'origin', branchName], '');

    print('\n' + '=' * 50);
    print('✅ ¡ÉXITO! Tu proyecto ha sido subido correctamente a GitHub. 🎉');
    print('=' * 50 + '\n');

  } catch (e) {
    print('\n❌ Ocurrió un error inesperado al intentar subir el proyecto:');
    print(e);
  }
}

/// Función auxiliar para ejecutar comandos de Git y mostrar un mensaje amigable
Future<void> runGitCommand(List<String> arguments, String loadingMessage, {bool ignoreErrorIfEmpty = false}) async {
  if (loadingMessage.isNotEmpty) {
    print('-> $loadingMessage');
  }
  
  final result = await Process.run('git', arguments);
  
  if (result.exitCode != 0) {
    final output = result.stdout.toString() + result.stderr.toString();
    
    // Si es un commit y no hay cambios, Git devuelve un código de error. Lo ignoramos si es el caso.
    if (ignoreErrorIfEmpty && (output.contains('nothing to commit') || output.contains('nada para hacer commit'))) {
      print('   ℹ️ No hay archivos nuevos o modificados para hacer commit.');
      return;
    }
    
    throw Exception('Error ejecutando "git ${arguments.join(' ')}":\n$output');
  }
}
