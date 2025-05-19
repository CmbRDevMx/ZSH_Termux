#!/data/data/com.termux/files/usr/bin/bash

# Termux Backup & Restore CLI
# Versión: 1.0
# Un script profesional para gestionar backups y restauraciones en Termux

# Colores
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
BOLD="\e[1m"
RESET="\e[0m"

# Banner
show_banner() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo '╔════════════════════════════════════════════════════════╗'
    echo '╚════════════════════════════════════════════════════════╝'
    echo -e "${RESET}"
    echo -e "${BOLD}${MAGENTA}        Backup & Restore${RESET}"
    echo -e "${YELLOW}        website: https://termux.app${RESET}"
    echo ""
}

# Función para animar el spinner de carga
loading_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    echo -e "\n"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "${CYAN} [%c] ${RESET} Procesando..." "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r"
    done
    printf "                              \r"
}

# Verificar si los directorios existen
check_directory() {
    if [ ! -d "$1" ]; then
        echo -e "${RED}Error: El directorio $1 no existe.${RESET}"
        exit 1
    fi
}

# Verificar permisos de escritura
check_write_permission() {
    if [ ! -w "$1" ]; then
        echo -e "${RED}Error: No tienes permisos de escritura en $1.${RESET}"
        exit 1
    fi
}

# Verificar espacio disponible
check_available_space() {
    local required_space=$1
    local available_space=$(df -P "$2" | awk 'NR==2 {print $4}')
    
    if [ $available_space -lt $required_space ]; then
        echo -e "${RED}Error: No hay suficiente espacio disponible.${RESET}"
        echo -e "${YELLOW}Espacio requerido: $(($required_space/1024)) MB${RESET}"
        echo -e "${YELLOW}Espacio disponible: $(($available_space/1024)) MB${RESET}"
        exit 1
    fi
}

# Crear backup
create_backup() {
    show_banner
    echo -e "${BOLD}${GREEN}✅ CREAR BACKUP DE TERMUX${RESET}\n"
    
    # Obtener la ruta base
    local base_dir="$PREFIX/.."
    check_directory "$base_dir"
    
    # Mostrar tamaño aproximado del backup
    local size=$(du -s "$base_dir/home" "$base_dir/usr" 2>/dev/null | awk '{sum+=$1} END {print sum}')
    echo -e "${CYAN}📊 Tamaño estimado del backup: ${YELLOW}$(($size/1024)) MB${RESET}\n"
    
    # Solicitar ubicación de destino
    echo -e "${BOLD}${WHITE}¿Dónde desea guardar el backup?${RESET}"
    echo -e "${CYAN}1) ${WHITE}/sdcard/ (Almacenamiento interno)${RESET}"
    echo -e "${CYAN}2) ${WHITE}Especificar otra ubicación${RESET}"
    echo -e "${CYAN}3) ${WHITE}Cancelar${RESET}"
    echo -n -e "${BOLD}${YELLOW}Seleccione una opción [1-3]: ${RESET}"
    read -r option
    
    case $option in
        1)
            backup_path="/sdcard/termux-backup_$(date +%Y%m%d_%H%M%S).tar.gz"
            ;;
        2)
            echo -n -e "${BOLD}${YELLOW}Ingrese la ruta completa (incluyendo nombre del archivo): ${RESET}"
            read -r backup_path
            ;;
        3)
            echo -e "${YELLOW}Operación cancelada.${RESET}"
            return
            ;;
        *)
            echo -e "${RED}Opción inválida. Operación cancelada.${RESET}"
            return
            ;;
    esac
    
    # Verificar permisos y espacio
    local backup_dir=$(dirname "$backup_path")
    check_directory "$backup_dir"
    check_write_permission "$backup_dir"
    check_available_space $((size*2)) "$backup_dir"
    
    echo -e "\n${CYAN}📦 Creando backup en: ${YELLOW}$backup_path${RESET}"
    echo -e "${BLUE}📋 Archivos incluidos: ${WHITE}/home y /usr${RESET}"
    echo -e "${MAGENTA}⏳ Este proceso puede tardar varios minutos...${RESET}\n"
    
    # Crear backup en segundo plano y mostrar spinner
    tar -zcf "$backup_path" -C "$base_dir" home usr &
    loading_spinner $!
    
    # Verificar si el backup se creó correctamente
    if [ -f "$backup_path" ]; then
        local final_size=$(du -h "$backup_path" | cut -f1)
        echo -e "\n${BOLD}${GREEN}✅ Backup completado exitosamente${RESET}"
        echo -e "${CYAN}📍 Ubicación: ${YELLOW}$backup_path${RESET}"
        echo -e "${CYAN}📊 Tamaño del archivo: ${YELLOW}$final_size${RESET}"
        echo -e "${MAGENTA}💡 Guarde este archivo en un lugar seguro para futuras restauraciones${RESET}\n"
    else
        echo -e "\n${RED}❌ Error al crear el backup. Por favor, intente nuevamente.${RESET}\n"
    fi
}

