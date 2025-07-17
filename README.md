# Loco  🚋

Loco is a library and minor mode to help you enter complex key sequences with ease.

[![MELPA](https://www.melpa.org/packages/loco-badge.svg)](https://www.melpa.org/#/loco) [![MELPA Stable](https://stable.melpa.org/packages/loco-badge.svg)](https://stable.melpa.org/#/loco)

## Introduction

Loco is a [package](https://www.gnu.org/software/emacs/manual/html_node/emacs/Packages.html) for [Emacs](https://www.gnu.org/software/emacs/). Loco lets you type any [key sequence](docs/build/loco.md#keys-key-sequences-and-commands), including those requiring the modifiers <kbd>Alt</kbd>, <kbd>Control</kbd>, <kbd>Hyper</kbd>, <kbd>Meta</kbd>, or <kbd>Super</kbd>, without using any physical modifier keys except <kbd>Shift</kbd>. This makes it easy to enter key sequences that are complicated or use hard-to-reach keys.

Loco works by translating key sequences from one form to another. It does not redefine the [standard key bindings](https://www.gnu.org/software/emacs/refcards/pdf/refcard.pdf), nor does it prevent you from [defining your own](https://www.gnu.org/software/emacs/manual/html_node/emacs/Key-Bindings.html). Learn the few rules of Loco and be productive immediately, using the key bindings you already know.

Loco does not preclude the use of physical modifier keys; it integrates well with them. There may even be some key bindings for which you find using physical modifier keys preferable. And it works equally well in the [GUI](https://en.wikipedia.org/wiki/Graphical_user_interface) or the [terminal](https://en.wikipedia.org/wiki/Computer_terminal), working around the [limitations of terminals](docs/build/loco.md#considerations-when-using-a-terminal) that prevent the entry of certain keys, allowing you to move between both easily.

When enabled, and using the default configuration, pressing <kbd>S-\<return\></kbd> will activate Loco.

> In Emacs, <kbd>S-\<return\></kbd> means hold <kbd>Shift</kbd> then press <kbd>Return</kbd>.

Once activated, you can type any key sequence, taking advantage of the following special keys to help you avoid pressing any physical modifier keys:

- <kbd>j</kbd> to apply the modifier <kbd>Control</kbd> to the next non‑special key;
- <kbd>k</kbd> to apply the modifier <kbd>Meta</kbd> to the next non‑special key; or
- <kbd>l</kbd> to open a menu that includes options to:
  - apply other modifiers (for example, <kbd>Alt</kbd>, <kbd>Hyper</kbd>, or <kbd>Super</kbd>) to the next non‑special key; or
  - enter the special keys themselves as the literal characters *j*, *k*, or *l*.

### Examples (using the default configuration)

| Typed Key Sequence | Translated Key Sequence | Command       |
|--------------------|-------------------------|---------------|
| <kbd>j d</kbd>     | <kbd>C-d</kbd>          | `delete-char` |
| <kbd>k d</kbd>     | <kbd>M-d</kbd>          | `kill-word`   |
| <kbd>j h i</kbd>   | <kbd>C-h i</kbd>        | `info`        |
| <kbd>j x j s</kbd> | <kbd>C-x C-s</kbd>      | `save-buffer` |

This is only a brief overview; see [Usage](docs/build/loco.md#usage) for a detailed explanation.

The default configuration is not the only way to use Loco. Loco can be [extensively customized](docs/build/loco.md#customization) with just a few lines of code. Many options are possible, including:

- Changing the key bindings used to enable, disable, or activate Loco;
- Changing the keys used while Loco reads a key sequence;
- Configuring activation keys that also function as modifiers; and
- Configuring activation keys that avoid modifiers completely.

## Documentation

This project includes a user manual which includes information on how to install this package.

The user manual is available here, in five formats:

- [Markdown](docs/build/loco.md)
- [HTML](docs/build/loco.html)
- [HTML Standalone](docs/build/loco-standalone.html)
- [Texinfo](docs/build/loco.texi)
- [Info](docs/build/loco.info)

## Author and copyright

This project was written and copyrighted in 2024 by Chris McLaren ([@csmclaren](https://www.github.com/csmclaren)).

## License

Unless otherwise noted, all files in this project are licensed under the [GNU](https://www.gnu.org) General Public License v3.0. See the [COPYING](COPYING) file for details.
