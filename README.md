# Custom Bash Scripts for LastPass CLI

Password manager [LastPass](https://www.lastpass.com/) has [official cli tool](https://support.logmeininc.com/lastpass/help/use-the-lastpass-command-line-application-lp040011). Unfortunately, the [repository](https://github.com/lastpass/lastpass-cli) itself does not make it clear as mentioned [here](https://github.com/lastpass/lastpass-cli/issues/14). Initially, I stumbled across GitHub repository and couldn't figure out if it is official tool or 3rd party. 

These scripts have been written and verified on OSX `10.13.6`, Bash version `5.0.16` and lpass tool version `v1.3.3.GIT`. Initially, I installed the tool using [Homebrew](https://brew.sh/) but ran into unexpected issues, so installing from source has fixed my issues ([explained here](https://github.com/lastpass/lastpass-cli/issues/427#issuecomment-427329292)). Before installing, make sure you have all the necessary dependencies as described [here](https://github.com/lastpass/lastpass-cli#dependencies). Manpage for lpass is available [here](https://lastpass.github.io/lastpass-cli/lpass.1.html).

## lpass-show.sh

Unfortunately, out-of-the-box, lpass does not provide remember the password feature ([discussed here](https://github.com/lastpass/lastpass-cli/issues/270)). If you need to do fully automated tasks or if you have many entries which require master password re-entry, this can be problematic. This script provides a proof-of-concept how to temporarily save master password to avoid manual re-entry of it. For technical details, please analyze source code. While I have taken as many security considerations are possible, I am not by any means a security expert, so any critique/GitHub issue/PR is welcome.

Important points:

- master password is saved into *temporary* variable which is *not* shown to the user (similar to typing sudo password)
- temporary variable is supplied to lpass via here-string, *not* `echo` ([reference](https://unix.stackexchange.com/questions/439497/is-there-a-way-to-pass-sensitive-data-in-bash-using-a-prompt-for-any-command))
- trap 0 is used to cleanup variables for *all* exits, signalled or not ([source](https://stackoverflow.com/questions/8122779/is-it-necessary-to-specify-traps-other-than-exit))
  - **!Very Important!** this applies *only* to Bash and certain implementations of ksh ([source](https://mywiki.wooledge.org/SignalTrap))

```
./lpass-show.sh <name or id>

<name or id>    name or id of the entry to be shown
                if name contains spaces use quotes, e.g. 'name with spaces'    
```

**Warning: this script is interactive and cannot be used in automatic manner as it asks for username and password via `read -r`**

## lpass-atts.sh

This script is based on [this](https://github.com/lastpass/lastpass-cli/blob/master/contrib/lpass-att-export.sh) script. Unfortunately, it didn't work for me out-of-the-box (see introduction for my system versions). The part which was failing for me was the sed regex. Also, I have incorporated previous script (`lpass-show.sh`) to fully automate export of attachments from entries which require master password re-entry.

```
./lpass-atts.sh [-o outdir] [-i <id>]

[-o outdir]    output directory where attachments will be saved
               directory does not have to exist as it is created with `mkdir -p`
               path can be either relative or absolute

[-i <id>]      retrieve attachment(s) from a specific entry by id
               argument supports only one id at a time
```
**Warning: this script is interactive and cannot be used in automatic manner as it asks for username and password via `read -r`**
