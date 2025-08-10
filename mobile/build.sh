
git clone https://github.com/flutter/flutter.git -b 3.22.2 --depth 1


export PATH="$PATH:`pwd`/flutter/bin"


flutter pub get#!/bin/sh

# Asegúrate de que los comandos se ejecuten en la carpeta correcta
cd mobile

# Clona la versión de Flutter recomendada para el Dart SDK
git clone https://github.com/flutter/flutter.git -b 3.22.8 --depth 1

# Exporta el path del SDK para que el shell lo reconozca
export PATH="$PATH:`pwd`/flutter/bin"

# Instala las dependencias de Flutter
flutter pub get

# Compila la aplicación para web
flutter build web --web-renderer=canvaskit --release


flutter build web --web-renderer=canvaskit --release