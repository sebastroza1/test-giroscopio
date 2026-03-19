# Integración Huawei pendiente para sensores del reloj

## Qué ya funciona
- detectar si el teléfono tiene Bluetooth
- verificar permisos Android para Bluetooth
- detectar si hay un reloj Huawei emparejado por nombre Bluetooth
- reflejar ese estado dentro de la app
- incluir en Android las dependencias HMS base de **Wear Engine**, **Health Kit** y **Huawei ID**
- exponer `com.huawei.hms.client.appid` mediante `manifestPlaceholders`

## Qué todavía no funciona
Este repo todavía no lee datos remotos de:
- giroscopio del reloj
- acelerómetro del reloj
- ritmo cardiaco del reloj

## Qué se integró ahora en el proyecto
En Android ya quedaron añadidos:
- repositorio Maven de Huawei
- dependencia `com.huawei.hms:wearengine:5.0.0.300`
- dependencia `com.huawei.hms:hihealth-base:+`
- dependencia `com.huawei.hms:hwid:+`
- `meta-data` de `com.huawei.hms.client.appid`
- validación nativa para avisar si el `appid` sigue sin configurarse
- actualización de AGP/Kotlin/Gradle wrapper para alinearlo mejor con los avisos actuales de Flutter

## Qué te falta configurar en tu máquina
1. Crear/configurar la app en **AppGallery Connect**.
2. Obtener el **APP ID** real de Huawei.
3. Reemplazar `huaweiAppId=0` en `android/gradle.properties` por el APP ID real.
4. Agregar el archivo `agconnect-services.json` en `android/app/` si tu flujo HMS lo requiere.
5. Tener HMS Core y Huawei Health instalados/actualizados en el teléfono Huawei usado para pruebas.
6. Validar en tu máquina qué versiones exactas resolvió Gradle para `hihealth-base` y `hwid` desde el repo de Huawei.
7. Completar la autenticación/autorización Huawei necesaria desde código nativo.
8. Implementar la suscripción real a sensores/eventos del wearable y enviarlos a Flutter por `EventChannel`.

## Por qué todavía pueden salir `-`
Aunque el proyecto ya quedó preparado con dependencias Huawei, el reloj no empezará a mandar datos solo por agregar librerías.
Todavía hace falta:
- autorización del usuario
- configuración AGC/HMS válida
- código nativo que abra los clientes de Wear Engine y Health Kit
- listeners que conviertan los datos a los streams actuales de Flutter

## Referencias oficiales
- Wear Engine: https://developer.huawei.com/consumer/en/codelab/WearEngine/
- Wear Engine product page: https://developer.huawei.com/consumer/en/hms/huawei-wearengine/
- Health Kit: https://developer.huawei.com/consumer/en/codelab/HUAWEIHiHealthCore/
