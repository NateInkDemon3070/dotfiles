function dot --description "Sincroniza configs vivas al repo dotfiles, commitea y hace push"
    set -l repo /home/jpablo/dotfiles
    if set -q DOTFILES_REPO
        set repo $DOTFILES_REPO
    end
    set -l cfg /home/jpablo/.config

    # Apps con perfil enorme o con datos sensibles: nunca se copia el perfil
    # completo, solo las subcarpetas que el repo ya trackea.
    set -l partial equibop pear-desktop zen

    if test (count $argv) -eq 0
        echo 'Uso: (el mensaje es opcional)'
        echo '  dot <config> [mensaje]                sincroniza ~/.config/<config>'
        echo '  dot wallpapers|sddm|limine [mensaje]  partes del sistema'
        echo '  dot all [mensaje]                    TODO'
        echo 'Ej: dot waybar "nuevo estilo"   |   dot all'
        return 1
    end

    set -l what $argv[1]
    set -l msg $argv[2]
    if test -z "$msg"
        set msg "sync $what "(date '+%Y-%m-%d %H:%M')
    end
    set -l fulls
    set -l apps
    set -l specials

    if test $what = all; or test $what = --all
        for d in $repo/.config/mangowm/*
            set -l n (basename $d)
            if not contains -- $n $partial
                set -a fulls $n
            end
        end
        set apps $partial
        set specials wallpapers sddm limine
    else
        switch $what
            case wallpapers wallpaper Wallpapers
                set -a specials wallpapers
            case sddm sddm.conf.d
                set -a specials sddm
            case limine limine.conf
                set -a specials limine
            case '*'
                if contains -- $what $partial
                    set -a apps $what
                else
                    set -a fulls $what
                end
        end
    end

    set -l add

    # configs completas
    for n in $fulls
        set -l src $cfg/$n
        if not test -e $src
            echo "  aviso: no existe $src (se omite)"
            continue
        end
        set -l dest .config/mangowm/$n
        mkdir -p $repo/(dirname $dest)
        rm -rf $repo/$dest
        cp -a $src $repo/$dest
        set -a add $dest
    end

    # sincro parcial: solo subcarpetas que el repo ya trackea
    for a in $apps
        set -l tracked (git -C $repo ls-files .config/mangowm/$a)
        if test (count $tracked) -eq 0
            echo "  aviso: el repo no trackea nada de $a (se omite)"
            continue
        end
        set -l subs
        for f in $tracked
            set -l rel (string replace ".config/mangowm/$a/" '' -- $f)
            set -l sub (string split -m1 / $rel)[1]
            if not contains -- $sub $subs
                set -a subs $sub
            end
        end
        for s in $subs
            set -l src $cfg/$a/$s
            if not test -e $src
                # apps tipo navegador: el perfil activo esta en installs.ini
                set -l prof
                if test -f $cfg/$a/installs.ini
                    set prof (string match -r '^Default=(.*)' < $cfg/$a/installs.ini | tail -n1)
                end
                if test -n "$prof"
                    if test -e $cfg/$a/$prof/$s
                        set src $cfg/$a/$prof/$s
                        echo "  ($a: perfil '$prof')"
                    end
                end
                if not test -e $src
                    set -l cand (command find $cfg/$a -mindepth 2 -maxdepth 2 -type d -name $s 2>/dev/null)
                    if test (count $cand) -eq 1
                        set src $cand[1]
                    else
                        echo "  aviso: no pude determinar $a/$s (candidatos: (count $cand)) - se omite"
                        continue
                    end
                end
            end
            set -l dest .config/mangowm/$a/$s
            mkdir -p $repo/(dirname $dest)
            rm -rf $repo/$dest
            cp -a $src $repo/$dest
            set -a add $dest
        end
    end

    # partes del sistema
    for sp in $specials
        set -l src
        set -l dest
        if test $sp = wallpapers
            set src /home/jpablo/Wallpapers
            set dest Wallpapers
        else if test $sp = sddm
            set src /etc/sddm.conf.d
            set dest sddm.conf.d
        else if test $sp = limine
            set src /boot/limine.conf
            set dest limine.conf
        end
        if test -z "$src"; or test -z "$dest"
            continue
        end
        if not test -e $src
            echo "  aviso: no existe $src (se omite)"
            continue
        end
        mkdir -p $repo/(dirname $dest)
        rm -rf $repo/$dest
        cp -a $src $repo/$dest
        set -a add $dest
    end

    # commit + push
    set -l realadd
    for p in $add
        if test -e $repo/$p
            set -a realadd $p
        end
    end
    if test (count $realadd) -eq 0
        echo 'nada para commitear'
        return 1
    end
    git -C $repo add $realadd
    and git -C $repo commit -m $msg
    and git -C $repo push
end
