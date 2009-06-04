" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
doc/CSApprox.txt	[[[1
599
*CSApprox.txt*  Bringing GVim colorschemes to the terminal!

                                                     *csapprox* *csapprox.vim*

                  _____ ____ ___                               ~
                 / ___// __// _ |  ___   ___   ____ ___  __ __ ~
                / /__ _\ \ / __ | / _ \ / _ \ / __// _ \ \ \ / ~
                \___//___//_/ |_|/ .__// .__//_/   \___//_\_\  ~
                                /_/   /_/                      ~
                                                  For Vim version 7.0 or newer
                                                      Last changed 01 Apr 2009

                               By Matt Wozniski
                                mjw@drexel.edu

                              Reference Manual~

                                                                *csapprox-toc*

1. Introduction                                       |csapprox-intro|
2. Requirements                                       |csapprox-requirements|
3. Configuration                                      |csapprox-configure|
4. Rationale/Design                                   |csapprox-design|
5. Known Bugs and Limitations                         |csapprox-limitations|
6. Appendix - Terminals and Palettes                  |csapprox-terminal-list|
7. Changelog                                          |csapprox-changelog|
8. Contact Info                                       |csapprox-author|

The functionality mentioned here is a plugin, see |add-plugin|.
You can avoid loading this plugin by setting the "CSApprox_loaded" global
variable in your |vimrc| file: >
    :let g:CSApprox_loaded = 1

==============================================================================
1. Introduction                                               *csapprox-intro*

It's hard to find colorschemes for terminal Vim.  Most colorschemes are
written to only support GVim, and don't work at all in terminal Vim.

This plugin makes GVim-only colorschemes Just Work in terminal Vim, as long
as the terminal supports 88 or 256 colors - and most do these days.  This
usually requires no user interaction (but see below for what to do if things
don't Just Work).  After getting this plugin happily installed, any time you
use :colorscheme it will do its magic and make the colorscheme Just Work.

Whenever you change colorschemes using the :colorscheme command this script
will be executed.  It will take the colors that the scheme specified for use
in the GUI and use an approximation algorithm to try to gracefully degrade
them to the closest color available in your terminal.  If you are running in
a GUI or if your terminal doesn't support 88 or 256 colors, no changes are
made.  Also, no changes will be made if the colorscheme seems to have been
high color already.

If for some reason this transparent method isn't suitable to you (for instance
if your environment can't be configured to meet the |csapprox-requirements|,
or you need to work in Vim 6), another option is also available: using the
|:CSApproxSnapshot| command to create a new GUI/88-/256-color terminal
colorscheme.  To use this command, a user would generally start GVim, choose a
colorscheme that sets up the desired colors, and then use |:CSApproxSnapshot|
to create a new colorscheme based on those colors that works in high color
terminals.  This method is more flexible than the transparent mode and works
in more places, but also requires more user intervention, and makes it harder
to deal with colorschemes being updated and such.
                                                           *:CSApproxSnapshot*
The full syntax for the command is: >
    :CSApproxSnapshot[!] /path/to/new/colorscheme
<       For example: >
    :CSApproxSnapshot ~/.vim/colors/foobar.vim
<
NOTE: The generated colorscheme will only work in 88- and 256-color terminals,
      and in GVim.  It will not work at all in a terminal with 16 or fewer
      colors.  There's just no reliable way to approximate down from
      16,777,216 colors to 16 colors, especially without there being any
      standard for what those 16 colors look like other than 'orange-ish',
      'red-ish', etc.

NOTE: Although :CSApproxSnapshot can be used in both GVim and terminal Vim,
      the resulting colors might be slightly off when run from terminal Vim.
      I can find no way around this; Vim internally sets different colors when
      running in a terminal than running in the GUI, and there's no way for
      terminal Vim to figure out what color would have been used in GVim.

==============================================================================
2. Requirements                                        *csapprox-requirements*

For CSApprox to work, there are 2 major requirements that must be met.

a) GUI support                          *csapprox-gui-support* *csapprox-+gui*

If CSApprox is being used to adjust a scheme's colors transparently, then the
terminal "vim" binary that is being run must be built with GUI support (see
|csapprox-limitations| for an explanation).  If |:CSApproxSnapshot| is being
used to create a terminal colorscheme for high color terminals, then the
"vim" binary being used to create the scheme must be built with +gui, but the
scheme can be used in terminal "vim" binaries that weren't built with +gui.
NOTE that creating snapshots with GVim will work better than making them with
Vim, and (obviously) all "gvim" binaries are built with +gui.

Unfortunately, several Linux distributions only include GUI support in their
"gvim" binary, and not in their "vim" binary.  You can check if GUI support is
available with the following command:
    :echo has('gui')

If that prints 0, the first thing to try would be searching for a larger vim
package provided by your distribution, like "vim-enhanced" on RedHat/CentOS
or "vim-gtk" or "vim-gnome" on Debian/Ubuntu.

If you are unable to obtain a "vim" binary that includes GUI support, but
have a "gvim" binary available, you can probably launch Vim with GUI support
anyway by calling gvim with the |-v| flag in the shell: >
    gvim -v

If the above works, you can remove the need to call "gvim -v" instead of "vim"
all the time by creating a symbolic link from your "gvim" binary to "vim"
somewhere in your $PATH, for example:
    sudo ln -s $(which gvim) $(which vim)

If launching as "gvim -v" doesn"t work, and no package with GUI support is
available, you will need to compile Vim yourself and ensure that GUI support
is included to use CSApprox in its transparent mode, or create a snapshotted
scheme from GVim to use its snapshot mode.  If this is inconvenient for you,
make sure that the Vim maintainer for your distribution knows it; they made a
conscious decision to build "vim" without +gui and "gvim" without terminal
support.

b) Properly configured terminal                            *csapprox-terminal*

As said above, many modern terminals support 88 or 256 colors, but most of
these default to setting $TERM to something generic (usually "xterm").  Since
Vim uses the value of the "colors" attribute for the current $TERM in terminfo
to figure out the number of colors used internally as 't_Co', this plugin will
either need for 't_Co' to be set to 88 or 256 in |vimrc|, or for $TERM to be
set to something that implies high color support.  Possible choices include
"xterm-256color" for 256 color support and "rxvt-unicode" for 88 color
support.
                                                              *csapprox-palettes*
Also, there are three different 256 color cube palettes available and CSApprox
has no way to tell which you're using unless $TERM is set to something that is
specific to the terminal, like "konsole-256color" or "Eterm".  Because of this, the
most sane behavior is assuming the user is using the most popular palette,
which is used by all but Konsole and Eterm, whenever $TERM is set to something
generic like "xterm" or "screen".  You can override this default, however -
see |csapprox-configure|.
                                                   *csapprox-terminal-example*
To turn on high color support without fixing $TERM, you can change t_Co in
your .vimrc, and set either CSApprox_konsole or CSApprox_eterm if appropriate.
One way would be to put something like this into your |vimrc|:
>
    if (&term == 'xterm' || &term =~? '^screen') && hostname() == 'my-machine'
        " On my machine, I use Konsole with 256 color support
        set t_Co=256
        let g:CSApprox_konsole = 1
    endif

Gnome Terminal, as of the time that I am writing this, doesn't support having
the terminal emulator set $TERM to something adequately descriptive.  In cases
like this, something like the following would be appropriate:
>
    if &term =~ '^\(xterm\|screen\)$' && $COLORTERM == 'gnome-terminal'
      set t_Co=256
    endif

==============================================================================
3. Configuration                                          *csapprox-configure*

There are several global variables that can be set to configure the behavior
of CSApprox.  They are listed roughly based on the likelihood that the end
user might want to know about them.

g:CSApprox_loaded                                          *g:CSApprox_loaded*
    If set in your |vimrc|, CSApprox is not loaded.  Has no effect on
    snapshotted schemes.

g:CSApprox_verbose_level                            *g:CSApprox_verbose_level*
    When CSApprox is run, the 'verbose' option will be temporarily raised to
    the value held in this variable unless it is already greater.  The default
    value is 1, which allows CSApprox to default to warning whenever something
    is wrong, even if it is recoverable, but allows the user to quiet us if he
    wants by changing this variable to 0.  The most important messages will be
    shown at verbosity level 1; some less important ones will be shown at
    higher verbosity levels.  Has no effect on snapshotted schemes.

g:CSApprox_eterm                                            *g:CSApprox_eterm*
    If set to a non-zero number, CSApprox will use the Eterm palette when
    'term' is set to "xterm" or begins with "screen".  Otherwise, the xterm
    palette would be used.  This also affects snapshotted schemes.

g:CSApprox_konsole                                        *g:CSApprox_konsole*
    If set to a non-zero number, CSApprox will use the Konsole palette when
    'term' is set to "xterm" or begins with "screen".  Otherwise, the xterm
    palette would be used.  This also affects snapshotted schemes.

g:CSApprox_attr_map                                      *g:CSApprox_attr_map*
    Since some attributes (like 'guisp') can't be used in a terminal, and
    others (like 'italic') are often very ugly in terminals, a generic way to
    map between a requested attribute and another attribute is included.  This
    variable should be set to a Dictionary, where the keys are strings
    representing the attributes the author wanted set, and the values are the
    strings that the user wants set instead.  If a value is '', it means the
    attribute should just be ignored.  The default is to replace 'italic' with
    'underline', and to use 'fg' instead of 'sp': >
        let g:CSApprox_attr_map = { 'italic' : 'underline', 'sp' : 'fg' }
<
    Your author prefers disabling bold and italic entirely, so uses this: >
        let g:CSApprox_attr_map = { 'bold' : '', 'italic' : '', 'sp' : 'fg' }
<

    Note: This transformation is considered at the time a snapshotted scheme
          is created, rather than when it is used.

    Note: You can only map an attribute representing a color to another
          attribute representing a color; likewise with boolean attributes.
          After all, sp -> bold and italic -> fg would be nonsensical.

                          *g:CSApprox_hook_pre* *g:CSApprox_hook_{scheme}_pre*
                        *g:CSApprox_hook_post* *g:CSApprox_hook_{scheme}_post*
g:CSApprox_hook_pre
g:CSApprox_hook_post
g:CSApprox_hook_{scheme}_pre
g:CSApprox_hook_{scheme}_post                                 *csapprox-hooks*
    These variables provide a method for adjusting tweaking the approximation
    algorithm, either for all schemes, or on a per scheme basis.  For
    snapshotted schemes, these will only take effect when the snapshotted
    scheme is created, rather than when it is used.  Each of these variables
    may be set to either a String containing a command to be :execute'd, or a
    List of such Strings.  The _pre hooks are executed before any
    approximations have been done.  In order to affect the approximation at
    this stage, you would need to change the gui colors for a group; the cterm
    colors will then be approximated from those gui colors.  Example:
>
      let g:CSApprox_hook_pre = 'hi Comment guibg=#ffddff'
<
    The advantage to tweaking the colors at this stage is that CSApprox will
    handle approximating the given gui colors to the proper cterm colors,
    regardless of the number of colors the terminal supports.  The
    disadvantage is that certain things aren't possible, including clearing
    the background or foreground color for a group, selecting a precise cterm
    color to be used, and overriding the mappings made by g:CSApprox_attr_map.
    Another notable disadvantage is that overriding things at this level will
    actually affect the gui colors, in case the :gui is used to start gvim
    from the running vim instance.

    To overcome these disadvantages, the _post hooks are provided.  These
    hooks will be executed only after all approximations have been completed.
    At this stage, in order to have changes appear the cterm* colors must be
    modified.  For example:
                                                       *csapprox-transparency*
>
      let g:CSApprox_hook_post = ['hi Normal  ctermbg=NONE ctermfg=NONE',
                                \ 'hi NonText ctermbg=NONE ctermfg=NONE' ]
<
    Setting g:CSApprox_hook_post as shown above will clear the background of
    the Normal and NonText groups, forcing the terminal's default background
    color to be used instead, including any pseudotransparency done by that
    terminal emulator.  As noted, though, the _post functions do not allow
    CSApprox to approximate the colors.  This may be desired, but if this is
    an inconvenience the function named by g:CSApprox_approximator_function
    can still be called manually.  For example:
>
      let g:CSApprox_hook_post = 'exe "hi Comment ctermbg="'
                      \ . '. g:CSApprox_approximator_function(0xA0,0x50,0x35)'
<
    The _{scheme}_ versions are exactly like their counterparts, except that
    they will only be executed if the value of g:colors_name matches the
    scheme name embedded in the variable name.  They will be executed after
    the corresponding hook without _{scheme}_, which provides a way to
    override a less specific hook with a more specific one.  For example, to
    clear the Normal and NonText groups, but only for the colorscheme
    "desert", one could do the following:
>
    let g:CSApprox_hook_desert_post = ['hi Normal ctermbg=NONE ctermfg=NONE',
                                    \ 'hi NonText ctermbg=NONE ctermfg=NONE' ]
<
    One final example: If you want CSApprox to be active for nearly all
    colorschemes, but want one or two particular schemes to be ignored, you
    can take advantage of the CSApprox logic that skips over any color scheme
    that is already high color by setting a color to a number above 255.  Note
    that most colors greater than 15 will work, but some will not - 256 should
    always work.  For instance, you can prevent CSApprox from modifying the
    colors of the zellner colorscheme like this:
>
    let g:CSApprox_hook_zellner_pre = 'hi _FakeGroup ctermbg=256'
<
    NOTE: Any characters that would stop the string stored in g:colors_name
          from being a valid variable name will be removed before the
          _{scheme}_ hook is searched.  Basically, this means that first all
          characters that are neither alphanumeric nor underscore will be
          removed, then any leading digits will be removed.  So, for a
          colorscheme named "123 foo_bar-baz456.vim", the hook searched for
          will be, eg, g:CSApprox_hook_foo_barbaz456_post

g:CSApprox_use_showrgb                                *g:CSApprox_use_showrgb*
    By default, CSApprox will use a built in mapping of color names to values.
    This optimization greatly helps speed, but means that colors addressed by
    name might not match up perfectly between gvim (which uses the system's
    real rgb database) and CSApprox (which uses the builtin database).  To
    force CSApprox to try the systemwide database first, and only fall back on
    the builtin database if it isn't available, set this variable non-zero.

g:CSApprox_approximator_function            *g:CSApprox_approximator_function*
    If the default approximation function doesn't work well enough, the user
    (or another author wishing to extend this plugin) can write another
    approximation function.  This function should take three numbers,
    representing r, g, and b in decimal, and return the index on the color
    cube that best matches those colors.  Assigning a |Funcref| to this
    variable will override the default approximator with the one the Funcref
    references.  This option will take effect at the time a snapshotted scheme
    is created, rather than when it's used.

g:CSApprox_redirfallback                            *g:CSApprox_redirfallback*
    Until Vim 7.2.052, there was a bug in the Vim function synIDattr() that
    made it impossible to determine syntax information about the |guisp|
    attribute.  CSApprox includes a workaround for this problem, as well as a
    test that ought to disable this workaround if synIDattr() works properly.
    If this test should happen to give improper results somehow, the user can
    force the behavior with this variable.  When set to 1, the workaround will
    always be used, and when set to 0, synIDattr() is blindly used.  Needless
    to say, if this automatic detection should ever fail, the author would
    like to be notified!  This option will take effect at the time a
    snapshotted scheme is created, rather than when it's used.

==============================================================================
4. Rationale/Design                                          *csapprox-design*

There is a wealth of colorschemes available for Vim.  Unfortunately, since
traditional terminal emulators have only supported 2, 8 or 16 colors,
colorscheme authors have tended to avoid writing colorschemes for terminal
Vim, sticking instead to GVim.  Even now that nearly every popular terminal
supports either 88 or 256 colors, few colorschemes are written to support
them.  This may be because the terminal color codes are just numbers from 0 to
87 or 255 with no semantic meaning, or because the same number doesn't yield
the same color in all terminals, or simply because the colorscheme author
doesn't use the terminal and doesn't want to take the time to support
terminals.

Whatever the reason, this leaves users of many modern terminal emulators in
the awkward position of having a terminal emulator that supports many colors,
but having very few colorschemes that were written to utilize those colors.

This is where CSApprox comes in.  It attempts to fill this void allowing GVim
colorschemes to be used in terminal Vim.  CSApprox has two distinct modes of
operation.  In the first mode, it attempts to make GVim colorschemes
transparently backwards compatible with terminal Vim in a high color terminal.
Basically, whenever a colorscheme is run it should set some colors for the
GUI, and this script will then run and attempt to figure out the closest color
available in the terminal's color palette to the color the scheme author asked
for.  Unfortunately, this does not work well all the time, and it has some
limitations (see |csapprox-limitations|).  Most of the time, however, this
gives a very close approximation to the GVim colors without requiring any
changes to the colorscheme, or any user interaction.  It only requires that
the plugin be installed on the machine where Vim is being run, and that the
user's environment meets the needs specified at |csapprox-requirements|.  In
the event that this doesn't work, a second option - using :CSApproxSnapshot
to create a new, 88-/256-color capable colorscheme - is available.

Ideally, the aim is for CSApprox to be completely transparent to the user.
This is why the approach I take is entirely different from the GuiColorScheme
script, which will break on any but the simplest colorschemes.  Unfortunately,
given the difficulty of determining exactly which terminal emulator the user
is running, and what features it supports, and which color palette it's using,
perfect transparency is difficult.  So, to this end, I've attempted to default
to settings that make it unlikely that this script ever makes things worse
(this is why I chose not to override t_Co to 256 myself), and I've attempted
to make it easy to override my choice of defaults when necessary (through
g:CSApprox_approximator_function, g:CSApprox_konsole, g:CSApprox_eterm,
g:CSApprox_attr_map, etc).

In the event that the transparent solution is undesirable, or that the user's
environment can't be configured to allow it (no GVim and no Vim with +gui, for
instance), |:CSApproxSnapshot| should provide a workable alternative - less
cool, and less flexible, but it will work in more environments, and the
snapshotted colorscheme will even work in Vim 6.

