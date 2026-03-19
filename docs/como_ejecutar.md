# Cómo ejecutar el proyecto (Windows)

Este repo empezó sin la estructura completa de plataformas Flutter.
Para que `flutter run` y `flutter build apk` funcionen, haz estos pasos en tu máquina:

## 1) Regenerar archivos de plataforma
Desde la raíz del proyecto:

```bash
flutter create .
```

> Esto crea los archivos faltantes de Android (gradle wrapper, etc.) y también web/windows si quieres.

## 2) Obtener dependencias

```bash
flutter pub get
```

## 3) Verificar dispositivo Android

```bash
flutter devices
```

Debes ver un teléfono físico o un emulador Android. Si no aparece:
- abre Android Studio
- inicia un emulador (AVD Manager)
- o conecta un teléfono con depuración USB activa

## 4) Ejecutar en Android

```bash
flutter run -d <device_id>
```

Ejemplo:

```bash
flutter run -d emulator-5554
```

## 5) Generar APK release

```bash
flutter build apk --release
```

APK de salida:
- `build/app/outputs/flutter-apk/app-release.apk`

## Nota sobre tu error de "No supported devices connected"
Ese error salió porque intentaste correr sin dispositivo Android activo.
Windows/Chrome aparecían, pero tu proyecto en ese momento no tenía esas plataformas generadas.

## Troubleshooting: reloj conectado pero no detectado
Si ves el reloj emparejado en Bluetooth del teléfono pero la app no lo detecta:

1. Acepta permisos al abrir la app (Bluetooth, ubicación y sensores).
2. En Android 12+ verifica manualmente:
   - Ajustes > Apps > ACV Motion Monitor > Permisos
   - habilita **Dispositivos cercanos** y **Ubicación**.
3. Pulsa **Conectar reloj** dentro de la app para refrescar estado.
4. Si sigue sin detectarse, desactiva/activa Bluetooth del teléfono y vuelve a abrir la app.

## Troubleshooting: el reloj sí conecta pero los sensores siguen en `-`
Eso actualmente es esperado con este código.

La app ya puede:
- detectar que hay un reloj Huawei emparejado por Bluetooth
- mostrar el estado de conexión dentro de la tarjeta principal

Pero todavía **no** puede:
- leer giroscopio del reloj
- leer acelerómetro del reloj
- leer ritmo cardiaco del reloj

### Por qué pasa
En este repo todavía no existe integración real con:
- **Huawei Health Kit / HMS** para Huawei Watch / Watch Fit
- o un flujo BLE/GATT específico con UUIDs reales del dispositivo

Emparejar el reloj en Bluetooth **no basta** para recibir sensores. Hace falta integrar el SDK/canal de datos correcto del fabricante.

### Qué debes esperar ahora mismo
- `Conectar reloj`: puede mostrar el Huawei como detectado
- `Iniciar sensores reloj`: ahora mostrará un mensaje indicando que la integración remota aún no está implementada
- tarjetas de `Reloj - Giroscopio`, `Reloj - Acelerómetro` y `Reloj - Ritmo cardiaco`: seguirán mostrando `-` hasta que se haga esa integración
