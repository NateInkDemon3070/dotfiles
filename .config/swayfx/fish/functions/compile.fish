function compile --description "Compile a file detecting the right compiler by file type"
    if test (count $argv) -eq 0
        echo "Uso: compile <archivo> [nombre_salida]"
        return 1
    end

    set -l file $argv[1]

    if not test -f $file
        echo "Error: '$file' no existe o no es un archivo"
        return 1
    end

    set -l dir (path dirname $file)
    set -l stem (path basename $file)
    set -l ext (path extension $stem | string replace -r '^\.' '')
    set -l base (string replace -r '\.[^.]*$' '' $stem)
    set -l out

    if test -n "$argv[2]"
        set out $argv[2]
    else
        set out $dir/$base
    end

    echo "Compilando '$file'..."

    switch $ext
        case c
            if command -q gcc
                gcc -Wall -Wextra $file -o $out
            else if command -q clang
                clang -Wall -Wextra $file -o $out
            else
                echo "Error: no hay compilador de C instalado (gcc o clang)"
                return 1
            end
        case cpp cc cxx 'c++'
            if command -q g++
                g++ -Wall -Wextra $file -o $out
            else if command -q clang++
                clang++ -Wall -Wextra $file -o $out
            else
                echo "Error: no hay compilador de C++ instalado (g++ o clang++)"
                return 1
            end
        case rs
            command -q rustc; or begin
                echo "Error: rustc no está instalado"
                return 1
            end
            rustc -O $file -o $out
        case go
            command -q go; or begin
                echo "Error: go no está instalado"
                return 1
            end
            go build -o $out $file
        case java
            command -q javac; or begin
                echo "Error: javac no está instalado"
                return 1
            end
            javac $file
            echo "Listo: se generaron los archivos .class junto a '$stem'"
            return 0
        case hs
            command -q ghc; or begin
                echo "Error: ghc no está instalado"
                return 1
            end
            ghc -o $out $file
        case f f90 f95 f03
            command -q gfortran; or begin
                echo "Error: gfortran no está instalado"
                return 1
            end
            gfortran -o $out $file
        case zig
            command -q zig; or begin
                echo "Error: zig no está instalado"
                return 1
            end
            zig build-exe $file -femit-bin=$out
        case cs
            if command -q mcs
                mcs -out:$out $file
            else
                echo "Error: mcs (mono) no está instalado"
                return 1
            end
        case ts
            command -q tsc; or begin
                echo "Error: tsc no está instalado"
                return 1
            end
            tsc $file
            echo "Listo: se generó '$base.js' junto a '$stem'"
            return 0
        case lua
            command -q luac; or begin
                echo "Error: luac no está instalado"
                return 1
            end
            luac -o $out $file
        case s S
            command -q gcc; or begin
                echo "Error: gcc no está instalado"
                return 1
            end
            gcc $file -o $out
        case asm
            if command -q nasm; and command -q gcc
                nasm -f elf64 $file -o /tmp/(basename $file).o
                and gcc -no-pie /tmp/(basename $file).o -o $out
                and rm -f /tmp/(basename $file).o
            else
                echo "Error: se necesitan nasm y gcc para ensamblado"
                return 1
            end
        case v sv
            command -q iverilog; or begin
                echo "Error: iverilog no está instalado"
                return 1
            end
            iverilog -o $out $file
        case py
            python3 -m py_compile $file
            echo "Listo: se compiló '$stem' a bytecode"
            return 0
        case sh
            command -q bash; or begin
                echo "Error: bash no está instalado"
                return 1
            end
            bash -n $file
            echo "Listo: sintaxis correcta"
            return 0
        case '*'
            set -l type (file --brief $file)
            switch $type
                case "*C source*"
                    gcc -Wall -Wextra $file -o $out
                case "*C++ source*"
                    g++ -Wall -Wextra $file -o $out
                case '*'
                    echo "Error: tipo de archivo no soportado ($type)"
                    return 1
            end
    end

    if test $status -eq 0
        echo "Listo: $out"
    end
end
