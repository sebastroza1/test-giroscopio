# Integración Huawei pendiente para sensores del reloj

## Qué ya funciona
- detectar si el teléfono tiene Bluetooth
- verificar permisos Android para Bluetooth
- detectar si hay un reloj Huawei emparejado por nombre Bluetooth
- reflejar ese estado dentro de la app

## Qué todavía no funciona
Este repo todavía no lee datos remotos de:
- giroscopio del reloj
- acelerómetro del reloj
- ritmo cardiaco del reloj

## Por qué
El emparejamiento Bluetooth del sistema operativo **no expone automáticamente** los sensores internos del reloj a una app Flutter.

Para eso hace falta integrar una de estas rutas oficiales de Huawei:
- **Wear Engine**, que según Huawei expone gestión de sensores del wearable y estado de salud/fitness
- **Health Kit**, para leer datos de salud/actividad autorizados por el usuario a través del ecosistema Huawei Health

## Qué falta implementar en este proyecto
1. Añadir dependencias nativas de Huawei HMS.
2. Configurar proyecto Huawei/AppGallery Connect si la ruta elegida lo exige.
3. Autenticar y autorizar el acceso a datos del usuario.
4. Suscribirse a los sensores/datos soportados por el SDK elegido.
5. Convertir esos callbacks nativos a `EventChannel` para Flutter.

## Importante
Si el reloj aparece como conectado pero las tarjetas siguen en `-`, eso no significa que el reloj esté mal emparejado.
Significa que la capa de lectura de sensores Huawei aún no existe dentro de este código.

## Referencias oficiales
- Wear Engine: https://developer.huawei.com/consumer/en/hms/huawei-wearengine
- Health Kit: https://developer.huawei.com/consumer/en/hms/huaweihealth/
