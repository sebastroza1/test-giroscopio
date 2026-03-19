# Integración Huawei pendiente para sensores del reloj

## Qué ya funciona
- detectar si el teléfono tiene Bluetooth
- verificar permisos Android para Bluetooth
- detectar si hay un reloj Huawei emparejado por nombre Bluetooth
- reflejar ese estado dentro de la app
- incluir en Android la dependencia HMS base de **Wear Engine** y dejar documentada la ruta oficial para Health Kit
- exponer `com.huawei.hms.client.appid` mediante `manifestPlaceholders`

## Qué todavía no funciona
Este repo todavía no lee datos remotos de:
- giroscopio del reloj
- acelerómetro del reloj
- ritmo cardiaco del reloj

La razón principal es que todavía **no existe la lógica nativa** que:
- abra los clientes de Wear Engine (y luego, si se reintegra, Health Kit)
- autorice al usuario contra Huawei
- se suscriba a sensores/datos remotos
- empuje muestras reales hacia Flutter mediante `EventChannel`

## Qué se integró ahora en el proyecto
En Android ya quedaron añadidos:
- repositorio Maven de Huawei
- dependencia `com.huawei.hms:wearengine:5.0.0.300`
- ruta BLE/GATT para Heart Rate estándar (`0x180D` / `0x2A37`)
- `meta-data` de `com.huawei.hms.client.appid`
- validación nativa para avisar si el `appid` sigue sin configurarse
- actualización de AGP/Kotlin/Gradle wrapper para alinearlo mejor con los avisos actuales de Flutter

## Qué te falta configurar en tu máquina
1. Crear/configurar la app en **AppGallery Connect**.
2. Obtener el **APP ID** real de Huawei.
3. Reemplazar `huaweiAppId=0` en `android/gradle.properties` por el APP ID real.
4. Agregar el archivo `agconnect-services.json` en `android/app/` si tu flujo HMS lo requiere.
5. Tener HMS Core y Huawei Health instalados/actualizados en el teléfono Huawei usado para pruebas.
6. Seguir el codelab oficial de Health Kit para reintroducir esa dependencia con una versión HMS realmente válida en tu entorno Huawei.
7. Implementar la lógica nativa que abra Wear Engine / Health Kit desde Android.
8. Completar la autenticación/autorización Huawei necesaria desde código nativo.
9. Implementar la suscripción real a sensores/eventos del wearable y enviarlos a Flutter por `EventChannel`.

## Por qué todavía pueden salir `-`
Aunque el proyecto ya quedó preparado con dependencias Huawei, el reloj no empezará a mandar datos solo por agregar librerías.
Todavía hace falta:
- configuración AGC/HMS válida
- lógica nativa Android que abra Wear Engine y Health Kit
- autenticación/autorización del usuario con Huawei
- listeners que conviertan los datos a los streams actuales de Flutter

## Referencias oficiales
- Wear Engine: https://developer.huawei.com/consumer/en/codelab/WearEngine/
- Wear Engine product page: https://developer.huawei.com/consumer/en/hms/huawei-wearengine/
- Health Kit: https://developer.huawei.com/consumer/en/codelab/HUAWEIHiHealthCore/

## Extracción real ya intentada en este repo
- el proveedor `ble_generic` ahora intenta conectarse por GATT a un reloj Huawei emparejado
- se suscribe al servicio estándar **Heart Rate Measurement** (`0x180D` / `0x2A37`)
- si el reloj expone ese servicio por BLE, la app puede empezar a recibir BPM reales en Flutter
- acelerómetro y giroscopio del reloj siguen pendientes porque normalmente requieren características vendor-specific o una integración más profunda con Wear Engine


## Cómo se “expone” Heart Rate Measurement
No se expone desde Flutter ni desde la app del teléfono.
Lo tiene que exponer el **firmware del reloj** como servicio GATT estándar (`0x180D` / `0x2A37`).
La app del teléfono solo puede:
- conectarse al reloj por BLE
- descubrir sus servicios GATT
- suscribirse si encuentra el servicio estándar

Si el reloj no publica ese servicio, no hay nada que “activar” desde la app del teléfono para forzarlo.

## Sobre el giroscopio del reloj
Según la página oficial de Wear Engine, la gestión de sensores del wearable menciona acelerómetro y ECG/PPG para FC, pero no un servicio estándar de giroscopio desde BLE.
Por eso, para que el giroscopio del reloj funcione de verdad, normalmente hace falta una de estas dos cosas:
- una API oficial específica de Huawei que exponga ese sensor
- o conocer y suscribirse a una característica GATT propietaria del reloj

Con el diagnóstico BLE añadido en este repo, si el reloj se conecta y no aparece Heart Rate estándar, al menos podrás ver qué servicios GATT publica realmente para seguir la integración.


## Nota sobre Health Kit oficial
El codelab oficial de Huawei Health Kit muestra una ruta de integración basada en `hihealth-base:{version}`, autenticación Huawei ID y `SensorsController`, además de requisitos explícitos de teléfono Huawei/HMS Core y configuración AGC.
Este repo no deja esa dependencia activada por defecto porque, en tu entorno actual, estaba rompiendo el build durante la resolución de artefactos.
