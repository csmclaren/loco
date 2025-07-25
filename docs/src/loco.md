---
dircategory: 'Emacs'
direntry: '\* Loco: (loco).                 Enter complex key sequences with ease!'
filter_embed_stylesheet_fpath: 'build/loco.css'
filter_link_stylesheet_fpath: 'loco.css'
filter_toc_exclude_pattern: 'table%-of%-contents'
title: 'Loco'
---

# Loco &nbsp;&#x1F68B;

Loco is a library and minor mode to help you enter complex key sequences with ease.

## Table of contents

{{TOC}}

## Introduction

Loco is a [package](
https://www.gnu.org/software/emacs/manual/html_node/emacs/Packages.html) for [Emacs](https://www.gnu.org/software/emacs/). Loco lets you type any [key sequence](#keys-key-sequences-and-commands), including those requiring the modifiers <kbd>Alt</kbd>, <kbd>Control</kbd>, <kbd>Hyper</kbd>, <kbd>Meta</kbd>, or <kbd>Super</kbd>, without using any physical modifier keys except <kbd>Shift</kbd>. This makes it easy to enter key sequences that are complicated or use hard-to-reach keys.

Loco works by translating key sequences from one form to another. It does not redefine the [standard key bindings](https://www.gnu.org/software/emacs/refcards/pdf/refcard.pdf), nor does it prevent you from [defining your own](https://www.gnu.org/software/emacs/manual/html_node/emacs/Key-Bindings.html). Learn the few rules of Loco and be productive immediately, using the key bindings you already know.

Loco does not preclude the use of physical modifier keys; it integrates well with them. There may even be some key bindings for which you find using physical modifier keys preferable. And it works equally well in the [GUI](https://en.wikipedia.org/wiki/Graphical_user_interface) or the [terminal](https://en.wikipedia.org/wiki/Computer_terminal), working around the [limitations of terminals](#considerations-when-using-a-terminal) that prevent the entry of certain keys, allowing you to move between both easily.

When enabled, and using the default configuration, pressing <kbd>S-&lt;return&gt;</kbd> will activate Loco.

>In Emacs, <kbd>S-&lt;return&gt;</kbd> means hold <kbd>Shift</kbd> then press <kbd>Return</kbd>.

Once activated, you can type any key sequence, taking advantage of the following special keys to help you avoid pressing any physical modifier keys:

- <kbd>j</kbd> to apply the modifier <kbd>Control</kbd> to  the next non&#x2011;special key;
- <kbd>k</kbd> to apply the modifier <kbd>Meta</kbd> to the next non&#x2011;special key; or
- <kbd>l</kbd> to open a menu that includes options to:
  - apply other modifiers (for example, <kbd>Alt</kbd>, <kbd>Hyper</kbd>, or <kbd>Super</kbd>) to the next non&#x2011;special key; or
  - enter the special keys themselves as the literal characters *j*, *k*, or *l*.

### Examples (using the default configuration)

| Typed Key Sequence | Translated Key Sequence | Command |
| --- | --- | --- |
| <kbd>j d</kbd> | <kbd>C-d</kbd> | `delete-char` |
| <kbd>k d</kbd> | <kbd>M-d</kbd> | `kill-word` |
| <kbd>j h i</kbd> | <kbd>C-h i</kbd> | `info` |
| <kbd>j x j s</kbd> | <kbd>C-x C-s</kbd> | `save-buffer` |

The default configuration is not the only way to use Loco, it is one of a set of pre-defined [standard configurations](#standard-configurations). Loco can also be [extensively customized](#customization) with just a few lines of code. Many options are possible, including:

- Changing the key bindings used to enable, disable, or activate Loco;
- Changing the keys used while Loco reads a key sequence;
- Configuring activation keys that also function as modifiers; and
- Configuring activation keys that avoid modifiers completely.

## Installation

### From MELPA

To install Loco from [MELPA](https://melpa.org), follow these steps:

1. Modify your Emacs configuration

    - Open your [Emacs init file](https://www.gnu.org/software/emacs/manual/html_node/emacs/Init-File.html) and add the following:

      ```lisp
      ;; Add MELPA to the list of package archives
      (require 'package)
      (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
      (package-initialize)

      ;; Refresh the descriptions of all packages in all package archives
      (unless package-archive-contents
        (package-refresh-contents))

      ;; Install the `loco` package
      (unless (package-installed-p 'loco)
        (package-install 'loco))

      ;; Load `loco`
      (require 'loco)

      ;; Set the default configuration for Loco
      (loco-set-default-configuration)

      ;; Enable Loco in all buffers
      (global-loco-mode 1)
      ```

    - Apply your changes by either restarting Emacs or evaluating the modified sections of your configuration file.

### From source

To install Loco from source, follow these steps:

1. Clone the [official repository](https://github.com/csmclaren/loco) from GitHub

    ```sh
    git clone https://github.com/csmclaren/loco.git
    ```

2. Modify your Emacs configuration

    - Open your [Emacs init file](https://www.gnu.org/software/emacs/manual/html_node/emacs/Init-File.html) and add the following, making sure to replace `/path/to/loco` with the path to your cloned repository:

      ```lisp
      ;; Add the load path
      (add-to-list 'load-path "/path/to/loco")

      ;; Load `loco`
      (require 'loco)

      ;; Set the default configuration for Loco
      (loco-set-default-configuration)

      ;; Enable Loco in all buffers
      (global-loco-mode 1)
      ```

    - Apply your changes by either restarting Emacs or evaluating the modified sections of your configuration file.

## Background

### Keys, key sequences, and commands

When discussing keys, it is helpful to distinguish between *physical* keys and *logical* keys.

A physical key is what you press with your fingers on the keyboard. Some physical keys are called *modifier* keys. Emacs recognizes six modifier keys: <kbd>Alt</kbd>, <kbd>Control</kbd>, <kbd>Hyper</kbd>, <kbd>Meta</kbd>, <kbd>Super</kbd>, and <kbd>Shift</kbd>. Your keyboard may not have all of these keys. Furthermore, your keyboard may have different names for the modifier keys that it does have. For example, <kbd>Super</kbd> is called <kbd>Command</kbd> on [Apple keyboards](https://en.wikipedia.org/wiki/Apple_keyboards), and <kbd>Meta</kbd> is called <kbd>Alt</kbd> or <kbd>Option</kbd> on most modern keyboards. Most physical keys, like letters, numbers, and symbols, are *non-modifier* keys.

A logical key (or simply a *key*) is zero or more modifier keys pressed simultaneously with a non-modifier key. For example, holding down the physical <kbd>Control</kbd> key (written as <kbd>C-</kbd>) while pressing the physical <kbd>x</kbd> key produces the key <kbd>C-x</kbd>.

Key sequences are composed of one or more keys. For example, the key sequence <kbd>C-x s</kbd> is composed of two keys: <kbd>C-x</kbd> and <kbd>s</kbd>. Key sequences can be bound to commands. For example, <kbd>C-x s</kbd> is bound to the command `save-all-files`.

By composing key sequences from keys, a large number of key sequences can be created from a small number of keys. This is similar to how an alphabet can be used to compose the words of a language: a large number of words can be created from a small number of letters.

### How Loco is different

On modern keyboards, which typically have small or hard-to-reach modifier keys, or for people with [RSI](https://en.wikipedia.org/wiki/Repetitive_strain_injury) or other forms of limited mobility, pressing one or more keys simultaneously can be difficult or even painful. This is especially true when two or more modifier keys are required to complete a single key, or if a certain modifier key is particularly hard to reach.

To help solve this problem, Loco extends the idea of composing key sequences from keys to the level of the key itself. In Loco, logical keys can be composed of one or more physical keys pressed one after the other, not simultaneously. Additionally, Loco uses certain easy-to-reach non-modifier keys (or *special* keys) to assist you with key entry.

## Usage

### Enabling and disabling Loco

Loco works by adding a [minor mode](https://www.gnu.org/software/emacs/manual/html_node/elisp/Minor-Modes.html) to Emacs. This mode can be enabled or disabled in some or all buffers.

To enable or disable Loco *in the current buffer*, use the command `loco-mode`. The key sequence <kbd>C-c ,</kbd> is bound to this command; pressing it will toggle Loco in the current buffer.

You can also call this command using Emacs Lisp with:

- No argument, `nil`, or a positive number to enable Loco in the current buffer;
  ```lisp
  (loco-mode 1) ; Enable in the current buffer
  ```

- A zero or negative number to disable Loco in the current buffer; or
  ```lisp
  (loco-mode 0) ; Disable in the current buffer
  ```

- The symbol `toggle` to toggle Loco in the current buffer.
  ```lisp
  (loco-mode 'toggle) ; Toggle in the current buffer
  ```

To enable or disable Loco *in all buffers*, use the command `global-loco-mode`. The key sequence <kbd>C-c .</kbd> is bound to this command; pressing it will toggle Loco in all buffers.

>This command will override any local settings.

You can also call this command using Emacs Lisp with:

- No argument, `nil`, or a positive number to enable Loco in all buffers;
  ```lisp
  (global-loco-mode 1) ; Enable in all buffers
  ```

- A zero or negative number to disable Loco in all buffers; or
  ```lisp
  (global-loco-mode 0) ; Disable in all buffers
  ```

- The symbol `toggle` to toggle Loco in all buffers.
  ```lisp
  (global-loco-mode 'toggle) ; Toggle in all buffers
  ```

When Loco is *disabled* in the current buffer, all keys can be typed normally as if Loco were not installed, with the exception of <kbd>C-c ,</kbd> and <kbd>C-c .</kbd> themselves, which are bound in the global keymap.

When Loco is *enabled* in the current buffer it will place an indicator, which Emacs calls a "lighter", in the mode line of that buffer. The lighter for Loco is simply the string "Loco".

### The default configuration

>This section assumes that you are using the default configuration for Loco, as recommended in [Installation](#installation).

#### Activating Loco

When Loco is enabled, it will bind two additional key sequences: <kbd>S-&lt;return&gt;</kbd> and <kbd>C-h S-&lt;return&gt;</kbd>. Pressing either of these will *activate* Loco.

When Loco is activated, it will prompt you to enter a key sequence, then it will lookup whether or not that key sequence is bound to a command. If a command is found, it will either execute or describe that command, depending on which key sequence was used to activate it. <kbd>S-&lt;return&gt;</kbd> tells Loco that it should *execute* the command. <kbd>C-h S-&lt;return&gt;</kbd> tells Loco it should *describe* the command.

#### Entering key sequences

When Loco reads a key sequence:

- It tracks a set of modifiers (<kbd>Alt</kbd>, <kbd>Control</kbd>, <kbd>Hyper</kbd>, <kbd>Meta</kbd>, and <kbd>Super</kbd>) that it considers "pending".

- <kbd>j</kbd> and <kbd>k</kbd> add <kbd>Control</kbd> and <kbd>Meta</kbd>, respectively, to the set of pending modifiers, or represent themselves, if their respective modifiers are already pending.

- <kbd>l</kbd> opens the Assist Menu, a menu which includes commands to toggle pending modifiers (<kbd>a</kbd> <kbd>c</kbd> <kbd>h</kbd> <kbd>m</kbd> and <kbd>s</kbd>) or enter keys for which there is no other way to enter because they have been repurposed by Loco (<kbd>j</kbd> <kbd>k</kbd> and <kbd>l</kbd> itself).

- When a key is pressed to which modifiers could be applied, any pending modifiers from that set are applied to the key, as if the equivalent physical modifier keys were held down at the time the key was pressed. The set (if not empty) is then cleared. The key (now potentially modified) is then added to the key sequence.

- When a key is added to the key sequence, Loco will check if the key sequence is bound to a command. If it is a *partial match* to one (or more) commands, Loco will continue to read keys. If it is an *exact match* to a command, Loco will stop reading keys and execute or describe that command (depending on how Loco was activated). Otherwise, Loco will stop reading keys and tell the user that no match was found.

- It will display its prompt in the minibuffer. The prompt will consist of:

    - A right-pointing triangle (&#x25B6;);

    - The current key sequence, if any, displayed in the normal Emacs style;

    - The set of pending modifiers, if any, displayed in the normal Emacs style, i.e., `A-`, `C-`, `H-`, `M-`, and `s-`, corresponding to the modifiers <kbd>Alt</kbd>, <kbd>Control</kbd>, <kbd>Hyper</kbd>, <kbd>Meta</kbd>, and <kbd>Super</kbd>, respectively; and

    - The Assist Menu, if open, displayed as `[;]` (in its collapsed state) or `[achms jkl q x ;]` (in its expanded state).

The following tables explain exactly how key presses are handled while reading a key sequence.

##### Normal operation (i.e., when the Assist Menu is closed)

| Key | Rule |
| --- | --- |
| <kbd>j</kbd> | There are two possibilities for how this key is handled. If <kbd>Control</kbd> is already pending, apply all pending modifiers to the key (clearing the modifiers), then add the modified key to the key sequence. Otherwise, add <kbd>Control</kbd> to the set of pending modifiers. |
| <kbd>k</kbd> | There are two possibilities for how this key is handled. If <kbd>Meta</kbd> is already pending, apply all pending modifiers to the key (clearing the modifiers), then add the modified key to the key sequence. Otherwise, add <kbd>Meta</kbd> to the set of pending modifiers. |
| <kbd>l</kbd> | Open the Assist Menu. |
| Other | Apply any pending modifiers to the key (clearing the modifiers), then add the (potentially modified) key to the key sequence. |

##### Assisted operation (i.e., when the Assist Menu is open)

| Key | Rule |
| --- | --- |
| <kbd>a</kbd> <kbd>c</kbd> <kbd>h</kbd> <kbd>m</kbd> or <kbd>s</kbd> | Toggle <kbd>Alt</kbd> <kbd>Control</kbd> <kbd>Hyper</kbd> <kbd>Meta</kbd> or <kbd>Super</kbd> respectively, in the set of pending modifiers, and close the Assist Menu. |
| <kbd>A</kbd> <kbd>C</kbd> <kbd>H</kbd> <kbd>M</kbd> or <kbd>S</kbd> | Toggle <kbd>Alt</kbd> <kbd>Control</kbd> <kbd>Hyper</kbd> <kbd>Meta</kbd> or <kbd>Super</kbd> respectively, in the set of pending modifiers, but do not close the Assist Menu. |
| <kbd>j</kbd> <kbd>k</kbd> or <kbd>l</kbd> | Apply any pending modifiers to the key (clearing the modifiers), add the (potentially modified) key to the key sequence, and close the Assist Menu. |
| <kbd>q</kbd> | Close the Assist Menu and cancel the key sequence (equivalent to <kbd>C-g</kbd>). |
| <kbd>x</kbd> | Close the Assist Menu. |
| <kbd>;</kbd> | Toggle the Assist Menu between its collapsed and expanded states. |
| Other | Discard the key, but do not close the Assist Menu. If the Assist Menu is currently collapsed, expand it to remind the user of all available options. |

##### Rock and roll

The keys <kbd>j</kbd>, <kbd>k</kbd>, and <kbd>l</kbd> were chosen to represent <kbd>Control</kbd>, <kbd>Meta</kbd>, and the Assist Menu, respectively, because on a [QWERTY](https://en.wikipedia.org/wiki/QWERTY) keyboard these keys are adjacent. This allows you to roll from side to side or rock your fingers back and forth over them.

Furthermore, you can build up the set of pending modifiers for a key in any order; for example, both <kbd>j k</kbd> and <kbd>k j</kbd> translate to <kbd>C-M-</kbd>.

These design choices enable efficient key entry, enhancing your ability to enter these important keys swiftly and accurately.

##### Persistent keys

On the Assist Menu, the keys used to toggle modifiers (<kbd>a</kbd>, <kbd>c</kbd>, <kbd>h</kbd>, <kbd>m</kbd>, and <kbd>s</kbd>) can be pressed in conjunction with the physical <kbd>Shift</kbd> key (<kbd>A</kbd>, <kbd>C</kbd>, <kbd>H</kbd>, <kbd>M</kbd>, and <kbd>S</kbd>, respectively).

These <kbd>Shift</kbd>-modified keys perform the same operation as their unmodified counterparts but make the Assist Menu *persistent*: after use, the menu remains open to use again.

The advantage of these keys is that multiple modifiers can be added or removed quickly. The disadvantage is that another key (for example, <kbd>x</kbd>) is then required to close the Assist Menu.

These keys are optional and not shown on the Assist Menu.

##### Typical key sequences and their translations

Most key sequences do not involve <kbd>Control</kbd> or <kbd>Meta</kbd> in conjunction with <kbd>j</kbd>, <kbd>k</kbd>, or <kbd>l</kbd>, making them easy to enter.

| Typed Key Sequence | Translated Key Sequence | Command |
| --- | --- | --- |
| <kbd>j e</kbd> | <kbd>C-e</kbd> | `move-end-of-line` |
| <kbd>k e</kbd> | <kbd>M-e</kbd> | `forward-sentence` |
| <kbd>j k e</kbd> or <kbd>k j e</kbd> | <kbd>C-M-e</kbd> |`end-of-defun` |

##### More difficult key sequences and their translations

Nine key sequences involve <kbd>Control</kbd> or <kbd>Meta</kbd> in conjunction with <kbd>j</kbd>, <kbd>k</kbd>, or <kbd>l</kbd>, making them more difficult to enter.

| Typed Key Sequence | Translated Key Sequence | Command |
| --- | --- | --- |
| <kbd>j l j</kbd> or <kbd>j j</kbd> | <kbd>C-j</kbd> | `eval-print-last-sexp` |
| <kbd>j l k</kbd> | <kbd>C-k</kbd> | `kill-line` |
| <kbd>j l l</kbd> | <kbd>C-l</kbd> | `recenter-top-bottom` |
| <kbd>k l j</kbd> | <kbd>M-j</kbd> | `default-indent-new-line` |
| <kbd>k l k</kbd> or <kbd>k k</kbd> | <kbd>M-k</kbd> |`kill-sentence` |
| <kbd>k l l</kbd> | <kbd>M-l</kbd> | `downcase-word` |
| <kbd>j k j</kbd> or <kbd>k j j</kbd> | <kbd>C-M-j</kbd> | `default-indent-new-line` |
| <kbd>j k k</kbd> or <kbd>k j k</kbd> | <kbd>C-M-k</kbd> | `kill-sexp` |
| <kbd>j k l l</kbd> or <kbd>k j l l</kbd> | <kbd>C-M-l</kbd> | `reposition-window` |

### Describing commands

The built-in command `describe-key` waits for a key sequence to be input. If that key sequence is bound to a command, it describes the command. This is an excellent way to discover (or remind yourself) of the command to which a key sequence is bound.

In the global keymap, <kbd>C-h k</kbd> is bound to `describe-key`.

This command reads key sequences directly, without leveraging Loco, but Loco provides similar functionality.

For purposes of describing a key sequence, when Loco is enabled in the current buffer, use <kbd>C-h S-&lt;return&gt;</kbd> to activate Loco. Then enter a key sequence, and Loco will describe the command to which it is bound.

### Standard configurations

A standard configuration is a named set of keys and behaviours for activating Loco and entering key sequences to execute or describe the commands to which they are bound. Eleven such configurations are included in Loco.

Standard configurations can be installed or uninstalled easily by applying `loco-set-standard-configuration` or `loco-unset-standard-configuration`, respectively, to the name of the configuration.

These allow one to use Loco beyond what is provided by the default configuration, but without requiring more substantial customization. The default configuration is itself defined as one of the standard configurations (`shift-return-jk`).

#### Details

- `shift‑return‑jk`

  This is the default configuration, described [above](#the-default-configuration).

  Note that this:

  ``` lisp
  (loco-set-default-configuration)
  ```

  is equivalent to:

  ``` lisp
  (loco-set-standard-configuration 'shift‑return‑jk)
  ```

  Similarly, this:

  ``` lisp
  (loco-unset-default-configuration)
  ```

  is equivalent to:

  ``` lisp
  (loco-unset-standard-configuration 'shift‑return‑jk)
  ```

- `control‑return‑jk` and `super‑return‑jk`

  These are similar to `shift‑return‑jk`, but use different modifier keys for activation.

  Instead of using <kbd>S-&lt;return&gt;</kbd> to activate Loco, they use <kbd>C-&lt;return&gt;</kbd> and <kbd>s-&lt;return&gt;</kbd>, respectively. And instead of using <kbd>C-h S-&lt;return&gt;</kbd> for purposes of describing a key sequence, they use <kbd>C-h C-&lt;return&gt;</kbd> and <kbd>C-h s-&lt;return&gt;</kbd>, respectively.

  These configurations may be preferable if <kbd>Control</kbd> or <kbd>Super</kbd> are better located on your keyboard or if you have already bound <kbd>S-&lt;return&gt;</kbd> to another command. Other than the change of activation key, all other functionality remains the same as per `shift‑return‑jk`.

- `shift‑return‑cp`, `control‑return‑cp`, and `super‑return‑cp`

  These are similar to the above three configurations in terms of activation, but use different keys to enter key sequences.

  Instead of using <kbd>j</kbd> for <kbd>Control</kbd>, <kbd>k</kbd> for <kbd>Meta</kbd>, <kbd>l</kbd> to open the Assist Menu, and <kbd>;</kbd> to toggle the Assist Menu between its collapsed and expanded states, they use <kbd>,</kbd>, <kbd>.</kbd>, <kbd>m</kbd>, and <kbd>/</kbd> respectively.

  These configurations may be preferable for those who find it easier to mentally associate the modifiers to punctuation (<kbd>,</kbd> and <kbd>.</kbd> instead of <kbd>j</kbd> and <kbd>k</kbd>, respectively), or remember <kbd>m</kbd> as "menu".

  Note that by using <kbd>m</kbd> to open the Assist Menu, we need to rely on the Assist Menu to help us enter a literal *m* when necessary. There is a potential conflict here. By default, the Assist Menu reserves <kbd>a</kbd> <kbd>c</kbd> <kbd>h</kbd> <kbd>m</kbd> and <kbd>s</kbd> to toggle pending modifiers then close the Assist Menu. To ensure that <kbd>m</kbd> inserts a literal *m*, <kbd>m</kbd> is removed from the list of keys that toggle pending modifiers in these configurations. For clarity and consistency, we also remove *c* from the Assist Menu in these configurations.

  The Assist Menu displays itself according to the keys as you've configured them. When using the default configuration, for example, the Assist Menu will display itself (when open and expanded) like this: `[achms jkl q x ;]`. In these configurations, it will display itself (when open and expanded) like this: `[ahs ,.m q x /]`.

  >Note that, by default, the Assist Menu also reserves <kbd>A</kbd> <kbd>C</kbd> <kbd>H</kbd> <kbd>M</kbd> and <kbd>S</kbd> as the [persistent](#persistent-keys) versions of <kbd>a</kbd> <kbd>c</kbd> <kbd>h</kbd> <kbd>m</kbd> and <kbd>s</kbd>, respectively. None of the persistent versions of these keys are removed from these configurations, so there does remain a means to toggle <kbd>Control</kbd> and <kbd>Meta</kbd> from the Assist Menu if desired.

- `control‑jk`

  Activation keys can also function as modifiers, allowing you to both activate Loco and set a pending modifier with a single key.

  In this configuration, <kbd>C-j</kbd> and <kbd>C-k</kbd> both activate Loco to read a key sequence and execute the command to which it is bound, but <kbd>C-j</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>C-k</kbd> with <kbd>Meta</kbd> pending.

  For purposes of describing a key sequence, <kbd>C-h C-j</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>C-h C-k</kbd> with <kbd>Meta</kbd> pending.

  Entering key sequences is similar to `shift‑return‑jk`, `control‑return‑jk`, and `super‑return‑jk`, but this configuration will also strip all modifiers from any key that it reads.

  As per [Working with physical modifier keys](#working-with-physical-modifier-keys), Loco is happy to merge any modified keys with any pending modifiers. When activating Loco with a key that is similar to the keys required to toggle pending modifiers, accidentally holding any physical modifier key past its intended key may modify subsequent keys, resulting in a key sequence bound to a different command that intended. Stripping modifiers from keys allows for some forgiveness when typing quickly, to ensure the modifiers aren't incorrectly applied to the wrong keys.

- `super‑jk`

  This configuration is similar to `control‑jk`, but uses different modifier keys for activation.

  In this configuration, <kbd>s-j</kbd> and <kbd>s-k</kbd> both activate Loco to read a key sequence and execute the command to which it is bound, but <kbd>s-j</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>s-k</kbd> with <kbd>Meta</kbd> pending.

  For purposes of describing a key sequence, <kbd>C-h s-j</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>C-h s-k</kbd> with <kbd>Meta</kbd> pending.

  Entering key sequences is similar to `shift‑return‑jk`, `control‑return‑jk`, and `super‑return‑jk`, but this configuration will also strip all modifiers from any key that it reads, similar to `control‑jk`.

- `control‑cp`

  In this configuration, <kbd>C-,</kbd> and <kbd>C-.</kbd> both activate Loco to read a key sequence and execute the command to which it is bound, but <kbd>C-,</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>C-.</kbd> with <kbd>Meta</kbd> pending.

  For purposes of describing a key sequence, <kbd>C-h C-,</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>C-h C-.</kbd> with <kbd>Meta</kbd> pending.

  Entering key sequences is similar to `shift‑return‑cp`, `control‑return‑cp`, and `super‑return‑cp`, but this configuration will also strip all modifiers from any key that it reads, similar to `control‑jk` and `super-jk`.

- `super‑cp`

  In this configuration, <kbd>s-,</kbd> and <kbd>s-.</kbd> both activate Loco to read a key sequence and execute the command to which it is bound, but <kbd>s-,</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>s-.</kbd> with <kbd>Meta</kbd> pending.

  For purposes of describing a key sequence, <kbd>C-h s-,</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>C-h s-.</kbd> with <kbd>Meta</kbd> pending.

  Entering key sequences is similar to `shift‑return‑cp`, `control‑return‑cp`, and `super‑return‑cp`, but this configuration will also strip all modifiers from any key that it reads, similar to `control‑jk`, `super-jk`, and `control-cp`.

- `double-tap‑cp`

  Activation keys can avoid modifiers completely, allowing you use Loco without using any physical modifier keys.

  In this configuration, <kbd>,</kbd> and <kbd>.</kbd> both activate Loco to read a key sequence and execute the command to which it is bound, but <kbd>,</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>.</kbd> with <kbd>Meta</kbd> pending.

  For purposes of describing a key sequence, <kbd>C-h ,</kbd> activates Loco with <kbd>Control</kbd> pending and <kbd>C-h .</kbd> with <kbd>Meta</kbd> pending.

  Entering key sequences is similar to `shift‑return‑cp`, `control‑return‑cp`, and `super‑return‑cp`,
  but this configuration will also strip all modifiers from any key that it reads, similar to `control‑jk`, `super-jk`, `control-cp`, and `super-cp`. It will also apply the *double-tap* rule.

  The effect of setting unmodified <kbd>,</kbd> and <kbd>.</kbd> as activation keys is significant. By rebinding them to activation keys, they no longer perform their original purpose: to enter a literal comma or period, respectively. Both are essential punctuation, second only to the letters and digits in terms of frequency of use.

  The double-tap rule, for this configuration, states that if <kbd>,</kbd> is pressed when <kbd>Control</kbd> is the *only* pending modifier, or if <kbd>.</kbd> is pressed when <kbd>Meta</kbd> is the *only* pending modifier, clear the modifier and add the key *unmodified* to the key sequence.

  This rule permits <kbd>,</kbd> and <kbd>.</kbd> to be entered as <kbd>, ,</kbd> or <kbd>. .</kbd>, respectively. It is called double-tap because it takes effect when these keys are tapped twice in succession (provided no other modifiers are in effect).

  Without this rule, entering a literal comma or period would be unduly onerous. For example, here are four alternate ways by which you could enter a literal comma or period, respectively:

  1. <kbd>, m C ,</kbd> or <kbd>. m M .</kbd>

      This method uses the Assist Menu (once), but uses a [persistent key](#persistent-keys) to keep the menu open.

  2. <kbd>, m c m ,</kbd> or <kbd>. m m m .</kbd>

      This method uses the Assist Menu (twice), but does not require a physical modifier key.

  3. <kbd>C-q ,</kbd> or <kbd>C-q .</kbd>

      In Emacs, <kbd>C-q</kbd> is bound to the command `quoted-insert`, which will read the next key and insert it. This method uses `quoted-insert`, but requires a physical modifier key.

  4. <kbd>, q ,</kbd> or <kbd>, q .</kbd>

      <kbd>C-q</kbd> itself can be entered as <kbd>, q</kbd>. This method uses `quoted-insert`, but does not require a physical modifier key.

  While the double-tap rule makes entering a literal comma or period easy, it does come with a cost.

  Without this rule, <kbd>, ,</kbd> would be translated to <kbd>C-,</kbd>. The first <kbd>,</kbd> would tell Loco to consider <kbd>Control</kbd> as pending, and the second <kbd>,</kbd> would tell Loco to apply <kbd>Control</kbd> to <kbd>,</kbd>.

  Similarly, <kbd>. .</kbd> would be translated to <kbd>M-.</kbd>. The first <kbd>.</kbd> would tell Loco to consider <kbd>Meta</kbd> as pending, and the second <kbd>.</kbd> would tell Loco to apply <kbd>Meta</kbd> to <kbd>.</kbd>.

  While <kbd>C-,</kbd> and <kbd>M-.</kbd> are less frequently used than literal commas and periods (<kbd>C-,</kbd> is not bound to any command and <kbd>M-.</kbd> is bound to `xref-find-definition`), we must still be able to enter them.

  Fortunately, we can use the Assist Menu for this. <kbd>C-,</kbd> and <kbd>M-.</kbd> can be entered as <kbd>, m ,</kbd> and <kbd>. m .</kbd>, respectively.

#### Summary

| Name | Activate | Apply <kbd>Control</kbd> | Apply <kbd>Meta</kbd> | O | E&nbsp;&amp;&nbsp;C | S | DT |
| --- | --- | :-: | :-: | :-: | :-: | :-: | :-: |
| `shift‑return‑jk`   | <kbd>S&#8209;&lt;return&gt;</kbd> | <kbd>j</kbd> | <kbd>k</kbd> | <kbd>l</kbd> | <kbd>;</kbd> |   |   |
| `control‑return‑jk` | <kbd>C&#8209;&lt;return&gt;</kbd> | <kbd>j</kbd> | <kbd>k</kbd> | <kbd>l</kbd> | <kbd>;</kbd> |   |   |
| `super‑return‑jk`   | <kbd>s&#8209;&lt;return&gt;</kbd> | <kbd>j</kbd> | <kbd>k</kbd> | <kbd>l</kbd> | <kbd>;</kbd> |   |   |
| `shift‑return‑cp`   | <kbd>S&#8209;&lt;return&gt;</kbd> | <kbd>,</kbd> | <kbd>.</kbd> | <kbd>m</kbd> | <kbd>/</kbd> |   |   |
| `control‑return‑cp` | <kbd>C&#8209;&lt;return&gt;</kbd> | <kbd>,</kbd> | <kbd>.</kbd> | <kbd>m</kbd> | <kbd>/</kbd> |   |   |
| `super‑return‑cp`   | <kbd>s&#8209;&lt;return&gt;</kbd> | <kbd>,</kbd> | <kbd>.</kbd> | <kbd>m</kbd> | <kbd>/</kbd> |   |   |
| `control‑jk`        | <kbd>C&#8209;j</kbd> and apply <kbd>Control</kbd>, <br> <kbd>C&#8209;k</kbd> and apply <kbd>Meta</kbd> | <kbd>j</kbd> | <kbd>k</kbd> | <kbd>l</kbd> | <kbd>;</kbd> | &#x2714;&#xFE0E; |   |
| `super‑jk`          | <kbd>s&#8209;j</kbd> and apply <kbd>Control</kbd>, <br> <kbd>s&#8209;k</kbd> and apply <kbd>Meta</kbd> | <kbd>j</kbd> | <kbd>k</kbd> | <kbd>l</kbd> | <kbd>;</kbd> | &#x2714;&#xFE0E; |   |
| `control‑cp`        | <kbd>C&#8209;,</kbd> and apply <kbd>Control</kbd>, <br> <kbd>C&#8209;,</kbd> and apply <kbd>Meta</kbd> | <kbd>,</kbd> | <kbd>.</kbd> | <kbd>m</kbd> | <kbd>/</kbd>| &#x2714;&#xFE0E; |   |
| `super‑cp`          | <kbd>s&#8209;,</kbd> and apply <kbd>Control</kbd>, <br> <kbd>s&#8209;.</kbd> and apply <kbd>Meta</kbd> | <kbd>,</kbd> | <kbd>.</kbd> | <kbd>m</kbd> | <kbd>/</kbd>| &#x2714;&#xFE0E; |   |
| `double‑tap‑cp`     | <kbd>,</kbd> and apply <kbd>Control</kbd>, <br> <kbd>.</kbd> and apply <kbd>Meta</kbd> | <kbd>,</kbd> | <kbd>.</kbd> | <kbd>m</kbd> | <kbd>/</kbd>| &#x2714;&#xFE0E; | &#x2714;&#xFE0E; |

- O: Open the Assist&nbsp;Menu
- E&nbsp;&amp;&nbsp;C: Expand&nbsp;&amp;&nbsp;Collapse the Assist&nbsp;Menu
- S: Strip modifiers
- DT: Enable the double-tap rule

### Repeating commands

One advantage of using physical modifier keys is that once held, the non-modifier key can be pressed multiple times in sequence to repeat the command.

Emacs provides a [number of ways](https://www.gnu.org/software/emacs/manual/html_node/emacs/Repeating.html) to assist with repeating a command, and Loco works well with all of them. In particular, using `repeat-mode` to setup groups of commands that can be repeated by pressing only their last letter is highly recommended.

### Working with physical modifier keys

While Loco aims to replace the need for physical modifier keys, there may be some cases where you want to use key bindings that use them. Because Loco does not replace or disable any keymaps, you are able to use other key bindings as you see fit.

Furthermore, while not necessary, any physical modifier keys you use while entering key sequences in Loco are properly merged with the set of pending modifiers.

### Considerations when using a terminal

In a GUI environment, applications receive key events directly from the [windowing system](https://en.wikipedia.org/wiki/Windowing_system) (for example, X11, Wayland, or Quartz Compositor). These systems have comprehensive support for detecting various key combinations, including multiple modifiers pressed simultaneously with other keys. The only limitation is usually from the operating system itself, which reserves certain key combinations for its own functions.

Modern terminal applications are typically run within a [terminal emulator](https://en.wikipedia.org/wiki/Terminal_emulator), an application that itself reserves certain key combinations for its own functions. This creates a disparity between the total number of keys available to the GUI application and the terminal application.

Terminal emulators are designed to mimic the behaviour of older physical terminals (for example, the [VT100](https://en.wikipedia.org/wiki/VT100)). Most terminal emulators work by encoding input into characters or escape sequences that the terminal application interprets. This limits how key events are handled by terminal applications in several ways:

- The <kbd>Control</kbd> key is typically limited to modifying these specific 32 characters: ```@ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ ?```. These characters have [ASCII](https://en.wikipedia.org/wiki/ASCII) codes of 64 to 95 inclusive. When pressed in conjunction with <kbd>Control</kbd>, 64 is subtracted from their ASCII code, resulting in a [Control Character](https://en.wikipedia.org/wiki/Control_character). This form of encoding inherently limits which combinations are possible with <kbd>Control</kbd> and does not work well in conjunction with any other modifier key.

- Other modifier keys, and keys without ASCII equivalents (for example, the arrow and function keys), are either encoded as character sequences beginning with the <kbd>ESC</kbd> character or not sent to terminal applications at all. Interpreting these sequences can be less reliable, especially for complex combinations involving multiple modifiers.

By translating simple key sequences into complex ones, Loco can avoid the above limitations.

Note that even the default configuration may not work perfectly in all terminals, as certain terminal emulators will not recognize its activation key, <kbd>S-&lt;return&gt;</kbd>. `control-jk` and `double-tap-cp` are the only standard configurations guaranteed to work in terminals.

### Customization

>Some of this section assumes the reader has basic experience with [Emacs Lisp](https://www.gnu.org/software/emacs/manual/html_node/eintr/).

#### Using the "Easy Customization Interface"

The [Easy Customization Interface](https://www.gnu.org/software/emacs/manual/html_node/emacs/Easy-Customization.html) can be used to customize certain properties of Loco, including its lighter and its prompts.

>You can also customize properties related to logging, which is useful if you are planning on modifying the source code for Loco. Logging is not explained in this document; see the source code for details.

Some of the properties presented in this interface take [S-expressions](https://www.gnu.org/software/emacs/manual/html_node/emacs/Expressions.html) as values. These permit more possibilities for values; for example, strings styled with custom colours and fonts.

All of the properties presented in this interface can be set using Emacs Lisp as well.

#### Mapping Caps Lock to Control

<kbd>S-&lt;return&gt;</kbd> is easy to press, but it would be easier still to be able to activate Loco with a physical modifier key located right on the home row. If this physical modifier key were <kbd>Control</kbd>, you would also have quick access to some very common Emacs key bindings without use of Loco. For example, <kbd>C-n</kbd> and <kbd>C-p</kbd>.

<kbd>Caps Lock</kbd>, located to the left of <kbd>a</kbd> on a QWERTY keyboard, is a rarely-used key in a prime location. As such, it is common to remap this key to <kbd>Control</kbd>.

For most operating systems, there is both built-in support and third-party tools available to remap keys.

For example, on MacOS, where keys are not easily remapped system-wide, mapping <kbd>Caps Lock</kbd> to <kbd>Control</kbd> is possible without third-party tools:

  - In *System Preferences > Keyboard > Keyboard Shortcuts... > Modifier Keys*, change *Caps Lock key* to *Control*.

  - (Optional) You may also want to change *Control key* to *Caps Lock*, effectively swapping the behaviour of the two keys, to ensure you still have a means to toggle <kbd>Caps Lock</kbd> if desired.

  - (Optional) If you use multiple keyboards, ensure that you change these settings for each keyboard appropriately by selecting each keyboard in turn at the top of the dialog box.

  - Press *Done* when complete.

#### Going further

With only a few lines of code, you can specify the key sequences to enable, disable, and activate Loco, as well as the set of keys and behaviours for entering key sequences.

See the commands `loco-set-standard-configuration` and `loco-unset-default-configuration` in the source code to understand how key sequences are bound and unbound, respectively, to enable, disble, and activate Loco for each standard configuration (including the default configuration).

See the command `loco-read-kseq` in the source code to understand how the set of keys and behaviours are specified for entering key sequences. Note that all standard configurations ultimately call this one command. It accepts many keyword arguments, all of which are explained in the documentation for that command.

## Author and copyright

This project was written and copyrighted in 2024 by Chris McLaren ([@csmclaren](https://www.github.com/csmclaren)).

## License

Unless otherwise noted, all files in this project are licensed under the [GNU](https://www.gnu.org) General Public License v3.0. See the [COPYING](COPYING) file for details.

## Colophon

The logo for Loco is a representation of a [tram](https://en.wikipedia.org/wiki/Tram) car from the [Unicode](https://home.unicode.org) chart [Transport and Map Symbols](https://unicode.org/charts/PDF/U1F680.pdf). Loco was created in Lisbon, Portugal, a city with a [history](https://en.wikipedia.org/wiki/Trams_in_Lisbon) of using tram cars such as these.