# Restaurar backup
restore_backup() {
    show_banner
    echo -e "${BOLD}${GREEN}🔄 RESTAURAR BACKUP DE TERMUX${RESET}\n"
    echo -e "${RED}${BOLD}⚠️  ADVERTENCIA: Este proceso sobrescribirá los archivos actuales.${RESET}\n"
    
    # Opciones para seleccionar el archivo de backup
    echo -e "${BOLD}${WHITE}¿Dónde está ubicado su archivo de backup?${RESET}"
    echo -e "${CYAN}1) ${WHITE}/sdcard/ (Almacenamiento interno)${RESET}"
    echo -e "${CYAN}2) ${WHITE}Especificar otra ubicación${RESET}"
    echo -e "${CYAN}3) ${WHITE}Cancelar${RESET}"
    echo -n -e "${BOLD}${YELLOW}Seleccione una opción [1-3]: ${RESET}"
    read -r option
    
    local backup_path
    case $option in
        1)
            echo -e "\n${BOLD}${WHITE}Archivos de backup disponibles en /sdcard/:${RESET}"
            
            # Listar archivos tar.gz en /sdcard/
            local files=($(find /sdcard/ -maxdepth 1 -name "*.tar.gz" | sort -r))
            
            if [ ${#files[@]} -eq 0 ]; then
                echo -e "${RED}No se encontraron archivos de backup (.tar.gz) en /sdcard/${RESET}\n"
                return
            fi
            
            for i in "${!files[@]}"; do
                local file_size=$(du -h "${files[$i]}" | cut -f1)
                local file_date=$(date -r "${files[$i]}" "+%d/%m/%Y %H:%M")
                echo -e "${CYAN}$((i+1))) ${WHITE}$(basename "${files[$i]}") ${YELLOW}[$file_size - $file_date]${RESET}"
            done
            
            echo -e "${CYAN}$((${#files[@]}+1))) ${WHITE}Cancelar${RESET}"
            echo -n -e "\n${BOLD}${YELLOW}Seleccione un archivo [1-$((${#files[@]}+1))]: ${RESET}"
            read -r file_option
            
            if [ "$file_option" -eq "$((${#files[@]}+1))" ]; then
                echo -e "${YELLOW}Operación cancelada.${RESET}"
                return
            elif [ "$file_option" -ge 1 ] && [ "$file_option" -le "${#files[@]}" ]; then
                backup_path="${files[$((file_option-1))]}"
            else
                echo -e "${RED}Opción inválida. Operación cancelada.${RESET}"
                return
            fi
            ;;
        2)
            echo -n -e "${BOLD}${YELLOW}Ingrese la ruta completa del archivo de backup: ${RESET}"
            read -r backup_path
            ;;
        3)
            echo -e "${YELLOW}Operación cancelada.${RESET}"
            return
            ;;
        *)
            echo -e "${RED}Opción inválida. Operación cancelada.${RESET}"
            return
            ;;
    esac
    
    # Verificar que el archivo exista
    if [ ! -f "$backup_path" ]; then
        echo -e "\n${RED}❌ Error: El archivo $backup_path no existe.${RESET}\n"
        return
    fi
    
    # Confirmación final
    echo -e "\n${BOLD}${RED}⚠️  ADVERTENCIA FINAL:${RESET}"
    echo -e "${RED}Esta operación sobrescribirá todos los archivos actuales en Termux.${RESET}"
    echo -e "${RED}Asegúrese de cerrar todas las demás sesiones de Termux.${RESET}"
    echo -e "${YELLOW}El proceso no se puede cancelar una vez iniciado.${RESET}\n"
    echo -n -e "${BOLD}${YELLOW}¿Está seguro de continuar? (s/N): ${RESET}"
    read -r confirm
    
    if [ "$confirm" != "s" ] && [ "$confirm" != "S" ]; then
        echo -e "${YELLOW}Operación cancelada.${RESET}"
        return
    fi
    
    # Proceder con la restauración
    echo -e "\n${CYAN}🔄 Restaurando desde: ${YELLOW}$backup_path${RESET}"
    echo -e "${MAGENTA}⏳ Este proceso puede tardar varios minutos...${RESET}\n"
    
    # Restaurar backup en segundo plano y mostrar spinner
    tar -zxf "$backup_path" -C "$PREFIX/.." --recursive-unlink --preserve-permissions &
    loading_spinner $!
    
    echo -e "\n${BOLD}${GREEN}✅ Restauración completada exitosamente${RESET}"
    echo -e "${MAGENTA}💡 Se recomienda reiniciar Termux para aplicar todos los cambios${RESET}\n"
    echo -e "${BOLD}${YELLOW}Presione enter para continuar...${RESET}"
    read -r
}