If any of my design choices seem to be causing extra work with no real
advantages, though, I'd like to hear about it.  Feel free to email me with any
improvements or complaints.

==============================================================================
5. Known Bugs and Limitations                           *csapprox-limitations*

GUI support is required for transparently adapting schemes.

  There is nothing I can do about this given my chosen design.  CSApprox works
  by being notified every time a colorscheme sets some GUI colors, then
  approximating those colors to similar terminal colors.  Unfortunately, when
  Vim is not built with GUI support, it doesn't bother to store the GUI
  colors, so querying for them fails.  This leaves me completely unable to
  tell what the colorscheme was trying to do.  See |csapprox-+gui| for some
  potential workarounds if your distribution doesn't provide a Vim with +gui.

User intervention is sometimes required for information about the terminal.

  This is really an insurmountable problem.  Unfortunately, most terminal
  emulators default to setting $TERM to 'xterm', even when they're not really
  compatible with an xterm.  $TERM is really the only reliable way to
  find anything at all out about the terminal you're running in, so there's no
  way to know if the terminal supports 88 or 256 colors without either the
  terminal telling me (using $TERM) or the user telling me (using 't_Co').
  Similarly, unless $TERM is set to something that implies a certain color
  palette ought to be used, there's no way for me to know, so I'm forced to
  default to the most common, xterm's palette, and allow the user to override
  my choice with |g:CSApprox_konsole| or |g:CSApprox_eterm|.  An example of
  configuring Vim to work around a terminal where $TERM is set to something
  generic without configuring the terminal properly is shown at
  |csapprox-terminal-example|.

Some colorschemes could fail to be converted if they try to be too smart.

  A colorscheme could decide to only set colors for the mode Vim is running
  in.  If a scheme only sets GUI colors when the GUI is running, instead of
  using the usual approach of setting all colors and letting Vim choose which
  to use, my approach falls apart.  My method for figuring out what the scheme
  author wants the scheme to look like absolutely depends upon him setting the
  GUI colors in all modes.  Fortunately, the few colorschemes that do this
  seem to be, by and large, intended for 256 color terminals already, meaning
  that skipping them is the proper behavior.  Note that this will only affect
  transparently adapted schemes and snapshots made from terminal Vim;
  snapshots made from GVim are immune to this problem.

Transparently adapting schemes is slow.

  For me, it takes Vim's startup time from 0.15 seconds to 0.35 seconds.  This
  is probably still acceptable, but it is definitely worth trying to cut down
  on this time in future versions.  Snapshotted schemes are faster to use,
  since all of the hard evaluations are made when they're made instead of when
  they're used.

  NOTE: As of CSApprox 3.50, the overhead is down to about 0.10 seconds on my
        test machine.

==============================================================================
6. Appendix - Terminals and Palettes                  *csapprox-terminal-list*

What follows is a list of terminals known to have and known not to have high
color support.  This list is certainly incomplete; feel free to contact me
with more to add to either list.

                                                     *csapprox-terminals-good*
------------------------------- Good Terminals -------------------------------

The most recent versions of each of these terminals can be compiled with
either 88 or 256 color support.

                                                              *csapprox-xterm*
xterm:
    256 color palette
    Colors composed of: [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]
    Greys composed of:  [ 0x08, 0x12, 0x1C, 0x26, 0x30, 0x3A, 0x44, 0x4E,
                          0x58, 0x62, 0x6C, 0x76, 0x80, 0x8A, 0x94, 0x9E,
                          0xA8, 0xB2, 0xBC, 0xC6, 0xD0, 0xDA, 0xE4, 0xEE ]

                                                              *csapprox-urxvt*
