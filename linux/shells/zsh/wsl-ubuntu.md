# Setting up ZSH on WSL Version of Ubuntu

## Steps

1. Install `zsh`:

    ```
    sudo apt-get install zsh
    ```

1. Install `oh-my-zsh`:

    ```
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    ```
    
1. Add in the patched version of `agnoster-js` from this repo, and update `.zshrc` with that theme

1. Update `Windows Terminal` to use `powerline` fonts and a color scheme that's more usable.

    - Powerline fonts can also be installed:

        ```
        git clone https://github.com/powerline/fonts.git
        .\install.ps1
        ```

## Credit

Steps based on:

https://blog.joaograssi.com/windows-subsystem-for-linux-with-oh-my-zsh-conemu/