# Función para mostrar información del sistema
show_system_info() {
    show_banner
    echo -e "${BOLD}${GREEN}ℹ️  INFORMACIÓN DEL SISTEMA${RESET}\n"
    
    # Información de Termux
    echo -e "${CYAN}📱 ${BOLD}Información de Termux:${RESET}"
    echo -e "${WHITE}   • Compatibilidad: ${YELLOW}$(if [ "$(getprop ro.product.cpu.abi)" = "arm64-v8a" ] || [ "$(getprop ro.product.cpu.abi)" = "x86_64" ]; then echo "Sistema de 64 bits"; elif [ "$(getprop ro.product.cpu.abilist)" = *"arm64-v8a"* ] || [ "$(getprop ro.product.cpu.abilist)" = *"x86_64"* ]; then echo "Sistema de 64 bits con compatibilidad de 32 bits"; else echo "Sistema de 32 bits"; fi)${RESET}"
    echo -e "${WHITE}   • Directorio base: ${YELLOW}$PREFIX/..${RESET}"
    echo -e "${WHITE}   • Directorio de aplicaciones: ${YELLOW}$PREFIX${RESET}"
    echo -e "${WHITE}   • Directorio home: ${YELLOW}$HOME${RESET}"
    
    # Información de almacenamiento
    echo -e "\n${CYAN}💾 ${BOLD}Espacio de almacenamiento:${RESET}"
    local termux_size=$(du -sh "$PREFIX/.." 2>/dev/null | cut -f1)
    local home_size=$(du -sh "$HOME" 2>/dev/null | cut -f1)
    local usr_size=$(du -sh "$PREFIX" 2>/dev/null | cut -f1)
    echo -e "${WHITE}   • Tamaño total de Termux: ${YELLOW}$termux_size${RESET}"
    echo -e "${WHITE}   • Tamaño de /home: ${YELLOW}$home_size${RESET}"
    echo -e "${WHITE}   • Tamaño de /usr: ${YELLOW}$usr_size${RESET}"
    
    # Información del sistema operativo
    echo -e "\n${CYAN}🧠 ${BOLD}Información del sistema:${RESET}"
    echo -e "${WHITE}   • Arquitectura: ${YELLOW}$(uname -m)${RESET}"
    echo -e "${WHITE}   • Kernel: ${YELLOW}$(uname -r)${RESET}"
    echo -e "${WHITE}   • Android: ${YELLOW}$(getprop ro.build.version.release 2>/dev/null || echo "No disponible")${RESET}"
    
    echo -e "\n${BOLD}${YELLOW}Presione enter para continuar...${RESET}"
    read -r
}

