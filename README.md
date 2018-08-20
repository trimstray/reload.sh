# `reload.sh`

Silly but interesting way to reinstall your system without using a cd-rom, flash memory and anything you could think about this process.

<p align="center">
    <img src="https://i.imgur.com/FCQl7pQ.gif"
         alt="Master">
</p>

## How it works?

Set your archive with system backup to restore:

```bash
_build="/mnt/system-backup.tgz"
```

Set path to temporary system (optional):

```bash
_base="/mnt/minimal-base"
```

  > If you do not specify this parameter, the temporary system will be downloaded automatically.

Init `reload.sh`:

```bash
./bin/reload.sh --base "$_base" --build "$_build"
```

## Contributions

Suggestions and pull requests are welcome. See also **[this](CONTRIBUTING.md)**.

## See also

* [`takeover.sh`](https://github.com/marcan/takeover.sh)

## Credits

| [![twitter/trimstray](https://avatars2.githubusercontent.com/u/31127917?s=140&v=4)](https://twitter.com/trimstray "Follow @trimstray on Twitter") |
|---|
| <p align="center"><a href="https://github.com/trimstray">trimstray</a></p> |

## License

GPLv3 : <http://www.gnu.org/licenses/>
