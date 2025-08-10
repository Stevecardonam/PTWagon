
git clone https://github.com/flutter/flutter.git -b 3.22.2 --depth 1


export PATH="$PATH:`pwd`/flutter/bin"


flutter pub get


flutter build web --web-renderer=canvaskit --release