# Ayuda y documentación
show_help() {
    show_banner
    echo -e "${BOLD}${GREEN}❓ AYUDA Y DOCUMENTACIÓN${RESET}\n"
    
    echo -e "${CYAN}📚 ${BOLD}Descripción:${RESET}"
    echo -e "${WHITE}   Este script profesional facilita la gestión de backups y restauraciones"
    echo -e "${WHITE}   completas del entorno Termux, incluyendo aplicaciones y datos personales.${RESET}"
    
    echo -e "\n${CYAN}🛠️  ${BOLD}Funciones principales:${RESET}"
    echo -e "${WHITE}   • Crear backup completo ${YELLOW}(/home y /usr)${RESET}"
    echo -e "${WHITE}   • Restaurar backup existente${RESET}"
    echo -e "${WHITE}   • Visualizar información del sistema${RESET}"
    
    echo -e "\n${CYAN}💡 ${BOLD}Consejos:${RESET}"
    echo -e "${WHITE}   1. Realice backups periódicos para evitar pérdida de datos${RESET}"
    echo -e "${WHITE}   2. Almacene sus backups en un lugar seguro (nube, tarjeta SD, etc.)${RESET}"
    echo -e "${WHITE}   3. Antes de restaurar, cierre todas las demás sesiones de Termux${RESET}"
    echo -e "${WHITE}   4. Reinicie Termux después de una restauración${RESET}"
    
    echo -e "\n${CYAN}⚠️  ${BOLD}Advertencias:${RESET}"
    echo -e "${WHITE}   • La restauración sobrescribirá TODOS los archivos actuales${RESET}"
    echo -e "${WHITE}   • Es recomendable realizar una copia de seguridad antes de restaurar${RESET}"
    echo -e "${WHITE}   • Asegúrese de tener suficiente espacio disponible${RESET}"
    
    echo -e "\n${BOLD}${YELLOW}Presione enter para continuar...${RESET}"
    read -r
}

# Función principal - Menú
main_menu() {
    while true; do
        show_banner
        echo -e "${BOLD}${WHITE}MENÚ PRINCIPAL${RESET}\n"
        echo -e "${CYAN}1) ${WHITE}Crear backup${RESET}"
        echo -e "${CYAN}2) ${WHITE}Restaurar backup${RESET}"
        echo -e "${CYAN}3) ${WHITE}Información del sistema${RESET}"
        echo -e "${CYAN}4) ${WHITE}Ayuda y documentación${RESET}"
        echo -e "${CYAN}5) ${WHITE}Salir${RESET}"
        echo -n -e "\n${BOLD}${YELLOW}Seleccione una opción [1-5]: ${RESET}"
        read -r option

        case $option in
            1) create_backup ;;
            2) restore_backup ;;
            3) show_system_info ;;
            4) show_help ;;
            5) 
                echo -e "\n${BOLD}${GREEN}¡Gracias por utilizar nuestro sistema de Backup & Restore!${RESET}"
                echo -e "${YELLOW}Desarrollado con 💖 por termux.app${RESET}\n"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida. Por favor, intente nuevamente.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Verificar que estamos en Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}Error: Este script está diseñado para ejecutarse en Termux.${RESET}"
    exit 1
fi

# Iniciar el programa
main_menu
