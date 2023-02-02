##   pkg-listn
#### manage your Arch linux packages with textfiles

When `pkg-listn` is executed it will compare Arch
packages listed in the *"packages file"*
(`~/.config/pkg-listn/packages`) and the
automatically generated *"cache file"*
(`~/.cache/pkg-listn/packages-cache`).

Packages that are unique to the **package file**
will get "*marked for installation*", and
packages unique to the **cache file** will
get "*marked for removal*". `pkg-listn` will then
sort out if the packages marked for installation
are available and from where (official Arch
repos, or **AUR**). Then a terminal is opened
with [i3term] listing a summary of the commands
that are about to get executed, the commands
are configurable in the "*settings file*".  
Below are the default settings: (`~/.config/pkg-listn/settings`)  

```text
pacman_install = sudo pacman -S
pacman_remove  = sudo pacman -R
aur_install    = yay -S
aur_list       = yay --aur -Slq

i3term_options = --instance pkg-listn
```

You can replace the `yay` commands with a different
*AUR helper*, make sure that **aur_list** command
prints out a list of all available AUR packages, one
pkg/line.

The commands will be executed accordingly in the
new terminal, and by default it will be a normal
interactive pacman/yay prompt, packages are not
installed/removed *automatically*.

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

The problem doing this on Arch is that something
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

## how

As mentioned [i3term] needs to be installed, but
it is trivial to modify the script to work with
any terminal emulator. Beside that the only
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

[NixOS]: https://nixos.org/
[i3term]: https://github.com/budlabs/i3term