rxvt-unicode (urxvt):
    88 colors by default (but a patch is available to use xterm's palette)
    Colors composed of: [ 0x00, 0x8B, 0xCD, 0xFF ]
    Greys composed of:  [ 0x2E, 0x5C, 0x73, 0x8B, 0xA2, 0xB9, 0xD0, 0xE7 ]

                                               *csapprox-pterm* *csapprox-putty*
PuTTY (pterm; putty.exe):
    256 colors; same palette as xterm

                                                              *csapprox-mrxvt*
Mrxvt (mrxvt):
    256 colors; same palette as xterm

                                                     *csapprox-gnome-terminal*
GNOME Terminal (gnome-terminal):
    256 colors; same palette as xterm

                                                            *csapprox-roxterm*
ROXTerm (roxterm):
    256 colors; same palette as xterm

                                                     *csapprox-xfce4-terminal*
Terminal (xfce4-terminal):
    256 colors; same palette as xterm

                                                          *csapprox-iterm.app*
iTerm (iTerm.app):
    256 colors; same palette as xterm
                                                            *csapprox-konsole*
Konsole (konsole):
    256 color palette
    Colors composed of: [ 0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF ]
    Same greyscales as xterm
    You should set the g:CSApprox_konsole variable unless $TERM begins with
    'konsole', case insensitive

                                                              *csapprox-eterm*
eterm (Eterm):
    256 color palette
    Colors composed of: [ 0x00, 0x2A, 0x55, 0x7F, 0xAA, 0xD4 ]
    Same greyscales as xterm
    You should set the g:CSApprox_eterm variable unless $TERM begins with
    'eterm', case insensitive

                                                             *csapprox-screen*
GNU Screen (screen):
    256 color support.  Internally, uses the xterm palette, but this is only
    relevant when running screen inside a terminal with fewer than 256 colors,
    in which case screen will attempt to map between its own 256 color cube
    and the colors supported by the real terminal to the best of its ability,
    in much the same way as CSApprox maps between GUI and terminal colors.

                                                      *csapprox-terminals-bad*
-------------------------------- Bad Terminals -------------------------------
This is a list of terminals known _not_ to have high color support.  If any of
these terminals have high color support added at some point in the future,
please tell me and I'll update this information.

                                                       *csapprox-terminal.app*
Terminal.app (as of OS X 10.5.2)

                                                              *csapprox-aterm*
aterm (as of version 1.00.01)

                                                             *csapprox-xiterm*
xiterm (as of version 0.5)

                                                              *csapprox-wterm*
wterm (as of version 6.2.9)

                                                             *csapprox-mlterm*
mlterm (as of version 2.9.4)

                                                              *csapprox-kterm*
kterm (as of version 6.2.0)

==============================================================================
7. Changelog                                              *csapprox-changelog*

 3.50   01 Apr 2009   Fix a major regression that prevented the Eterm and
                      Konsole colors from being correctly snapshotted

                      Fix a related bug causing incorrect terminal colors
                      after calling :CSApproxSnapshot

                      Fix a bug causing black to be used instead of dark grey

                      Have snapshots calculate g:colors_name programmatically

                      Introduce many tweaks for better speed

                      Clarify some things at :help csapprox-terminal-example

                      Default to using our own list of rgb.txt colors rather
                      than searching, for performance.  Add a new variable,
                      g:CSApprox_use_showrgb, which forces us to try finding
                      the colors using the "showrgb" program instead, and fall
                      back on our own list if it isn't available

                      Remove g:CSApprox_extra_rgb_txt_dirs - not needed in
                      light of the above change

 3.05   31 Jan 2009   Fix a harmless "Undefined variable" error in
                      :CSApproxSnapshot

                      Fix a behavioral bug when dumping out colors defined
                      external to the scheme.

 3.00   21 Jan 2009   Update the docs for better info on :CSApproxSnapshot

                      Allow snapshotted schemes to work on Vim 6, and work
                      properly in Konsole and Eterm (thanks David Majnemer!)

                      Fix a bug causing a syntax error when using GVim while
                      CSApprox was loaded.  (thanks again, David Majnemer!)

 2.00   14 Dec 2008   Add a hooks system, allowing users to specify a command
                      to run, either before or after the approximation
                      algorithm is run, for all schemes or one specific one.

                      Also rewrite :CSApproxSnapshot to be more maintainable
                      and less of a hack, and fix several bugs that it
                      contained.

 1.50   19 Nov 2008   Add CSApproxSnapshot command, as an alternative solution
                      when the user has gvim or a vim with gui support, but
                      sometimes needs to use a vim without gui support.

 1.10   28 Oct 2008   Enable running on systems with no rgb.txt (Penn Su)
                      Begin distributing a copy of rgb.txt with CSApprox

 1.00   04 Oct 2008   First public release

 0.90   14 Sep 2008   Initial beta release

==============================================================================
8. Contact Info                                              *csapprox-author*

Your author, a Vim nerd with some free time, was sick of seeing terminals
always get the short end of the stick.  He'd like to be notified of any
problems you find - after all, he took the time to write all this lovely
documentation, and this plugin, which took more time than you could possibly
imagine to get working transparently for every colorscheme he could get his
hands on.  You can contact him with any problems or praises at mjw@drexel.edu

==============================================================================
vim:tw=78:fo=tcq2:isk=!-~,^*,^\|,^\":ts=8:ft=help:norl:
plugin/CSApprox.vim	[[[1
987
" CSApprox:    Make gvim-only colorschemes Just Work terminal vim
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Wed, 01 Apr 2009 22:10:19 -0400
" Version:     3.50
" History:     :help csapprox-changelog
"
" Long Description:
" It's hard to find colorschemes for terminal Vim.  Most colorschemes are
" written to only support GVim, and don't work at all in terminal Vim.
"
" This plugin makes GVim-only colorschemes Just Work in terminal Vim, as long
" as the terminal supports 88 or 256 colors - and most do these days.  This
" usually requires no user interaction (but see below for what to do if things
" don't Just Work).  After getting this plugin happily installed, any time you
" use :colorscheme it will do its magic and make the colorscheme Just Work.
"
" Whenever you change colorschemes using the :colorscheme command this script
" will be executed.  It will take the colors that the scheme specified for use
" in the GUI and use an approximation algorithm to try to gracefully degrade
" them to the closest color available in your terminal.  If you are running in
" a GUI or if your terminal doesn't support 88 or 256 colors, no changes are
" made.  Also, no changes will be made if the colorscheme seems to have been
" high color already.
"
" License:
" Copyright (c) 2009, Matthew J. Wozniski
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"     * Redistributions of source code must retain the above copyright notice,
"       this list of conditions and the following disclaimer.
"     * Redistributions in binary form must reproduce the above copyright
"       notice, this list of conditions and the following disclaimer in the
"       documentation and/or other materials provided with the distribution.
"     * The names of the contributors may not be used to endorse or promote
"       products derived from this software without specific prior written
"       permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
" OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
" OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
" NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT,
" INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
" LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
" OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
" LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
" NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
" EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

" {>1} Basic plugin setup

" {>2} Check preconditions
" Quit if the user doesn't want or need us or is missing the gui feature.  We
" need +gui to be able to check the gui color settings; vim doesn't bother to
" store them if it is not built with +gui.
if !has('gui') || exists('g:CSApprox_loaded')
  " XXX This depends upon knowing the default for g:CSApprox_verbose_level
  let s:verbose = 1
  if exists("g:CSApprox_verbose_level")
    let s:verbose  = g:CSApprox_verbose_level
  endif

  if ! has('gui') && s:verbose > 0
    echomsg "CSApprox needs gui support - not loading."
    echomsg "  See :help |csapprox-+gui| for possible workarounds."
  endif

  unlet s:verbose

  finish
endif

" {1} Mark us as loaded, and disable all compatibility options for now.
let g:CSApprox_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" {>1} Built-in approximation algorithm

" {>2} Cube definitions
let s:xterm_colors   = [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]
let s:eterm_colors   = [ 0x00, 0x2A, 0x55, 0x7F, 0xAA, 0xD4 ]
let s:konsole_colors = [ 0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF ]
let s:xterm_greys    = [ 0x08, 0x12, 0x1C, 0x26, 0x30, 0x3A,
                       \ 0x44, 0x4E, 0x58, 0x62, 0x6C, 0x76,
                       \ 0x80, 0x8A, 0x94, 0x9E, 0xA8, 0xB2,
                       \ 0xBC, 0xC6, 0xD0, 0xDA, 0xE4, 0xEE ]

let s:urxvt_colors   = [ 0x00, 0x8B, 0xCD, 0xFF ]
let s:urxvt_greys    = [ 0x2E, 0x5C, 0x73, 0x8B,
                       \ 0xA2, 0xB9, 0xD0, 0xE7 ]

" {>2} Integer comparator
" Used to sort the complete list of possible colors
function! s:IntCompare(i1, i2)
  return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunc

" {>2} Approximator
" Takes 3 decimal values for r, g, and b, and returns the closest cube number.
" Uses &term to determine which cube should be used, though if &term is set to
" "xterm" or begins with "screen", the variables g:CSApprox_eterm and
" g:CSApprox_konsole can be used to select a different palette.
"
" This approximator considers closeness based upon the individiual components.
" For each of r, g, and b, it finds the closest cube component available on
" the cube.  If the three closest matches can combine to form a valid color,
" this color is used, otherwise we repeat the search with the greys removed,
" meaning that the three new matches must make a valid color when combined.
function! s:ApproximatePerComponent(r,g,b)
  let hex = printf("%02x%02x%02x", a:r, a:g, a:b)

  let greys  = (&t_Co == 88 ? s:urxvt_greys : s:xterm_greys)

  if &t_Co == 88
    let colors = s:urxvt_colors
    let type = 'urxvt'
  elseif ((&term ==# 'xterm' || &term =~# '^screen' || &term==# 'builtin_gui')
       \   && exists('g:CSApprox_konsole') && g:CSApprox_konsole)
       \ || &term =~? '^konsole'
    let colors = s:konsole_colors
    let type = 'konsole'
  elseif ((&term ==# 'xterm' || &term =~# '^screen' || &term==# 'builtin_gui')
       \   && exists('g:CSApprox_eterm') && g:CSApprox_eterm)
       \ || &term =~? '^eterm'
    let colors = s:eterm_colors
    let type = 'eterm'
  else
    let colors = s:xterm_colors
    let type = 'xterm'
  endif

  if !exists('s:approximator_cache_'.type)
    let s:approximator_cache_{type} = {}
  endif

  let rv = get(s:approximator_cache_{type}, hex, -1)
  if rv != -1
    return rv
  endif

  " Only obtain sorted list once
  if !exists("s:".type."_greys_colors")
    let s:{type}_greys_colors = sort(greys + colors, "s:IntCompare")
  endif

  let greys_colors = s:{type}_greys_colors

  let r = s:NearestElemInList(a:r, greys_colors)
  let g = s:NearestElemInList(a:g, greys_colors)
  let b = s:NearestElemInList(a:b, greys_colors)

  let len = len(colors)
  if (r == g && g == b && index(greys, r) != -1)
    let rv = 16 + len * len * len + index(greys, r)
  else
    let r = s:NearestElemInList(a:r, colors)
    let g = s:NearestElemInList(a:g, colors)
    let b = s:NearestElemInList(a:b, colors)
    let rv = index(colors, r) * len * len
         \ + index(colors, g) * len
         \ + index(colors, b)
         \ + 16
  endif

  let s:approximator_cache_{type}[hex] = rv
  return rv
endfunction

" {>2} Color comparator
" Finds the nearest element to the given element in the given list
function! s:NearestElemInList(elem, list)
  let len = len(a:list)
  for i in range(len-1)
    if (a:elem <= (a:list[i] + a:list[i+1]) / 2)
      return a:list[i]
    endif
  endfor
  return a:list[len-1]
endfunction

" {>1} Collect info for the set highlights

" {>2} Determine if synIDattr is usable
" synIDattr() couldn't support 'guisp' until 7.2.052.  This function returns
" true if :redir is needed to find the 'guisp' attribute, false if synIDattr()
" is functional.  This test can be overridden by setting the global variable
" g:CSApprox_redirfallback to 1 (to force use of :redir) or to 0 (to force use
" of synIDattr()).
function! s:NeedRedirFallback()
  if !exists("g:CSApprox_redirfallback")
    let g:CSApprox_redirfallback = (v:version == 702 && !has('patch52'))
                                 \  || v:version < 702
  endif
  return g:CSApprox_redirfallback
endfunction

" {>2} Collect and store the highlights
" Get a dictionary containing information for every highlight group not merely
" linked to another group.  Return value is a dictionary, with highlight group
" numbers for keys and values that are dictionaries with four keys each,
" 'name', 'term', 'cterm', and 'gui'.  'name' holds the group name, and each
" of the others holds highlight information for that particular mode.
function! s:Highlights(modes)
  let rv = {}

  let i = 0
  while 1
    let i += 1

    " Only interested in groups that exist and aren't linked
    if synIDtrans(i) == 0
      break
    endif

    " Handle vim bug allowing groups with name == "" to be created
    if synIDtrans(i) != i || len(synIDattr(i, "name")) == 0
      continue
    endif

    let rv[i] = {}
    let rv[i].name = synIDattr(i, "name")

    for where in a:modes
      let rv[i][where]  = {}
      for attr in [ "bold", "italic", "reverse", "underline", "undercurl" ]
        let rv[i][where][attr] = synIDattr(i, attr, where)
      endfor

      for attr in [ "fg", "bg" ]
        let rv[i][where][attr] = synIDattr(i, attr.'#', where)
      endfor

      if where == "gui"
        let rv[i][where]["sp"] = s:SynGuiSp(i, rv[i].name)
      else
        let rv[i][where]["sp"] = -1
      endif

      for attr in [ "fg", "bg", "sp" ]
        if rv[i][where][attr] == -1
          let rv[i][where][attr] = ''
        endif
      endfor
    endfor
  endwhile

  return rv
endfunction

" {>2} Retrieve guisp

" Get guisp using whichever method is specified by _redir_fallback
function! s:SynGuiSp(idx, name)
  if !s:NeedRedirFallback()
    return s:SynGuiSpAttr(a:idx)
  else
    return s:SynGuiSpRedir(a:name)
  endif
endfunction

" {>3} Implementation for retrieving guisp with redir hack
function! s:SynGuiSpRedir(name)
  redir => temp
  exe 'sil hi ' . a:name
  redir END
  let temp = matchstr(temp, 'guisp=\zs.*')
  if len(temp) == 0 || temp[0] =~ '\s'
    let temp = ""
  else
    " Make sure we can handle guisp='dark red'
    let temp = substitute(temp, '[\x00].*', '', '')
    let temp = substitute(temp, '\s*\(c\=term\|gui\).*', '', '')
    let temp = substitute(temp, '\s*$', '', '')
  endif
  return temp
endfunction

" {>3} Implementation for retrieving guisp with synIDattr()
function! s:SynGuiSpAttr(idx)
  return synIDattr(a:idx, 'sp#', 'gui')
endfunction

" {>1} Handle color names

" Place to store rgb.txt name to color mappings - lazy loaded if needed
let s:rgb = {}

" {>2} Builtin gui color names
" gui_x11.c and gui_gtk_x11.c have some default colors names that are searched
" if the x server doesn't know about a color.  If 'showrgb' is available,
" we'll default to using these color names and values, and overwrite them with
" other values if 'showrgb' tells us about those colors.
let s:rgb_defaults = { "lightred"     : "#FFBBBB",
                     \ "lightgreen"   : "#88FF88",
                     \ "lightmagenta" : "#FFBBFF",
                     \ "darkcyan"     : "#008888",
                     \ "darkblue"     : "#0000BB",
                     \ "darkred"      : "#BB0000",
                     \ "darkmagenta"  : "#BB00BB",
                     \ "darkgrey"     : "#BBBBBB",
                     \ "darkyellow"   : "#BBBB00",
                     \ "gray10"       : "#1A1A1A",
                     \ "grey10"       : "#1A1A1A",
                     \ "gray20"       : "#333333",
                     \ "grey20"       : "#333333",
                     \ "gray30"       : "#4D4D4D",
                     \ "grey30"       : "#4D4D4D",
                     \ "gray40"       : "#666666",
                     \ "grey40"       : "#666666",
                     \ "gray50"       : "#7F7F7F",
                     \ "grey50"       : "#7F7F7F",
                     \ "gray60"       : "#999999",
                     \ "grey60"       : "#999999",
                     \ "gray70"       : "#B3B3B3",
                     \ "grey70"       : "#B3B3B3",
                     \ "gray80"       : "#CCCCCC",
                     \ "grey80"       : "#CCCCCC",
                     \ "gray90"       : "#E5E5E5",
                     \ "grey90"       : "#E5E5E5" }

" {>2} Colors that vim will use by name in one of the default schemes, either
" for bg=light or for bg=dark.  This lets us avoid loading the entire rgb.txt
" database when the scheme itself doesn't ask for colors by name.
let s:rgb_presets = { "black"         : "#000000",
                     \ "blue"         : "#0000ff",
                     \ "brown"        : "#a52a2a",
                     \ "cyan"         : "#00ffff",
                     \ "darkblue"     : "#00008b",
                     \ "darkcyan"     : "#008b8b",
                     \ "darkgrey"     : "#a9a9a9",
                     \ "darkmagenta"  : "#8b008b",
                     \ "green"        : "#00ff00",
                     \ "grey"         : "#bebebe",
                     \ "grey40"       : "#666666",
                     \ "grey90"       : "#e5e5e5",
                     \ "lightblue"    : "#add8e6",
                     \ "lightcyan"    : "#e0ffff",
                     \ "lightgrey"    : "#d3d3d3",
                     \ "lightmagenta" : "#ffbbff",
                     \ "magenta"      : "#ff00ff",
                     \ "red"          : "#ff0000",
                     \ "seagreen"     : "#2e8b57",
                     \ "white"        : "#ffffff",
                     \ "yellow"       : "#ffff00" }

" {>2} Find available color names
" Find the valid named colors.  By default, use our own rgb list, but try to
" retrieve the system's list if g:CSApprox_use_showrgb is set to true.  Store
" the color names and color values to the dictionary s:rgb - the keys are
" color names (in lowercase), the values are strings representing color values
" (as '#rrggbb').
function! s:UpdateRgbHash()
  try
    if !exists("g:CSApprox_use_showrgb") || !g:CSApprox_use_showrgb
      throw "Not using showrgb"
    endif

    " We want to use the 'showrgb' program, if it's around
    let lines = split(system('showrgb'), '\n')

    if v:shell_error || !exists('lines') || empty(lines)
      throw "'showrgb' didn't give us an rgb.txt"
    endif

    let s:rgb = copy(s:rgb_defaults)

    " fmt is (blanks?)(red)(blanks)(green)(blanks)(blue)(blanks)(name)
    let parsepat  = '^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(\d\+\)\s\+\(.*\)$'

    for line in lines
      let v = matchlist(line, parsepat)
      if len(v) < 0
        throw "CSApprox: Bad RGB line: " . string(line)
      endif
      let s:rgb[tolower(v[4])] = printf("#%02x%02x%02x", v[1], v[2], v[3])
    endfor
  catch
    try
      let s:rgb = csapprox#rgb()
    catch
      echohl ErrorMsg
      echomsg "Can't call rgb() from autoload/csapprox.vim"
      echomsg "Named colors will not be available!"
      echohl None
    endtry
  endtry

  return 0
endfunction

" {>1} Derive and set cterm attributes

" {>2} Attribute overrides
" Allow the user to override a specified attribute with another attribute.
" For example, the default is to map 'italic' to 'underline' (since many
" terminals cannot display italic text, and gvim itself will replace italics
" with underlines where italicizing is impossible), and to replace 'sp' with
" 'fg' (since terminals can't use one color for the underline and another for
" the foreground, we color the entire word).  This default can of course be
" overridden by the user, by setting g:CSApprox_attr_map.  This map must be
" a dictionary of string keys, representing the same attributes that synIDattr
" can look up, to string values, representing the attribute mapped to or an
" empty string to disable the given attribute entirely.
function! s:attr_map(attr)
  let rv = get(g:CSApprox_attr_map, a:attr, a:attr)

  return rv
endfunction

function! s:NormalizeAttrMap(map)
  let old = copy(a:map)
  let new = filter(a:map, '0')

  let valid_attrs = [ 'bg', 'fg', 'sp', 'bold', 'italic',
                    \ 'reverse', 'underline', 'undercurl' ]

  let colorattrs = [ 'fg', 'bg', 'sp' ]

  for olhs in keys(old)
    if olhs ==? 'inverse'
      let nlhs = 'reverse'
    endif

    let orhs = old[olhs]

    if orhs ==? 'inverse'
      let nrhs = 'reverse'
    endif

    let nlhs = tolower(olhs)
    let nrhs = tolower(orhs)

    try
      if index(valid_attrs, nlhs) == -1
        echomsg "CSApprox: Bad attr map (removing unrecognized attribute " . olhs . ")"
      elseif nrhs != '' && index(valid_attrs, nrhs) == -1
        echomsg "CSApprox: Bad attr map (removing unrecognized attribute " . orhs . ")"
      elseif nrhs != '' && !!(index(colorattrs, nlhs)+1) != !!(index(colorattrs, nrhs)+1)
        echomsg "CSApprox: Bad attr map (removing " . olhs . "; type mismatch with " . orhs . ")"
      elseif nrhs == 'sp'
        echomsg "CSApprox: Bad attr map (removing " . olhs . "; can't map to 'sp')"
      else
        let new[nlhs] = nrhs
      endif
    catch
      echo v:exception
    endtry
  endfor
endfunction

" {>2} Normalize the GUI settings of a highlight group
" If the Normal group is cleared, set it to gvim's default, black on white
" Though this would be a really weird thing for a scheme to do... *shrug*
function! s:FixupGuiInfo(highlights)
  if a:highlights[s:hlid_normal].gui.bg == ''
    let a:highlights[s:hlid_normal].gui.bg = 'white'
  endif

  if a:highlights[s:hlid_normal].gui.fg == ''
    let a:highlights[s:hlid_normal].gui.fg = 'black'
  endif
endfunction

" {>2} Map gui settings to cterm settings
" Given information about a highlight group, replace the cterm settings with
" the mapped gui settings, applying any attribute overrides along the way.  In
" particular, this gives special treatment to the 'reverse' attribute and the
" 'guisp' attribute.  In particular, if the 'reverse' attribute is set for
" gvim, we unset it for the terminal and instead set ctermfg to match guibg
" and vice versa, since terminals can consider a 'reverse' flag to mean using
" default-bg-on-default-fg instead of current-bg-on-current-fg.  We also
" ensure that the 'sp' attribute is never set for cterm, since no terminal can
" handle that particular highlight.  If the user wants to display the guisp
" color, he should map it to either 'fg' or 'bg' using g:CSApprox_attr_map.
function! s:FixupCtermInfo(highlights)
  for hl in values(a:highlights)

    if !has_key(hl, 'cterm')
      let hl["cterm"] = {}
    endif

    " Find attributes to be set in the terminal
    for attr in [ "bold", "italic", "reverse", "underline", "undercurl" ]
      let hl.cterm[attr] = ''
      if hl.gui[attr] == 1
        if s:attr_map(attr) != ''
          let hl.cterm[ s:attr_map(attr) ] = 1
        endif
      endif
    endfor

    for color in [ "bg", "fg" ]
      let eff_color = color
      if hl.cterm['reverse']
        let eff_color = (color == 'bg' ? 'fg' : 'bg')
      endif

      let hl.cterm[color] = get(hl.gui, s:attr_map(eff_color), '')
    endfor

    if hl.gui['sp'] != '' && s:attr_map('sp') != ''
      let hl.cterm[s:attr_map('sp')] = hl.gui['sp']
    endif

    if hl.cterm['reverse'] && hl.cterm.bg == ''
      let hl.cterm.bg = 'fg'
    endif

    if hl.cterm['reverse'] && hl.cterm.fg == ''
      let hl.cterm.fg = 'bg'
    endif

    if hl.cterm['reverse']
      let hl.cterm.reverse = ''
    endif
  endfor
endfunction

" {>2} Set cterm colors for a highlight group
" Given the information for a single highlight group (ie, the value of
" one of the items in s:Highlights() already normalized with s:FixupCtermInfo
" and s:FixupGuiInfo), handle matching the gvim colors to the closest cterm
" colors by calling the appropriate approximator as specified with the
" g:CSApprox_approximator_function variable and set the colors and attributes
" appropriately to match the gui.
function! s:SetCtermFromGui(hl)
  let hl = a:hl

  " Set up the default approximator function, if needed
  if !exists("g:CSApprox_approximator_function")
    let g:CSApprox_approximator_function=function("s:ApproximatePerComponent")
  endif

  " Clear existing highlights
  exe 'hi ' . hl.name . ' cterm=NONE ctermbg=NONE ctermfg=NONE'

  for which in [ 'bg', 'fg' ]
    let val = hl.cterm[which]

    " Skip unset colors
    if val == -1 || val == ""
      continue
    endif

    " Try translating anything but 'fg', 'bg', #rrggbb, and rrggbb from an
    " rgb.txt color to a #rrggbb color
    if val !~? '^[fb]g$' && val !~ '^#\=\x\{6}$'
      try
        " First see if it is in our preset-by-vim rgb list
        let val = s:rgb_presets[tolower(val)]
      catch
        " Then try loading and checking our real rgb list
        if empty(s:rgb)
          call s:UpdateRgbHash()
        endif
        try
          let val = s:rgb[tolower(val)]
        catch
          " And then barf if we still haven't found it
          if &verbose
            echomsg "CSApprox: Colorscheme uses unknown color \"" . val . "\""
          endif
          continue
        endtry
      endtry
    endif

    if val =~? '^[fb]g$'
      exe 'hi ' . hl.name . ' cterm' . which . '=' . val
      let hl.cterm[which] = val
    elseif val =~ '^#\=\x\{6}$'
      let val = substitute(val, '^#', '', '')
      let r = str2nr(val[0:1], 16)
      let g = str2nr(val[2:3], 16)
      let b = str2nr(val[4:5], 16)
      let hl.cterm[which] = g:CSApprox_approximator_function(r, g, b)
      exe 'hi ' . hl.name . ' cterm' . which . '=' . hl.cterm[which]
    else
      throw "Internal error handling color: " . val
    endif
  endfor

  " Finally, set the attributes
  let attrs = [ 'bold', 'italic', 'underline', 'undercurl' ]
  call filter(attrs, 'hl.cterm[v:val] == 1')

  if !empty(attrs)
    exe 'hi ' . hl.name . ' cterm=' . join(attrs, ',')
  endif
endfunction


" {>1} Top-level control

" Cache the highlight ID of the normal group; it's used often and won't change
let s:hlid_normal = hlID('Normal')

" {>2} Builtin cterm color names above 15
" Vim defines some color name to high color mappings internally (see
" syntax.c:do_highlight).  Since we don't want to overwrite a colorscheme that
" was actually written for a high color terminal with our choices, but have no
" way to tell if a colorscheme was written for a high color terminal, we fall
" back on guessing.  If any highlight group has a cterm color set to 16 or
" higher, we assume that the user has used a high color colorscheme - unless
" that color is one of the below, which vim can set internally when a color is
" requested by name.
let s:presets_88  = []
let s:presets_88 += [32] " Brown
let s:presets_88 += [72] " DarkYellow
let s:presets_88 += [84] " Gray
let s:presets_88 += [84] " Grey
let s:presets_88 += [82] " DarkGray
let s:presets_88 += [82] " DarkGrey
let s:presets_88 += [43] " LightBlue
let s:presets_88 += [61] " LightGreen
let s:presets_88 += [63] " LightCyan
let s:presets_88 += [74] " LightRed
let s:presets_88 += [75] " LightMagenta
let s:presets_88 += [78] " LightYellow

let s:presets_256  = []
let s:presets_256 += [130] " Brown
let s:presets_256 += [130] " DarkYellow
let s:presets_256 += [248] " Gray
let s:presets_256 += [248] " Grey
let s:presets_256 += [242] " DarkGray
let s:presets_256 += [242] " DarkGrey
let s:presets_256 += [ 81] " LightBlue
let s:presets_256 += [121] " LightGreen
let s:presets_256 += [159] " LightCyan
let s:presets_256 += [224] " LightRed
let s:presets_256 += [225] " LightMagenta
let s:presets_256 += [229] " LightYellow

" {>2} Wrapper around :exe to allow :executing multiple commands.
" "cmd" is the command to be :executed.
" If the variable is a String, it is :executed.
" If the variable is a List, each element is :executed.
function! s:exe(cmd)
  if type(a:cmd) == type('')
    exe a:cmd
  else
    for cmd in a:cmd
      call s:exe(cmd)
    endfor
  endif
endfunction

" {>2} Function to handle hooks
" Prototype: HandleHooks(type [, scheme])
" "type" is the type of hook to be executed, ie. "pre" or "post"
" "scheme" is the name of the colorscheme that is currently active, if known
"
" If the variables g:CSApprox_hook_{type} and g:CSApprox_hook_{scheme}_{type}
" exist, this will :execute them in that order.  If one does not exist, it
" will silently be ignored.
"
" If the scheme name contains characters that are invalid in a variable name,
" they will simply be removed.  Ie, g:colors_name = "123 foo_bar-baz456"
" becomes "foo_barbaz456"
"
" NOTE: Exceptions will be printed out, rather than end processing early.  The
" rationale is that it is worse for the user to fix the hook in an editor with
" broken colors.  :)
function! s:HandleHooks(type, ...)
  let type = a:type
  let scheme = (a:0 == 1 ? a:1 : "")
  let scheme = substitute(scheme, '[^[:alnum:]_]', '', 'g')
  let scheme = substitute(scheme, '^\d\+', '', '')

  for cmd in [ 'g:CSApprox_hook_' . type,
             \ 'g:CSApprox_' . scheme . '_hook_' . type,
             \ 'g:CSApprox_hook_' . scheme . '_' . type ]
    if exists(cmd)
      try
        call s:exe(eval(cmd))
      catch
        echomsg "Error processing " . cmd . ":"
        echomsg v:exception
      endtry
    endif
  endfor
endfunction

" {>2} Main function
" Wrapper around the actual implementation to make it easier to ensure that
" all temporary settings are restored by the time we return, whether or not
" something was thrown.  Additionally, sets the 'verbose' option to the max of
" g:CSApprox_verbose_level (default 1) and &verbose for the duration of the
" main function.  This allows us to default to a message whenever any error,
" even a recoverable one, occurs, meaning the user quickly finds out when
" something's wrong, but makes it very easy for the user to make us silent.
function! s:CSApprox()
  try
    let savelz  = &lz

    set lz

    if exists("g:CSApprox_attr_map") && type(g:CSApprox_attr_map) == type({})
      call s:NormalizeAttrMap(g:CSApprox_attr_map)
    else
      let g:CSApprox_attr_map = { 'italic' : 'underline', 'sp' : 'fg' }
    endif

    " colors_name must be unset and reset, or vim will helpfully reload the
    " colorscheme when we set the background for the Normal group.
    " See the help entries ':hi-normal-cterm' and 'g:colors_name'
    if exists("g:colors_name")
      let colors_name = g:colors_name
      unlet g:colors_name
    endif

    " Similarly, the global variable "syntax_cmd" must be set to something vim
    " doesn't recognize, lest vim helpfully switch all colors back to the
    " default whenever the Normal group is changed (in syncolor.vim)...
    if exists("g:syntax_cmd")
      let syntax_cmd = g:syntax_cmd
    endif
    let g:syntax_cmd = "PLEASE DON'T CHANGE ANY COLORS!!!"

    " Set up our verbosity level, if needed.
    " Default to 1, so the user can know if something's wrong.
    if !exists("g:CSApprox_verbose_level")
      let g:CSApprox_verbose_level = 1
    endif

    call s:HandleHooks("pre", (exists("colors_name") ? colors_name : ""))

    " Set 'verbose' set to the maximum of &verbose and CSApprox_verbose_level
    exe max([&vbs, g:CSApprox_verbose_level]) 'verbose call s:CSApproxImpl()'

    call s:HandleHooks("post", (exists("colors_name") ? colors_name : ""))
  finally
    if exists("colors_name")
      let g:colors_name = colors_name
    endif

    unlet g:syntax_cmd
    if exists("syntax_cmd")
      let g:syntax_cmd = syntax_cmd
    endif

    let &lz   = savelz
  endtry
endfunction

" {>2} CSApprox implementation
" Verifies that the user has not started the gui, and that vim recognizes his
" terminal as having enough colors for us to go on, then gathers the existing
" highlights and sets the cterm colors to match the gui colors for all those
" highlights (unless the colorscheme was already high-color).
function! s:CSApproxImpl()
  " Return if not running in an 88/256 color terminal
  if &t_Co != 256 && &t_Co != 88
    if &verbose && !has('gui_running')
      echomsg "CSApprox skipped; terminal only has" &t_Co "colors, not 88/256"
      echomsg "Try checking :help csapprox-terminal for workarounds"
    endif

    return
  endif

  " Get the current highlight colors
  let highlights = s:Highlights(["gui"])

  let hinums = keys(highlights)

  " Make sure that the script is not already 256 color by checking to make
  " sure that no groups are set to a value above 256, unless the color they're
  " set to can be set internally by vim (gotten by scraping
  " color_numbers_{88,256} in syntax.c:do_highlight)
  "
  " XXX: s:inhibit_hicolor_test allows this test to be skipped for snapshots
  if !exists("s:inhibit_hicolor_test") || !s:inhibit_hicolor_test
    for hlid in hinums
      for type in [ 'bg', 'fg' ]
        let color = synIDattr(hlid, type, 'cterm')

        if color > 15 && index(s:presets_{&t_Co}, str2nr(color)) < 0
          " The value is set above 15, and wasn't set by vim.
          if &verbose >= 2
            echomsg 'CSApprox: Exiting - high' type 'color found for' highlights[hlid].name
          endif
          return
        endif
      endfor
    endfor
  endif

  call s:FixupGuiInfo(highlights)
  call s:FixupCtermInfo(highlights)

  " We need to set the Normal group first so 'bg' and 'fg' work as colors
  call insert(hinums, remove(hinums, index(hinums, string(s:hlid_normal))))

  " then set each color's cterm attributes to match gui
  for hlid in hinums
    call s:SetCtermFromGui(highlights[hlid])
  endfor
endfunction

" {>2} Write out the current colors to an 88/256 color colorscheme file.
" "file" - destination filename
" "overwrite" - overwrite an existing file
function! s:CSApproxSnapshot(file, overwrite)
  let force = a:overwrite
  let file = fnamemodify(a:file, ":p")

  if empty(file)
    throw "Bad file name: \"" . file . "\""
  elseif (filewritable(fnamemodify(file, ':h')) != 2)
    throw "Cannot write to directory \"" . fnamemodify(file, ':h') . "\""
  elseif (glob(file) || filereadable(file)) && !force
    " TODO - respect 'confirm' here and prompt if it's set.
    echohl ErrorMsg
    echomsg "E13: File exists (add ! to override)"
    echohl None
    return
  endif

  " Sigh... This is basically a bug, but one that I have no chance of fixing.
  " Vim decides that Pmenu should be highlighted in 'LightMagenta' in terminal
  " vim and as 'Magenta' in gvim...  And I can't ask it what color it actually
  " *wants*.  As far as I can see, there's no way for me to learn that
  " I should output 'Magenta' when 'LightMagenta' is provided by vim for the
  " terminal.
  if !has('gui_running')
    echohl WarningMsg
    echomsg "Warning: The written colorscheme may have incorrect colors"
    echomsg "         when CSApproxSnapshot is used in terminal vim!"
    echohl None
  endif

  let save_t_Co = &t_Co
  let s:inhibit_hicolor_test = 1
  if exists("g:CSApprox_konsole")
    let save_CSApprox_konsole = g:CSApprox_konsole
  endif
  if exists("g:CSApprox_eterm")
    let save_CSApprox_eterm = g:CSApprox_eterm
  endif

  " Needed just like in CSApprox()
  if exists("g:colors_name")
    let colors_name = g:colors_name
    unlet g:colors_name
  endif

  " Needed just like in CSApprox()
  if exists("g:syntax_cmd")
    let syntax_cmd = g:syntax_cmd
  endif
  let g:syntax_cmd = "PLEASE DON'T CHANGE ANY COLORS!!!"

  try
    let lines = []
    let lines += [ '" This scheme was created by CSApproxSnapshot' ]
    let lines += [ '" on ' . strftime("%a, %d %b %Y") ]
    let lines += [ '' ]
    let lines += [ 'hi clear' ]
    let lines += [ 'if exists("syntax_on")' ]
    let lines += [ '    syntax reset' ]
    let lines += [ 'endif' ]
    let lines += [ '' ]
    let lines += [ 'if v:version < 700' ]
    let lines += [ '    let g:colors_name = expand("<sfile>:t:r")' ]
    let lines += [ '    command! -nargs=+ CSAHi exe "hi" substitute(substitute(<q-args>, "undercurl", "underline", "g"), "guisp\\S\\+", "", "g")' ]
    let lines += [ 'else' ]
    let lines += [ '    let g:colors_name = expand("<sfile>:t:r")' ]
    let lines += [ '    command! -nargs=+ CSAHi exe "hi" <q-args>' ]
    let lines += [ 'endif' ]
    let lines += [ '' ]

    let lines += [ 'if 0' ]
    for round in [ 'konsole', 'eterm', 'xterm', 'urxvt' ]
      sil! unlet g:CSApprox_eterm
      sil! unlet g:CSApprox_konsole

      if round == 'konsole'
        let g:CSApprox_konsole = 1
      elseif round == 'eterm'
        let g:CSApprox_eterm = 1
      endif

      if round == 'urxvt'
        set t_Co=88
      else
        set t_Co=256
      endif

      call s:CSApprox()

      let highlights = s:Highlights(["term", "cterm", "gui"])
      call s:FixupGuiInfo(highlights)

      if round == 'konsole' || round == 'eterm'
        let lines += [ 'elseif has("gui_running") || (&t_Co == ' . &t_Co
                   \ . ' && (&term ==# "xterm" || &term =~# "^screen")'
                   \ . ' && exists("g:CSApprox_' . round . '")'
                   \ . ' && g:CSApprox_' . round . ')'
                   \ . ' || &term =~? "^' . round . '"' ]
      else
        let lines += [ 'elseif has("gui_running") || &t_Co == ' . &t_Co ]
      endif

      let hinums = keys(highlights)

      call insert(hinums, remove(hinums, index(hinums, string(s:hlid_normal))))

      for hlnum in hinums
        let hl = highlights[hlnum]
        let line = '    CSAHi ' . hl.name
        for type in [ 'term', 'cterm', 'gui' ]
          let attrs = [ 'reverse', 'bold', 'italic', 'underline', 'undercurl' ]
          call filter(attrs, 'hl[type][v:val] == 1')
          let line .= ' ' . type . '=' . (empty(attrs) ? 'NONE' : join(attrs, ','))
          if type != 'term'
            let line .= ' ' . type . 'bg=' . (len(hl[type].bg) ? hl[type].bg : 'bg')
            let line .= ' ' . type . 'fg=' . (len(hl[type].fg) ? hl[type].fg : 'fg')
            if type == 'gui' && hl.gui.sp !~ '^\s*$'
              let line .= ' ' . type . 'sp=' . hl[type].sp
            endif
          endif
        endfor
        let lines += [ line ]
      endfor
    endfor
    let lines += [ 'endif' ]
    let lines += [ '' ]
    let lines += [ 'if 1' ]
    let lines += [ '    delcommand CSAHi' ]
    let lines += [ 'endif' ]
    call writefile(lines, file)
  finally
    let &t_Co = save_t_Co

    if exists("save_CSApprox_konsole")
      let g:CSApprox_konsole = save_CSApprox_konsole
    endif
    if exists("save_CSApprox_eterm")
      let g:CSApprox_eterm = save_CSApprox_eterm
    endif

    if exists("colors_name")
      let g:colors_name = colors_name
    endif

    unlet g:syntax_cmd
    if exists("syntax_cmd")
      let g:syntax_cmd = syntax_cmd
    endif

    call s:CSApprox()

    unlet s:inhibit_hicolor_test
  endtry
endfunction

" {>2} Snapshot user command
command! -bang -nargs=1 -complete=file -bar CSApproxSnapshot
        \ call s:CSApproxSnapshot(<f-args>, strlen("<bang>"))

" {>1} Hooks

" {>2} Autocmds
" Set up an autogroup to hook us on the completion of any :colorscheme command
augroup CSApprox
  au!
  au ColorScheme * call s:CSApprox()
  "au User CSApproxPost highlight Normal ctermbg=none | highlight NonText ctermbg=None
augroup END

" {>2} Execute
" The last thing to do when sourced is to run and actually fix up the colors.
if !has('gui_running')
  call s:CSApprox()
endif

" {>1} Restore compatibility options
let &cpo = s:savecpo
unlet s:savecpo


" {0} vim:sw=2:sts=2:et:fdm=expr:fde=substitute(matchstr(getline(v\:lnum),'^\\s*"\\s*{\\zs.\\{-}\\ze}'),'^$','=','')
autoload/csapprox.vim	[[[1
810
let s:rgb = {}

let s:rgb["alice blue"]             = "#f0f8ff"
let s:rgb["aliceblue"]              = "#f0f8ff"
let s:rgb["antique white"]          = "#faebd7"
let s:rgb["antiquewhite"]           = "#faebd7"
let s:rgb["antiquewhite1"]          = "#ffefdb"
let s:rgb["antiquewhite2"]          = "#eedfcc"
let s:rgb["antiquewhite3"]          = "#cdc0b0"
let s:rgb["antiquewhite4"]          = "#8b8378"
let s:rgb["aquamarine"]             = "#7fffd4"
let s:rgb["aquamarine1"]            = "#7fffd4"
let s:rgb["aquamarine2"]            = "#76eec6"
let s:rgb["aquamarine3"]            = "#66cdaa"
let s:rgb["aquamarine4"]            = "#458b74"
let s:rgb["azure"]                  = "#f0ffff"
let s:rgb["azure1"]                 = "#f0ffff"
let s:rgb["azure2"]                 = "#e0eeee"
let s:rgb["azure3"]                 = "#c1cdcd"
let s:rgb["azure4"]                 = "#838b8b"
let s:rgb["beige"]                  = "#f5f5dc"
let s:rgb["bisque"]                 = "#ffe4c4"
let s:rgb["bisque1"]                = "#ffe4c4"
let s:rgb["bisque2"]                = "#eed5b7"
let s:rgb["bisque3"]                = "#cdb79e"
let s:rgb["bisque4"]                = "#8b7d6b"
let s:rgb["black"]                  = "#000000"
let s:rgb["blanched almond"]        = "#ffebcd"
let s:rgb["blanchedalmond"]         = "#ffebcd"
let s:rgb["blue violet"]            = "#8a2be2"
let s:rgb["blue"]                   = "#0000ff"
let s:rgb["blue1"]                  = "#0000ff"
let s:rgb["blue2"]                  = "#0000ee"
let s:rgb["blue3"]                  = "#0000cd"
let s:rgb["blue4"]                  = "#00008b"
let s:rgb["blueviolet"]             = "#8a2be2"
let s:rgb["brown"]                  = "#a52a2a"
let s:rgb["brown1"]                 = "#ff4040"
let s:rgb["brown2"]                 = "#ee3b3b"
let s:rgb["brown3"]                 = "#cd3333"
let s:rgb["brown4"]                 = "#8b2323"
let s:rgb["burlywood"]              = "#deb887"
let s:rgb["burlywood1"]             = "#ffd39b"
let s:rgb["burlywood2"]             = "#eec591"
let s:rgb["burlywood3"]             = "#cdaa7d"
let s:rgb["burlywood4"]             = "#8b7355"
let s:rgb["cadet blue"]             = "#5f9ea0"
let s:rgb["cadetblue"]              = "#5f9ea0"
let s:rgb["cadetblue1"]             = "#98f5ff"
let s:rgb["cadetblue2"]             = "#8ee5ee"
let s:rgb["cadetblue3"]             = "#7ac5cd"
let s:rgb["cadetblue4"]             = "#53868b"
let s:rgb["chartreuse"]             = "#7fff00"
let s:rgb["chartreuse1"]            = "#7fff00"
let s:rgb["chartreuse2"]            = "#76ee00"
let s:rgb["chartreuse3"]            = "#66cd00"
let s:rgb["chartreuse4"]            = "#458b00"
let s:rgb["chocolate"]              = "#d2691e"
let s:rgb["chocolate1"]             = "#ff7f24"
let s:rgb["chocolate2"]             = "#ee7621"
let s:rgb["chocolate3"]             = "#cd661d"
let s:rgb["chocolate4"]             = "#8b4513"
let s:rgb["coral"]                  = "#ff7f50"
let s:rgb["coral1"]                 = "#ff7256"
let s:rgb["coral2"]                 = "#ee6a50"
let s:rgb["coral3"]                 = "#cd5b45"
let s:rgb["coral4"]                 = "#8b3e2f"
let s:rgb["cornflower blue"]        = "#6495ed"
let s:rgb["cornflowerblue"]         = "#6495ed"
let s:rgb["cornsilk"]               = "#fff8dc"
let s:rgb["cornsilk1"]              = "#fff8dc"
let s:rgb["cornsilk2"]              = "#eee8cd"
let s:rgb["cornsilk3"]              = "#cdc8b1"
let s:rgb["cornsilk4"]              = "#8b8878"
let s:rgb["cyan"]                   = "#00ffff"
let s:rgb["cyan1"]                  = "#00ffff"
let s:rgb["cyan2"]                  = "#00eeee"
let s:rgb["cyan3"]                  = "#00cdcd"
let s:rgb["cyan4"]                  = "#008b8b"
let s:rgb["dark blue"]              = "#00008b"
let s:rgb["dark cyan"]              = "#008b8b"
let s:rgb["dark goldenrod"]         = "#b8860b"
let s:rgb["dark gray"]              = "#a9a9a9"
let s:rgb["dark green"]             = "#006400"
let s:rgb["dark grey"]              = "#a9a9a9"
let s:rgb["dark khaki"]             = "#bdb76b"
let s:rgb["dark magenta"]           = "#8b008b"
let s:rgb["dark olive green"]       = "#556b2f"
let s:rgb["dark orange"]            = "#ff8c00"
let s:rgb["dark orchid"]            = "#9932cc"
let s:rgb["dark red"]               = "#8b0000"
let s:rgb["dark salmon"]            = "#e9967a"
let s:rgb["dark sea green"]         = "#8fbc8f"
let s:rgb["dark slate blue"]        = "#483d8b"
let s:rgb["dark slate gray"]        = "#2f4f4f"
let s:rgb["dark slate grey"]        = "#2f4f4f"
let s:rgb["dark turquoise"]         = "#00ced1"
let s:rgb["dark violet"]            = "#9400d3"
let s:rgb["dark yellow"]            = "#bbbb00"
let s:rgb["darkblue"]               = "#00008b"
let s:rgb["darkcyan"]               = "#008b8b"
let s:rgb["darkgoldenrod"]          = "#b8860b"
let s:rgb["darkgoldenrod1"]         = "#ffb90f"
let s:rgb["darkgoldenrod2"]         = "#eead0e"
let s:rgb["darkgoldenrod3"]         = "#cd950c"
let s:rgb["darkgoldenrod4"]         = "#8b6508"
let s:rgb["darkgray"]               = "#a9a9a9"
let s:rgb["darkgreen"]              = "#006400"
let s:rgb["darkgrey"]               = "#a9a9a9"
let s:rgb["darkkhaki"]              = "#bdb76b"
let s:rgb["darkmagenta"]            = "#8b008b"
let s:rgb["darkolivegreen"]         = "#556b2f"
let s:rgb["darkolivegreen1"]        = "#caff70"
let s:rgb["darkolivegreen2"]        = "#bcee68"
let s:rgb["darkolivegreen3"]        = "#a2cd5a"
let s:rgb["darkolivegreen4"]        = "#6e8b3d"
let s:rgb["darkorange"]             = "#ff8c00"
let s:rgb["darkorange1"]            = "#ff7f00"
let s:rgb["darkorange2"]            = "#ee7600"
let s:rgb["darkorange3"]            = "#cd6600"
let s:rgb["darkorange4"]            = "#8b4500"
let s:rgb["darkorchid"]             = "#9932cc"
let s:rgb["darkorchid1"]            = "#bf3eff"
let s:rgb["darkorchid2"]            = "#b23aee"
let s:rgb["darkorchid3"]            = "#9a32cd"
let s:rgb["darkorchid4"]            = "#68228b"
let s:rgb["darkred"]                = "#8b0000"
let s:rgb["darksalmon"]             = "#e9967a"
let s:rgb["darkseagreen"]           = "#8fbc8f"
let s:rgb["darkseagreen1"]          = "#c1ffc1"
let s:rgb["darkseagreen2"]          = "#b4eeb4"
let s:rgb["darkseagreen3"]          = "#9bcd9b"
let s:rgb["darkseagreen4"]          = "#698b69"
let s:rgb["darkslateblue"]          = "#483d8b"
let s:rgb["darkslategray"]          = "#2f4f4f"
let s:rgb["darkslategray1"]         = "#97ffff"
let s:rgb["darkslategray2"]         = "#8deeee"
let s:rgb["darkslategray3"]         = "#79cdcd"
let s:rgb["darkslategray4"]         = "#528b8b"
let s:rgb["darkslategrey"]          = "#2f4f4f"
let s:rgb["darkturquoise"]          = "#00ced1"
let s:rgb["darkviolet"]             = "#9400d3"
let s:rgb["darkyellow"]             = "#bbbb00"
let s:rgb["deep pink"]              = "#ff1493"
let s:rgb["deep sky blue"]          = "#00bfff"
let s:rgb["deeppink"]               = "#ff1493"
let s:rgb["deeppink1"]              = "#ff1493"
let s:rgb["deeppink2"]              = "#ee1289"
let s:rgb["deeppink3"]              = "#cd1076"
let s:rgb["deeppink4"]              = "#8b0a50"
let s:rgb["deepskyblue"]            = "#00bfff"
let s:rgb["deepskyblue1"]           = "#00bfff"
let s:rgb["deepskyblue2"]           = "#00b2ee"
let s:rgb["deepskyblue3"]           = "#009acd"
let s:rgb["deepskyblue4"]           = "#00688b"
let s:rgb["dim gray"]               = "#696969"
let s:rgb["dim grey"]               = "#696969"
let s:rgb["dimgray"]                = "#696969"
let s:rgb["dimgrey"]                = "#696969"
let s:rgb["dodger blue"]            = "#1e90ff"
let s:rgb["dodgerblue"]             = "#1e90ff"
let s:rgb["dodgerblue1"]            = "#1e90ff"
let s:rgb["dodgerblue2"]            = "#1c86ee"
let s:rgb["dodgerblue3"]            = "#1874cd"
let s:rgb["dodgerblue4"]            = "#104e8b"
let s:rgb["firebrick"]              = "#b22222"
let s:rgb["firebrick1"]             = "#ff3030"
let s:rgb["firebrick2"]             = "#ee2c2c"
let s:rgb["firebrick3"]             = "#cd2626"
let s:rgb["firebrick4"]             = "#8b1a1a"
let s:rgb["floral white"]           = "#fffaf0"
let s:rgb["floralwhite"]            = "#fffaf0"
let s:rgb["forest green"]           = "#228b22"
let s:rgb["forestgreen"]            = "#228b22"
let s:rgb["gainsboro"]              = "#dcdcdc"
let s:rgb["ghost white"]            = "#f8f8ff"
let s:rgb["ghostwhite"]             = "#f8f8ff"
let s:rgb["gold"]                   = "#ffd700"
let s:rgb["gold1"]                  = "#ffd700"
let s:rgb["gold2"]                  = "#eec900"
let s:rgb["gold3"]                  = "#cdad00"
let s:rgb["gold4"]                  = "#8b7500"
let s:rgb["goldenrod"]              = "#daa520"
let s:rgb["goldenrod1"]             = "#ffc125"
let s:rgb["goldenrod2"]             = "#eeb422"
let s:rgb["goldenrod3"]             = "#cd9b1d"
let s:rgb["goldenrod4"]             = "#8b6914"
let s:rgb["gray"]                   = "#bebebe"
let s:rgb["gray0"]                  = "#000000"
let s:rgb["gray1"]                  = "#030303"
let s:rgb["gray10"]                 = "#1a1a1a"
let s:rgb["gray100"]                = "#ffffff"
let s:rgb["gray11"]                 = "#1c1c1c"
let s:rgb["gray12"]                 = "#1f1f1f"
let s:rgb["gray13"]                 = "#212121"
let s:rgb["gray14"]                 = "#242424"
let s:rgb["gray15"]                 = "#262626"
let s:rgb["gray16"]                 = "#292929"
let s:rgb["gray17"]                 = "#2b2b2b"
let s:rgb["gray18"]                 = "#2e2e2e"
let s:rgb["gray19"]                 = "#303030"
let s:rgb["gray2"]                  = "#050505"
let s:rgb["gray20"]                 = "#333333"
let s:rgb["gray21"]                 = "#363636"
let s:rgb["gray22"]                 = "#383838"
let s:rgb["gray23"]                 = "#3b3b3b"
let s:rgb["gray24"]                 = "#3d3d3d"
let s:rgb["gray25"]                 = "#404040"
let s:rgb["gray26"]                 = "#424242"
let s:rgb["gray27"]                 = "#454545"
let s:rgb["gray28"]                 = "#474747"
let s:rgb["gray29"]                 = "#4a4a4a"
let s:rgb["gray3"]                  = "#080808"
let s:rgb["gray30"]                 = "#4d4d4d"
let s:rgb["gray31"]                 = "#4f4f4f"
let s:rgb["gray32"]                 = "#525252"
let s:rgb["gray33"]                 = "#545454"
let s:rgb["gray34"]                 = "#575757"
let s:rgb["gray35"]                 = "#595959"
let s:rgb["gray36"]                 = "#5c5c5c"
let s:rgb["gray37"]                 = "#5e5e5e"
let s:rgb["gray38"]                 = "#616161"
let s:rgb["gray39"]                 = "#636363"
let s:rgb["gray4"]                  = "#0a0a0a"
let s:rgb["gray40"]                 = "#666666"
let s:rgb["gray41"]                 = "#696969"
let s:rgb["gray42"]                 = "#6b6b6b"
let s:rgb["gray43"]                 = "#6e6e6e"
let s:rgb["gray44"]                 = "#707070"
let s:rgb["gray45"]                 = "#737373"
let s:rgb["gray46"]                 = "#757575"
let s:rgb["gray47"]                 = "#787878"
let s:rgb["gray48"]                 = "#7a7a7a"
let s:rgb["gray49"]                 = "#7d7d7d"
let s:rgb["gray5"]                  = "#0d0d0d"
let s:rgb["gray50"]                 = "#7f7f7f"
let s:rgb["gray51"]                 = "#828282"
let s:rgb["gray52"]                 = "#858585"
let s:rgb["gray53"]                 = "#878787"
let s:rgb["gray54"]                 = "#8a8a8a"
let s:rgb["gray55"]                 = "#8c8c8c"
let s:rgb["gray56"]                 = "#8f8f8f"
let s:rgb["gray57"]                 = "#919191"
let s:rgb["gray58"]                 = "#949494"
let s:rgb["gray59"]                 = "#969696"
let s:rgb["gray6"]                  = "#0f0f0f"
let s:rgb["gray60"]                 = "#999999"
let s:rgb["gray61"]                 = "#9c9c9c"
let s:rgb["gray62"]                 = "#9e9e9e"
let s:rgb["gray63"]                 = "#a1a1a1"
let s:rgb["gray64"]                 = "#a3a3a3"
let s:rgb["gray65"]                 = "#a6a6a6"
let s:rgb["gray66"]                 = "#a8a8a8"
let s:rgb["gray67"]                 = "#ababab"
let s:rgb["gray68"]                 = "#adadad"
let s:rgb["gray69"]                 = "#b0b0b0"
let s:rgb["gray7"]                  = "#121212"
let s:rgb["gray70"]                 = "#b3b3b3"
let s:rgb["gray71"]                 = "#b5b5b5"
let s:rgb["gray72"]                 = "#b8b8b8"
let s:rgb["gray73"]                 = "#bababa"
let s:rgb["gray74"]                 = "#bdbdbd"
let s:rgb["gray75"]                 = "#bfbfbf"
let s:rgb["gray76"]                 = "#c2c2c2"
let s:rgb["gray77"]                 = "#c4c4c4"
let s:rgb["gray78"]                 = "#c7c7c7"
let s:rgb["gray79"]                 = "#c9c9c9"
let s:rgb["gray8"]                  = "#141414"
let s:rgb["gray80"]                 = "#cccccc"
let s:rgb["gray81"]                 = "#cfcfcf"
let s:rgb["gray82"]                 = "#d1d1d1"
let s:rgb["gray83"]                 = "#d4d4d4"
let s:rgb["gray84"]                 = "#d6d6d6"
let s:rgb["gray85"]                 = "#d9d9d9"
let s:rgb["gray86"]                 = "#dbdbdb"
let s:rgb["gray87"]                 = "#dedede"
let s:rgb["gray88"]                 = "#e0e0e0"
let s:rgb["gray89"]                 = "#e3e3e3"
let s:rgb["gray9"]                  = "#171717"
let s:rgb["gray90"]                 = "#e5e5e5"
let s:rgb["gray91"]                 = "#e8e8e8"
let s:rgb["gray92"]                 = "#ebebeb"
let s:rgb["gray93"]                 = "#ededed"
let s:rgb["gray94"]                 = "#f0f0f0"
let s:rgb["gray95"]                 = "#f2f2f2"
let s:rgb["gray96"]                 = "#f5f5f5"
let s:rgb["gray97"]                 = "#f7f7f7"
let s:rgb["gray98"]                 = "#fafafa"
let s:rgb["gray99"]                 = "#fcfcfc"
let s:rgb["green yellow"]           = "#adff2f"
let s:rgb["green"]                  = "#00ff00"
let s:rgb["green1"]                 = "#00ff00"
let s:rgb["green2"]                 = "#00ee00"
let s:rgb["green3"]                 = "#00cd00"
let s:rgb["green4"]                 = "#008b00"
let s:rgb["greenyellow"]            = "#adff2f"
let s:rgb["grey"]                   = "#bebebe"
let s:rgb["grey0"]                  = "#000000"
let s:rgb["grey1"]                  = "#030303"
let s:rgb["grey10"]                 = "#1a1a1a"
let s:rgb["grey100"]                = "#ffffff"
let s:rgb["grey11"]                 = "#1c1c1c"
let s:rgb["grey12"]                 = "#1f1f1f"
let s:rgb["grey13"]                 = "#212121"
let s:rgb["grey14"]                 = "#242424"
let s:rgb["grey15"]                 = "#262626"
let s:rgb["grey16"]                 = "#292929"
let s:rgb["grey17"]                 = "#2b2b2b"
let s:rgb["grey18"]                 = "#2e2e2e"
let s:rgb["grey19"]                 = "#303030"
let s:rgb["grey2"]                  = "#050505"
let s:rgb["grey20"]                 = "#333333"
let s:rgb["grey21"]                 = "#363636"
let s:rgb["grey22"]                 = "#383838"
let s:rgb["grey23"]                 = "#3b3b3b"
let s:rgb["grey24"]                 = "#3d3d3d"
let s:rgb["grey25"]                 = "#404040"
let s:rgb["grey26"]                 = "#424242"
let s:rgb["grey27"]                 = "#454545"
let s:rgb["grey28"]                 = "#474747"
let s:rgb["grey29"]                 = "#4a4a4a"
let s:rgb["grey3"]                  = "#080808"
let s:rgb["grey30"]                 = "#4d4d4d"
let s:rgb["grey31"]                 = "#4f4f4f"
let s:rgb["grey32"]                 = "#525252"
let s:rgb["grey33"]                 = "#545454"
let s:rgb["grey34"]                 = "#575757"
let s:rgb["grey35"]                 = "#595959"
let s:rgb["grey36"]                 = "#5c5c5c"
let s:rgb["grey37"]                 = "#5e5e5e"
let s:rgb["grey38"]                 = "#616161"
let s:rgb["grey39"]                 = "#636363"
let s:rgb["grey4"]                  = "#0a0a0a"
let s:rgb["grey40"]                 = "#666666"
let s:rgb["grey41"]                 = "#696969"
let s:rgb["grey42"]                 = "#6b6b6b"
let s:rgb["grey43"]                 = "#6e6e6e"
let s:rgb["grey44"]                 = "#707070"
let s:rgb["grey45"]                 = "#737373"
let s:rgb["grey46"]                 = "#757575"
let s:rgb["grey47"]                 = "#787878"
let s:rgb["grey48"]                 = "#7a7a7a"
let s:rgb["grey49"]                 = "#7d7d7d"
let s:rgb["grey5"]                  = "#0d0d0d"
let s:rgb["grey50"]                 = "#7f7f7f"
let s:rgb["grey51"]                 = "#828282"
let s:rgb["grey52"]                 = "#858585"
let s:rgb["grey53"]                 = "#878787"
let s:rgb["grey54"]                 = "#8a8a8a"
let s:rgb["grey55"]                 = "#8c8c8c"
let s:rgb["grey56"]                 = "#8f8f8f"
let s:rgb["grey57"]                 = "#919191"
let s:rgb["grey58"]                 = "#949494"
let s:rgb["grey59"]                 = "#969696"
let s:rgb["grey6"]                  = "#0f0f0f"
let s:rgb["grey60"]                 = "#999999"
let s:rgb["grey61"]                 = "#9c9c9c"
let s:rgb["grey62"]                 = "#9e9e9e"
let s:rgb["grey63"]                 = "#a1a1a1"
let s:rgb["grey64"]                 = "#a3a3a3"
let s:rgb["grey65"]                 = "#a6a6a6"
let s:rgb["grey66"]                 = "#a8a8a8"
let s:rgb["grey67"]                 = "#ababab"
let s:rgb["grey68"]                 = "#adadad"
let s:rgb["grey69"]                 = "#b0b0b0"
let s:rgb["grey7"]                  = "#121212"
let s:rgb["grey70"]                 = "#b3b3b3"
let s:rgb["grey71"]                 = "#b5b5b5"
let s:rgb["grey72"]                 = "#b8b8b8"
let s:rgb["grey73"]                 = "#bababa"
let s:rgb["grey74"]                 = "#bdbdbd"
let s:rgb["grey75"]                 = "#bfbfbf"
let s:rgb["grey76"]                 = "#c2c2c2"
let s:rgb["grey77"]                 = "#c4c4c4"
let s:rgb["grey78"]                 = "#c7c7c7"
let s:rgb["grey79"]                 = "#c9c9c9"
let s:rgb["grey8"]                  = "#141414"
let s:rgb["grey80"]                 = "#cccccc"
let s:rgb["grey81"]                 = "#cfcfcf"
let s:rgb["grey82"]                 = "#d1d1d1"
let s:rgb["grey83"]                 = "#d4d4d4"
let s:rgb["grey84"]                 = "#d6d6d6"
let s:rgb["grey85"]                 = "#d9d9d9"
let s:rgb["grey86"]                 = "#dbdbdb"
let s:rgb["grey87"]                 = "#dedede"
let s:rgb["grey88"]                 = "#e0e0e0"
let s:rgb["grey89"]                 = "#e3e3e3"
let s:rgb["grey9"]                  = "#171717"
let s:rgb["grey90"]                 = "#e5e5e5"
let s:rgb["grey91"]                 = "#e8e8e8"
let s:rgb["grey92"]                 = "#ebebeb"
let s:rgb["grey93"]                 = "#ededed"
let s:rgb["grey94"]                 = "#f0f0f0"
let s:rgb["grey95"]                 = "#f2f2f2"
let s:rgb["grey96"]                 = "#f5f5f5"
let s:rgb["grey97"]                 = "#f7f7f7"
let s:rgb["grey98"]                 = "#fafafa"
let s:rgb["grey99"]                 = "#fcfcfc"
let s:rgb["honeydew"]               = "#f0fff0"
let s:rgb["honeydew1"]              = "#f0fff0"
let s:rgb["honeydew2"]              = "#e0eee0"
let s:rgb["honeydew3"]              = "#c1cdc1"
let s:rgb["honeydew4"]              = "#838b83"
let s:rgb["hot pink"]               = "#ff69b4"
let s:rgb["hotpink"]                = "#ff69b4"
let s:rgb["hotpink1"]               = "#ff6eb4"
let s:rgb["hotpink2"]               = "#ee6aa7"
let s:rgb["hotpink3"]               = "#cd6090"
let s:rgb["hotpink4"]               = "#8b3a62"
let s:rgb["indian red"]             = "#cd5c5c"
let s:rgb["indianred"]              = "#cd5c5c"
let s:rgb["indianred1"]             = "#ff6a6a"
let s:rgb["indianred2"]             = "#ee6363"
let s:rgb["indianred3"]             = "#cd5555"
let s:rgb["indianred4"]             = "#8b3a3a"
let s:rgb["ivory"]                  = "#fffff0"
let s:rgb["ivory1"]                 = "#fffff0"
let s:rgb["ivory2"]                 = "#eeeee0"
let s:rgb["ivory3"]                 = "#cdcdc1"
let s:rgb["ivory4"]                 = "#8b8b83"
let s:rgb["khaki"]                  = "#f0e68c"
let s:rgb["khaki1"]                 = "#fff68f"
let s:rgb["khaki2"]                 = "#eee685"
let s:rgb["khaki3"]                 = "#cdc673"
let s:rgb["khaki4"]                 = "#8b864e"
let s:rgb["lavender blush"]         = "#fff0f5"
let s:rgb["lavender"]               = "#e6e6fa"
let s:rgb["lavenderblush"]          = "#fff0f5"
let s:rgb["lavenderblush1"]         = "#fff0f5"
let s:rgb["lavenderblush2"]         = "#eee0e5"
let s:rgb["lavenderblush3"]         = "#cdc1c5"
let s:rgb["lavenderblush4"]         = "#8b8386"
let s:rgb["lawn green"]             = "#7cfc00"
let s:rgb["lawngreen"]              = "#7cfc00"
let s:rgb["lemon chiffon"]          = "#fffacd"
let s:rgb["lemonchiffon"]           = "#fffacd"
let s:rgb["lemonchiffon1"]          = "#fffacd"
let s:rgb["lemonchiffon2"]          = "#eee9bf"
let s:rgb["lemonchiffon3"]          = "#cdc9a5"
let s:rgb["lemonchiffon4"]          = "#8b8970"
let s:rgb["light blue"]             = "#add8e6"
let s:rgb["light coral"]            = "#f08080"
let s:rgb["light cyan"]             = "#e0ffff"
let s:rgb["light goldenrod yellow"] = "#fafad2"
let s:rgb["light goldenrod"]        = "#eedd82"
let s:rgb["light gray"]             = "#d3d3d3"
let s:rgb["light green"]            = "#90ee90"
let s:rgb["light grey"]             = "#d3d3d3"
let s:rgb["light magenta"]          = "#ffbbff"
let s:rgb["light pink"]             = "#ffb6c1"
let s:rgb["light red"]              = "#ffbbbb"
let s:rgb["light salmon"]           = "#ffa07a"
let s:rgb["light sea green"]        = "#20b2aa"
let s:rgb["light sky blue"]         = "#87cefa"
let s:rgb["light slate blue"]       = "#8470ff"
let s:rgb["light slate gray"]       = "#778899"
let s:rgb["light slate grey"]       = "#778899"
let s:rgb["light steel blue"]       = "#b0c4de"
let s:rgb["light yellow"]           = "#ffffe0"
let s:rgb["lightblue"]              = "#add8e6"
let s:rgb["lightblue1"]             = "#bfefff"
let s:rgb["lightblue2"]             = "#b2dfee"
let s:rgb["lightblue3"]             = "#9ac0cd"
let s:rgb["lightblue4"]             = "#68838b"
let s:rgb["lightcoral"]             = "#f08080"
let s:rgb["lightcyan"]              = "#e0ffff"
let s:rgb["lightcyan1"]             = "#e0ffff"
let s:rgb["lightcyan2"]             = "#d1eeee"
let s:rgb["lightcyan3"]             = "#b4cdcd"
let s:rgb["lightcyan4"]             = "#7a8b8b"
let s:rgb["lightgoldenrod"]         = "#eedd82"
let s:rgb["lightgoldenrod1"]        = "#ffec8b"
let s:rgb["lightgoldenrod2"]        = "#eedc82"
let s:rgb["lightgoldenrod3"]        = "#cdbe70"
let s:rgb["lightgoldenrod4"]        = "#8b814c"
let s:rgb["lightgoldenrodyellow"]   = "#fafad2"
let s:rgb["lightgray"]              = "#d3d3d3"
let s:rgb["lightgreen"]             = "#90ee90"
let s:rgb["lightgrey"]              = "#d3d3d3"
let s:rgb["lightmagenta"]           = "#ffbbff"
let s:rgb["lightpink"]              = "#ffb6c1"
let s:rgb["lightpink1"]             = "#ffaeb9"
let s:rgb["lightpink2"]             = "#eea2ad"
let s:rgb["lightpink3"]             = "#cd8c95"
let s:rgb["lightpink4"]             = "#8b5f65"
let s:rgb["lightred"]               = "#ffbbbb"
let s:rgb["lightsalmon"]            = "#ffa07a"
let s:rgb["lightsalmon1"]           = "#ffa07a"
let s:rgb["lightsalmon2"]           = "#ee9572"
let s:rgb["lightsalmon3"]           = "#cd8162"
let s:rgb["lightsalmon4"]           = "#8b5742"
let s:rgb["lightseagreen"]          = "#20b2aa"
let s:rgb["lightskyblue"]           = "#87cefa"
let s:rgb["lightskyblue1"]          = "#b0e2ff"
let s:rgb["lightskyblue2"]          = "#a4d3ee"
let s:rgb["lightskyblue3"]          = "#8db6cd"
let s:rgb["lightskyblue4"]          = "#607b8b"
let s:rgb["lightslateblue"]         = "#8470ff"
let s:rgb["lightslategray"]         = "#778899"
let s:rgb["lightslategrey"]         = "#778899"
let s:rgb["lightsteelblue"]         = "#b0c4de"
let s:rgb["lightsteelblue1"]        = "#cae1ff"
let s:rgb["lightsteelblue2"]        = "#bcd2ee"
let s:rgb["lightsteelblue3"]        = "#a2b5cd"
let s:rgb["lightsteelblue4"]        = "#6e7b8b"
let s:rgb["lightyellow"]            = "#ffffe0"
let s:rgb["lightyellow1"]           = "#ffffe0"
let s:rgb["lightyellow2"]           = "#eeeed1"
let s:rgb["lightyellow3"]           = "#cdcdb4"
let s:rgb["lightyellow4"]           = "#8b8b7a"
let s:rgb["lime green"]             = "#32cd32"
let s:rgb["limegreen"]              = "#32cd32"
let s:rgb["linen"]                  = "#faf0e6"
let s:rgb["magenta"]                = "#ff00ff"
let s:rgb["magenta1"]               = "#ff00ff"
let s:rgb["magenta2"]               = "#ee00ee"
let s:rgb["magenta3"]               = "#cd00cd"
let s:rgb["magenta4"]               = "#8b008b"
let s:rgb["maroon"]                 = "#b03060"
let s:rgb["maroon1"]                = "#ff34b3"
let s:rgb["maroon2"]                = "#ee30a7"
let s:rgb["maroon3"]                = "#cd2990"
let s:rgb["maroon4"]                = "#8b1c62"
let s:rgb["medium aquamarine"]      = "#66cdaa"
let s:rgb["medium blue"]            = "#0000cd"
let s:rgb["medium orchid"]          = "#ba55d3"
let s:rgb["medium purple"]          = "#9370db"
let s:rgb["medium sea green"]       = "#3cb371"
let s:rgb["medium slate blue"]      = "#7b68ee"
let s:rgb["medium spring green"]    = "#00fa9a"
let s:rgb["medium turquoise"]       = "#48d1cc"
let s:rgb["medium violet red"]      = "#c71585"
let s:rgb["mediumaquamarine"]       = "#66cdaa"
let s:rgb["mediumblue"]             = "#0000cd"
let s:rgb["mediumorchid"]           = "#ba55d3"
let s:rgb["mediumorchid1"]          = "#e066ff"
let s:rgb["mediumorchid2"]          = "#d15fee"
let s:rgb["mediumorchid3"]          = "#b452cd"
let s:rgb["mediumorchid4"]          = "#7a378b"
let s:rgb["mediumpurple"]           = "#9370db"
let s:rgb["mediumpurple1"]          = "#ab82ff"
let s:rgb["mediumpurple2"]          = "#9f79ee"
let s:rgb["mediumpurple3"]          = "#8968cd"
let s:rgb["mediumpurple4"]          = "#5d478b"
let s:rgb["mediumseagreen"]         = "#3cb371"
let s:rgb["mediumslateblue"]        = "#7b68ee"
let s:rgb["mediumspringgreen"]      = "#00fa9a"
let s:rgb["mediumturquoise"]        = "#48d1cc"
let s:rgb["mediumvioletred"]        = "#c71585"
let s:rgb["midnight blue"]          = "#191970"
let s:rgb["midnightblue"]           = "#191970"
let s:rgb["mint cream"]             = "#f5fffa"
let s:rgb["mintcream"]              = "#f5fffa"
let s:rgb["misty rose"]             = "#ffe4e1"
let s:rgb["mistyrose"]              = "#ffe4e1"
let s:rgb["mistyrose1"]             = "#ffe4e1"
let s:rgb["mistyrose2"]             = "#eed5d2"
let s:rgb["mistyrose3"]             = "#cdb7b5"
let s:rgb["mistyrose4"]             = "#8b7d7b"
let s:rgb["moccasin"]               = "#ffe4b5"
let s:rgb["navajo white"]           = "#ffdead"
let s:rgb["navajowhite"]            = "#ffdead"
let s:rgb["navajowhite1"]           = "#ffdead"
let s:rgb["navajowhite2"]           = "#eecfa1"
let s:rgb["navajowhite3"]           = "#cdb38b"
let s:rgb["navajowhite4"]           = "#8b795e"
let s:rgb["navy blue"]              = "#000080"
let s:rgb["navy"]                   = "#000080"
let s:rgb["navyblue"]               = "#000080"
let s:rgb["old lace"]               = "#fdf5e6"
let s:rgb["oldlace"]                = "#fdf5e6"
let s:rgb["olive drab"]             = "#6b8e23"
let s:rgb["olivedrab"]              = "#6b8e23"
let s:rgb["olivedrab1"]             = "#c0ff3e"
let s:rgb["olivedrab2"]             = "#b3ee3a"
let s:rgb["olivedrab3"]             = "#9acd32"
let s:rgb["olivedrab4"]             = "#698b22"
let s:rgb["orange red"]             = "#ff4500"
let s:rgb["orange"]                 = "#ffa500"
let s:rgb["orange1"]                = "#ffa500"
let s:rgb["orange2"]                = "#ee9a00"
let s:rgb["orange3"]                = "#cd8500"
let s:rgb["orange4"]                = "#8b5a00"
let s:rgb["orangered"]              = "#ff4500"
let s:rgb["orangered1"]             = "#ff4500"
let s:rgb["orangered2"]             = "#ee4000"
let s:rgb["orangered3"]             = "#cd3700"
let s:rgb["orangered4"]             = "#8b2500"
let s:rgb["orchid"]                 = "#da70d6"
let s:rgb["orchid1"]                = "#ff83fa"
let s:rgb["orchid2"]                = "#ee7ae9"
let s:rgb["orchid3"]                = "#cd69c9"
let s:rgb["orchid4"]                = "#8b4789"
let s:rgb["pale goldenrod"]         = "#eee8aa"
let s:rgb["pale green"]             = "#98fb98"
let s:rgb["pale turquoise"]         = "#afeeee"
let s:rgb["pale violet red"]        = "#db7093"
let s:rgb["palegoldenrod"]          = "#eee8aa"
let s:rgb["palegreen"]              = "#98fb98"
let s:rgb["palegreen1"]             = "#9aff9a"
let s:rgb["palegreen2"]             = "#90ee90"
let s:rgb["palegreen3"]             = "#7ccd7c"
let s:rgb["palegreen4"]             = "#548b54"
let s:rgb["paleturquoise"]          = "#afeeee"
let s:rgb["paleturquoise1"]         = "#bbffff"
let s:rgb["paleturquoise2"]         = "#aeeeee"
let s:rgb["paleturquoise3"]         = "#96cdcd"
let s:rgb["paleturquoise4"]         = "#668b8b"
let s:rgb["palevioletred"]          = "#db7093"
let s:rgb["palevioletred1"]         = "#ff82ab"
let s:rgb["palevioletred2"]         = "#ee799f"
let s:rgb["palevioletred3"]         = "#cd6889"
let s:rgb["palevioletred4"]         = "#8b475d"
let s:rgb["papaya whip"]            = "#ffefd5"
let s:rgb["papayawhip"]             = "#ffefd5"
let s:rgb["peach puff"]             = "#ffdab9"
let s:rgb["peachpuff"]              = "#ffdab9"
let s:rgb["peachpuff1"]             = "#ffdab9"
let s:rgb["peachpuff2"]             = "#eecbad"
let s:rgb["peachpuff3"]             = "#cdaf95"
let s:rgb["peachpuff4"]             = "#8b7765"
let s:rgb["peru"]                   = "#cd853f"
let s:rgb["pink"]                   = "#ffc0cb"
let s:rgb["pink1"]                  = "#ffb5c5"
let s:rgb["pink2"]                  = "#eea9b8"
let s:rgb["pink3"]                  = "#cd919e"
let s:rgb["pink4"]                  = "#8b636c"
let s:rgb["plum"]                   = "#dda0dd"
let s:rgb["plum1"]                  = "#ffbbff"
let s:rgb["plum2"]                  = "#eeaeee"
let s:rgb["plum3"]                  = "#cd96cd"
let s:rgb["plum4"]                  = "#8b668b"
let s:rgb["powder blue"]            = "#b0e0e6"
let s:rgb["powderblue"]             = "#b0e0e6"
let s:rgb["purple"]                 = "#a020f0"
let s:rgb["purple1"]                = "#9b30ff"
let s:rgb["purple2"]                = "#912cee"
let s:rgb["purple3"]                = "#7d26cd"
let s:rgb["purple4"]                = "#551a8b"
let s:rgb["red"]                    = "#ff0000"
let s:rgb["red1"]                   = "#ff0000"
let s:rgb["red2"]                   = "#ee0000"
let s:rgb["red3"]                   = "#cd0000"
let s:rgb["red4"]                   = "#8b0000"
let s:rgb["rosy brown"]             = "#bc8f8f"
let s:rgb["rosybrown"]              = "#bc8f8f"
let s:rgb["rosybrown1"]             = "#ffc1c1"
let s:rgb["rosybrown2"]             = "#eeb4b4"
let s:rgb["rosybrown3"]             = "#cd9b9b"
let s:rgb["rosybrown4"]             = "#8b6969"
let s:rgb["royal blue"]             = "#4169e1"
let s:rgb["royalblue"]              = "#4169e1"
let s:rgb["royalblue1"]             = "#4876ff"
let s:rgb["royalblue2"]             = "#436eee"
let s:rgb["royalblue3"]             = "#3a5fcd"
let s:rgb["royalblue4"]             = "#27408b"
let s:rgb["saddle brown"]           = "#8b4513"
let s:rgb["saddlebrown"]            = "#8b4513"
let s:rgb["salmon"]                 = "#fa8072"
let s:rgb["salmon1"]                = "#ff8c69"
let s:rgb["salmon2"]                = "#ee8262"
let s:rgb["salmon3"]                = "#cd7054"
let s:rgb["salmon4"]                = "#8b4c39"
let s:rgb["sandy brown"]            = "#f4a460"
let s:rgb["sandybrown"]             = "#f4a460"
let s:rgb["sea green"]              = "#2e8b57"
let s:rgb["seagreen"]               = "#2e8b57"
let s:rgb["seagreen1"]              = "#54ff9f"
let s:rgb["seagreen2"]              = "#4eee94"
let s:rgb["seagreen3"]              = "#43cd80"
let s:rgb["seagreen4"]              = "#2e8b57"
let s:rgb["seashell"]               = "#fff5ee"
let s:rgb["seashell1"]              = "#fff5ee"
let s:rgb["seashell2"]              = "#eee5de"
let s:rgb["seashell3"]              = "#cdc5bf"
let s:rgb["seashell4"]              = "#8b8682"
let s:rgb["sienna"]                 = "#a0522d"
let s:rgb["sienna1"]                = "#ff8247"
let s:rgb["sienna2"]                = "#ee7942"
let s:rgb["sienna3"]                = "#cd6839"
let s:rgb["sienna4"]                = "#8b4726"
let s:rgb["sky blue"]               = "#87ceeb"
let s:rgb["skyblue"]                = "#87ceeb"
let s:rgb["skyblue1"]               = "#87ceff"
let s:rgb["skyblue2"]               = "#7ec0ee"
let s:rgb["skyblue3"]               = "#6ca6cd"
let s:rgb["skyblue4"]               = "#4a708b"
let s:rgb["slate blue"]             = "#6a5acd"
let s:rgb["slate gray"]             = "#708090"
let s:rgb["slate grey"]             = "#708090"
let s:rgb["slateblue"]              = "#6a5acd"
let s:rgb["slateblue1"]             = "#836fff"
let s:rgb["slateblue2"]             = "#7a67ee"
let s:rgb["slateblue3"]             = "#6959cd"
let s:rgb["slateblue4"]             = "#473c8b"
let s:rgb["slategray"]              = "#708090"
let s:rgb["slategray1"]             = "#c6e2ff"
let s:rgb["slategray2"]             = "#b9d3ee"
let s:rgb["slategray3"]             = "#9fb6cd"
let s:rgb["slategray4"]             = "#6c7b8b"
let s:rgb["slategrey"]              = "#708090"
let s:rgb["snow"]                   = "#fffafa"
let s:rgb["snow1"]                  = "#fffafa"
let s:rgb["snow2"]                  = "#eee9e9"
let s:rgb["snow3"]                  = "#cdc9c9"
let s:rgb["snow4"]                  = "#8b8989"
let s:rgb["spring green"]           = "#00ff7f"
let s:rgb["springgreen"]            = "#00ff7f"
let s:rgb["springgreen1"]           = "#00ff7f"
let s:rgb["springgreen2"]           = "#00ee76"
let s:rgb["springgreen3"]           = "#00cd66"
let s:rgb["springgreen4"]           = "#008b45"
let s:rgb["steel blue"]             = "#4682b4"
let s:rgb["steelblue"]              = "#4682b4"
let s:rgb["steelblue1"]             = "#63b8ff"
let s:rgb["steelblue2"]             = "#5cacee"
let s:rgb["steelblue3"]             = "#4f94cd"
let s:rgb["steelblue4"]             = "#36648b"
let s:rgb["tan"]                    = "#d2b48c"
let s:rgb["tan1"]                   = "#ffa54f"
let s:rgb["tan2"]                   = "#ee9a49"
let s:rgb["tan3"]                   = "#cd853f"
let s:rgb["tan4"]                   = "#8b5a2b"
let s:rgb["thistle"]                = "#d8bfd8"
let s:rgb["thistle1"]               = "#ffe1ff"
let s:rgb["thistle2"]               = "#eed2ee"
let s:rgb["thistle3"]               = "#cdb5cd"
let s:rgb["thistle4"]               = "#8b7b8b"
let s:rgb["tomato"]                 = "#ff6347"
let s:rgb["tomato1"]                = "#ff6347"
let s:rgb["tomato2"]                = "#ee5c42"
let s:rgb["tomato3"]                = "#cd4f39"
let s:rgb["tomato4"]                = "#8b3626"
let s:rgb["turquoise"]              = "#40e0d0"
let s:rgb["turquoise1"]             = "#00f5ff"
let s:rgb["turquoise2"]             = "#00e5ee"
let s:rgb["turquoise3"]             = "#00c5cd"
let s:rgb["turquoise4"]             = "#00868b"
let s:rgb["violet red"]             = "#d02090"
let s:rgb["violet"]                 = "#ee82ee"
let s:rgb["violetred"]              = "#d02090"
let s:rgb["violetred1"]             = "#ff3e96"
let s:rgb["violetred2"]             = "#ee3a8c"
let s:rgb["violetred3"]             = "#cd3278"
let s:rgb["violetred4"]             = "#8b2252"
let s:rgb["wheat"]                  = "#f5deb3"
let s:rgb["wheat1"]                 = "#ffe7ba"
let s:rgb["wheat2"]                 = "#eed8ae"
let s:rgb["wheat3"]                 = "#cdba96"
let s:rgb["wheat4"]                 = "#8b7e66"
let s:rgb["white smoke"]            = "#f5f5f5"
let s:rgb["white"]                  = "#ffffff"
let s:rgb["whitesmoke"]             = "#f5f5f5"
let s:rgb["yellow green"]           = "#9acd32"
let s:rgb["yellow"]                 = "#ffff00"
let s:rgb["yellow1"]                = "#ffff00"
let s:rgb["yellow2"]                = "#eeee00"
let s:rgb["yellow3"]                = "#cdcd00"
let s:rgb["yellow4"]                = "#8b8b00"
let s:rgb["yellowgreen"]            = "#9acd32"

if has('mac') && !has('macunix')
  let s:rgb["dark gray"]     = "0x808080"
  let s:rgb["darkgray"]      = "0x808080"
  let s:rgb["dark grey"]     = "0x808080"
  let s:rgb["darkgrey"]      = "0x808080"
  let s:rgb["gray"]          = "0xc0c0c0"
  let s:rgb["grey"]          = "0xc0c0c0"
  let s:rgb["light gray"]    = "0xe0e0e0"
  let s:rgb["lightgray"]     = "0xe0e0e0"
  let s:rgb["light grey"]    = "0xe0e0e0"
  let s:rgb["lightgrey"]     = "0xe0e0e0"
  let s:rgb["dark red"]      = "0x800000"
  let s:rgb["darkred"]       = "0x800000"
  let s:rgb["red"]           = "0xdd0806"
  let s:rgb["light red"]     = "0xffa0a0"
  let s:rgb["lightred"]      = "0xffa0a0"
  let s:rgb["dark blue"]     = "0x000080"
  let s:rgb["darkblue"]      = "0x000080"
  let s:rgb["blue"]          = "0x0000d4"
  let s:rgb["light blue"]    = "0xa0a0ff"
  let s:rgb["lightblue"]     = "0xa0a0ff"
  let s:rgb["dark green"]    = "0x008000"
  let s:rgb["darkgreen"]     = "0x008000"
  let s:rgb["green"]         = "0x006411"
  let s:rgb["light green"]   = "0xa0ffa0"
  let s:rgb["lightgreen"]    = "0xa0ffa0"
  let s:rgb["dark cyan"]     = "0x008080"
  let s:rgb["darkcyan"]      = "0x008080"
  let s:rgb["cyan"]          = "0x02abea"
  let s:rgb["light cyan"]    = "0xa0ffff"
  let s:rgb["lightcyan"]     = "0xa0ffff"
  let s:rgb["dark magenta"]  = "0x800080"
  let s:rgb["darkmagenta"]   = "0x800080"
  let s:rgb["magenta"]       = "0xf20884"
  let s:rgb["light magenta"] = "0xf0a0f0"
  let s:rgb["lightmagenta"]  = "0xf0a0f0"
  let s:rgb["brown"]         = "0x804040"
  let s:rgb["yellow"]        = "0xfcf305"
  let s:rgb["light yellow"]  = "0xffffa0"
  let s:rgb["lightyellow"]   = "0xffffa0"
  let s:rgb["orange"]        = "0xfc8000"
  let s:rgb["purple"]        = "0xa020f0"
  let s:rgb["slateblue"]     = "0x6a5acd"
  let s:rgb["violet"]        = "0x8d38c9"
endif

function! csapprox#rgb()
  return s:rgb
endfunction
