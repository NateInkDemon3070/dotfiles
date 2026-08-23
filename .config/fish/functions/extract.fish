function extract --description "Extract compressed files"
    if test (count $argv) -eq 0
        echo "Uso: extract <archivo>"
        return 1
    end

    set -l file $argv[1]

    if not test -f $file
        echo "Error: '$file' no existe o no es un archivo"
        return 1
    end

    set -l dir (dirname $file)
    set -l dest ""

    echo "¿Dónde extraer?"
    echo "  1) En la misma carpeta ($dir)"
    echo "  2) En otra ruta"
    read -P "> " -l choice

    switch $choice
        case 1
            set dest $dir
        case 2
            echo "Ruta destino:"
            read -P "> " -l dest
            if not test -d $dest
                echo "¿Crear directorio '$dest'? (s/n)"
                read -P "> " -l confirm
                if test "$confirm" = "s"
                    mkdir -p $dest
                else
                    echo "Cancelado"
                    return 1
                end
            end
        case '*'
            echo "Opción no válida"
            return 1
    end

    set -l type (file --brief $file)
    echo "Extrayendo '$file' en '$dest'..."

    switch $type
        case "*gzip*"
            if string match -q "*.tar.gz" $file; or string match -q "*.tgz" $file
                tar xzf $file -C $dest
            else
                gunzip -k $file
            end
        case "*bzip2*"
            if string match -q "*.tar.bz2" $file; or string match -q "*.tbz2" $file
                tar xjf $file -C $dest
            else
                bunzip2 -k $file
            end
        case "*XZ*"
            if string match -q "*.tar.xz" $file; or string match -q "*.txz" $file
                tar xJf $file -C $dest
            else
                xz -dk $file
            end
        case "*Zstandard*"
            if string match -q "*.tar.zst" $file; or string match -q "*.zst" $file
                tar --zstd -xf $file -C $dest
            else
                zstd -dk $file
            end
        case "*Zip*"
            unzip $file -d $dest
        case "*7-zip*"
            7z x $file -o$dest
        case "*RAR*"
            unrar x $file $dest
        case "*ar archive*"
            ar x $file --output=$dest
        case "*cpio*"
            cd $dest; cpio -idm < $file; cd -
        case "*tar archive*"
            tar xf $file -C $dest
        case '*'
            echo "Error: tipo de archivo no soportado ($type)"
            return 1
    end

    echo "Listo: extraído en $dest"
end
