# 🍋 LemonSH

LemonSH is a lightweight shell written in **Dart** with built-in commands, a minimal text editor, and a custom package manager (**lemon**). It aims to be hackable, fun, and cross-platform.

---

## ✨ Features

- Built-in commands:
  - `ls`, `cd`, `pwd`, `cat`, `touch`, `rm`, `mkdir`, `rmdir`, `cp`, `mv`
  - `echo`, `date`, `whoami`, `head`, `tail`, `wc`, `find`, `chmod`, `clear`
- Simple text editor (`edit <file>` with `:wq` to save and quit, `:q!` to quit without saving)
- Package manager (`lemon install <pkg>`)
- Local `.bin` folder for installed binaries
- Easy to extend with more commands

---

## 🚀 Getting Started

### Clone the repo
```bash
git clone --depth 1 https://github.com/your-username/lemonsh.git
cd lemonsh
dart pub get
dart compile exe main.dart -o lemonsh
./lemonsh
```
### Contribution program:
Contributing Prebuilt Binaries

 - LemonSH is designed to run on multiple architectures.
You can help by contributing prebuilt binaries for your system!

Steps to contribute

- 1. Fork this repo


- 2. Clone your fork


- 3. Build LemonSH for your architecture:

``bash dart compile exe main.dart -o lemonsh-<your-arch>```


 - 4. Upload your binary in your fork inside a bin/ folder
Example: ```bash bin/linux-x86_64/lemonsh```


 - 5. Open a Pull Request to submit your binary



- This way, others can simply download and use prebuilt binaries for their system 🚀
