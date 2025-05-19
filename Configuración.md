# Guía Rápida para tu ZSH en Termux

Esta guía te ayudará a aprovechar al máximo tu configuración ZSH mejorada en Termux.

## 🚀 Primeros Pasos

1. **Reinicia tu shell**: Después de implementar los cambios, ejecuta:
   ```
   source ~/.zshrc
   ```

2. **Configura Powerlevel10k**: Personaliza tu prompt ejecutando:
   ```
   p10k configure
   ```

3. **Instala dependencias necesarias**:
   ```
   pkg install fzf fd-find bat direnv lsd
   ```

## 🔥 Comandos y Características Principales

### Navegación Mejorada

| Comando | Descripción |
|---------|-------------|
| `..`    | Subir un directorio |
| `...`   | Subir dos directorios |
| `-`     | Volver al directorio anterior |
| `take nombre_dir` | Crear directorio y entrar en él |
| `z nombre_parcial` | Saltar a un directorio visitado frecuentemente |

### Listado de Archivos

| Comando | Descripción |
|---------|-------------|
| `ls`    | Listado mejorado con LSD |
| `ll`    | Listado detallado |
| `la`    | Mostrar archivos ocultos |
| `lt`    | Vista en árbol |
| `l.`    | Solo archivos ocultos |
| `las`   | Listar archivos Astro |
| `las directorio` | Listar archivos Astro en un directorio específico |

### Búsqueda

| Comando | Descripción |
|---------|-------------|
| `ff patrón` | Buscar archivos por nombre |
| `fd patrón` | Buscar directorios por nombre |
| `fe`    | Buscar y editar un archivo con FZF |
| `Ctrl+T` | Abrir selector de archivos FZF |
| `Ctrl+R` | Buscar en el historial con FZF |
| `Alt+C` | Cambiar a subdirectorios con FZF |

### Git Simplificado

| Comando | Descripción |
|---------|-------------|
| `gs`    | Estado del repositorio |
| `ga`    | Añadir cambios |
| `gc "mensaje"` | Commit con mensaje |
| `gp`    | Push a repositorio remoto |
| `gl`    | Pull desde repositorio remoto |
| `gd`    | Ver diferencias |
| `gco rama` | Cambiar de rama |
| `gb`    | Listar ramas |
| `glo`   | Log con gráfico |

### Utilidades

| Comando | Descripción |
|---------|-------------|
| `extract archivo` | Extraer cualquier archivo comprimido |
| `sysinfo` | Mostrar información del sistema |
| `bak archivo` | Crear respaldo de un archivo |
| `colors` | Mostrar colores disponibles |
| `pkg-menu` | Menú interactivo para gestionar paquetes |
| `h`     | Ver historial de comandos |

### Atajos de Teclado

| Atajo | Descripción |
|-------|-------------|
| `Tab` | Autocompletar (presiona dos veces para ver menu) |
| `Flecha Arriba/Abajo` | Navegar en historial con coincidencia |
| `Ctrl+Flecha Derecha/Izquierda` | Mover por palabras |
| `Alt+L` | Limpiar pantalla |
| `Shift+Tab` | Autocompletar en reversa |

## 🛠️ Personalización Adicional

### Personalizar Alias

Añade tus propios alias al final del archivo `.zshrc`:

```zsh
# Mis alias personalizados
alias miapp='cd ~/proyectos/mi-aplicacion && npm start'
alias editzsh='nano ~/.zshrc && source ~/.zshrc'
```

### Personalizar Colores de Archivos

Modifica los colores para tipos de archivos específicos:

```zsh
export LS_COLORS="*.vue=36:*.jsx=93:*.tsx=93:$LS_COLORS"
```

### Crear Funciones Personalizadas

Añade funciones para automatizar tareas específicas:

```zsh
# Ejemplo: Función para crear un proyecto JavaScript básico
create-js-project() {
  mkdir -p "$1"
  cd "$1"
  npm init -y
  mkdir -p src
  touch src/index.js
  echo "console.log('Hello World');" > src/index.js
  echo "Proyecto creado en $1"
}
```

## 🔄 Actualización y Mantenimiento

1. **Actualizar Oh-My-Zsh**:
   ```
   omz update
   ```

2. **Actualizar plugins personalizados**:
   ```
   cd ~/.plugins/zsh-syntax-highlighting && git pull
   cd ~/.plugins/zsh-autosuggestions && git pull
   ```

3. **Actualizar Powerlevel10k**:
   ```
   cd ~/powerlevel10k && git pull
   ```

4. **Limpiar historial de comandos**:
   ```
   history -c
   ```

## 📋 Sugerencias de Flujo de Trabajo

1. **Desarrollo Web**: Usa `las` para ver archivos Astro, `z` para navegar rápidamente entre proyectos, y los alias de git para gestionar versiones.

2. **Administración de Sistema**: Aprovecha `sysinfo` para monitorear el sistema, `pkg-menu` para gestionar paquetes y `extract` para manejar archivos.

3. **Exploración de Código**: Combina `fe` para abrir archivos rápidamente, `ff` para buscar archivos específicos, y `lt` para visualizar la estructura de directorios.

---

¡Disfruta de tu terminal potenciada! A medida que te familiarices con estas características, descubrirás que puedes trabajar mucho más rápido y eficientemente desde la línea de comandos
