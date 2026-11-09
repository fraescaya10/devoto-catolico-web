# Capturas de pantalla

Esta carpeta está vacía a propósito: las capturas se exportan desde el lienzo de Claude Design ("Diseño app de oraciones"), porque solo ahí se renderizan las pantallas.

## Cómo exportarlas

1. Abre el diseño y cada pantalla en ventana completa.
2. Exporta una imagen (PNG) desde el menú de compartir/exportar del diseño.
3. Hazlo en dos anchos: **1440 px** (escritorio) y **390 px** (móvil). En móvil, angosta la ventana antes de exportar.
4. Guárdalas con el mismo nombre que su archivo en `screens/`, más el sufijo de ancho.

## Nombres esperados

| Pantalla | Escritorio | Móvil |
|---|---|---|
| `publico/inicio` | `publico-inicio-desktop.png` | `publico-inicio-mobile.png` |
| `publico/oraciones` | `publico-oraciones-desktop.png` | `publico-oraciones-mobile.png` |
| `publico/lectura` | `publico-lectura-desktop.png` | `publico-lectura-mobile.png` |
| `publico/novenas` | `publico-novenas-desktop.png` | `publico-novenas-mobile.png` |
| `publico/novena` | `publico-novena-desktop.png` | `publico-novena-mobile.png` |
| `publico/rosarios` | `publico-rosarios-desktop.png` | `publico-rosarios-mobile.png` |
| `publico/rosario` | `publico-rosario-desktop.png` | `publico-rosario-mobile.png` |
| `cuenta/registro` | `cuenta-registro-desktop.png` | `cuenta-registro-mobile.png` |
| `cuenta/ingresar` | `cuenta-ingresar-desktop.png` | `cuenta-ingresar-mobile.png` |
| `cuenta/recuperar` | `cuenta-recuperar-desktop.png` | `cuenta-recuperar-mobile.png` |
| `panel/inicio` | `panel-inicio-desktop.png` | `panel-inicio-mobile.png` |
| `panel/oraciones` | `panel-oraciones-desktop.png` | `panel-oraciones-mobile.png` |
| `panel/oracion-editar` | `panel-oracion-editar-desktop.png` | `panel-oracion-editar-mobile.png` |
| `panel/oracion-publicada` | `panel-oracion-publicada-desktop.png` | `panel-oracion-publicada-mobile.png` |
| `panel/secuencias` | `panel-secuencias-desktop.png` | — |
| `panel/secuencia-editar` | `panel-secuencia-editar-desktop.png` | `panel-secuencia-editar-mobile.png` |
| `panel/novenas` | `panel-novenas-desktop.png` | — |
| `panel/novena-editar` | `panel-novena-editar-desktop.png` | `panel-novena-editar-mobile.png` |
| `panel/revision` | `panel-revision-desktop.png` | `panel-revision-mobile.png` |
| `panel/usuarios` | `panel-usuarios-desktop.png` | — |
| `fundamentos` | `fundamentos.png` | — |

**Estados que conviene capturar aparte** (son los que más ayudan al agente):

| Estado | Archivo |
|---|---|
| Editor con el panel de solicitud abierto y el aviso de duplicado | `panel-oracion-editar-solicitud-desktop.png` |
| Cola de revisión con el formulario de rechazo abierto | `panel-revision-rechazo-desktop.png` |
| Rosario en modo oscuro | `publico-rosario-oscuro-mobile.png` |
| Ingresar con "sesión expirada" | `cuenta-ingresar-expirada-desktop.png` |
| Registro con errores de validación | `cuenta-registro-errores-mobile.png` |
