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
pacman_install = sudo pacman -S
pacman_remove  = sudo pacman -R
# aur_install  = paru -S
# aur_list     = paru --aur -Slq
aur_install    = yay -S
aur_list       = yay --aur -Slq

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
  - pacman
  - an AUR helper (optional)

When you have that run:  

 ```
 # make install
 $ pkg-listn -v
```

This will install (but not **enable** or start) the systemd
units and add the script to `$PREFIX/bin/` as pkg-listn.
The only available command line option is `-v` which
will print version information to **stderr**, and
if it is the first time `pkg-listn` is executed it
will create the configuration files in `~/.config/pkg-listn`.

[NixOS]: https://nixos.org/
[i3term]: https://github.com/budlabs/i3term
