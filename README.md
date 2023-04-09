### what?

When `pkg-listn` is executed it will compare the
packages listed in *"packages file"*
(`~/.config/pkg-listn/packages`) against packages
that is installed locally (`pacman -Qq`) to see
what to *"mark for installation"*. `pkg-listn`
will then proceed to figure out from which
repositories(*official* or *foreign*) the marked
packages are available from. `pkg-listn` will
also compare the *package file* against a
automatically generated *"cache file"*
(`~/.cache/pkg-listn/packages-cache`) to determine
which packages to *"mark for removal"*.

If there is available packages marked for
installation and/or removal, a terminal is opened
with a summary of commands that are about to
get executed, the commands are configurable in
the "*settings file*".  

Below are the default settings: (`~/.config/pkg-listn/settings`)  

```text
install_foreign_command = yay -S
install_command         = sudo pacman -S

remove_foreign_command  = sudo pacman -R
remove_command          = sudo pacman -R

list_local   = pacman -Qq
list_remote  = pacman -Slq
list_foreign = yay --aur -Slq

# terminal_command = kitty --name pkg-listn -e 
# terminal_command = urxvtc -name pkg-listn -e 
# terminal_command = i3term --instance pkg-listn -p spacedust-dark --
terminal_command = xterm -name pkg-listn -e 
```

The commands will get executed accordingly in the
new terminal.

Included in the repository is also two **systemd**
units, that when enabled:  
(`systemctl --user enable --now pkg-listn.path`),  
will automatically execute `pkg-listn.bash` when
the **package file** has been modified.


#### unmanage packages

You might end up in a situation where you want to
remove entries from the package file, without uninstalling
the packages. To do that use the command-line option
`--unmanage PACKAGE...`, example:  

```text
$ pkg-listn --unmanage bzip2 libev pcre zlib
```

The above command would remove `bzip2 libev pcre zlib` from
both the **package file** and the **cache file**.  

### why?

When i tried using [NixOS] i found it nice to have
all manually installed packages declared in a file,
like this. It has happened to me many times, that I have
forgot what packages i had installed, and this setup
also makes it easy to recreate the same package installation
on a new system.  

The problem doing this is that something
like this can easily get even more unmanageable if
one installs and remove packages both with
`pkg-listn`, `pacman`, and `yay` f.i. But with
`pkg-listn` it shouldn't be a problem, if you
install a package normally from the commandline
with `pacman -S` it will not mess things up for
`pkg-listn` and vice versa, the only drawback is
that you need to add such packages sometime later
to your **package file**, but it is not important
to do so, its only to have it in the list and you
can then also use `pkg-listn` to remove that
package (simply by removing it from **package file**).

### how?

runtime dependencies are:
  - GNU sed
  - GNU bash
  - a package manager (pacman, apt, zypper e.t.c)
  - an AUR helper (optional)
  - a terminal emulator (xterm, alacritty, gnome-terminal e.t.c) 

**Arch Linux** users can install `pkg-listn` from [AUR]:  

``` shell
git clone https://aur.archlinux.org/pkg-listn.git
cd pkg-listn
makepkg -si
# yay -S pkg-listn     # AUR helper does whats listed above
```

---

Or clone and install from source:  
(N.B. **gawk** and **GNUmake** is needed to build)  

 ``` shell
 git clone https://github.com/budRich/pkg-listn.git
 cd pkg-listn
 make
 sudo make PREFIX=/usr install # adjust PREFIX if needed
```

After installation this is how you create the default
settings and enable the systemd units:  

```shell
pkg-listn -v           # this will create the config/package file
cat ~/.config/pkg-listn/settings # review the settings
# the default configuration is setup to use pacman, yay, xterm
systemctl --user enable --now pkg-listn.path
nano ~/.config/pkg-listn/packages # add some packages
```


[AUR]: https://aur.archlinux.org/packages/pkg-listn
[NixOS]: https://nixos.org/
[i3term]: https://github.com/budlabs/i3term
