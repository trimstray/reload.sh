# `reload.sh`

<br>

<img src="https://i.imgur.com/QETbVXy.gif" align="center"
     title="reload.sh preview">

## Don't do it...

Please don't do it on live systems (e.g. production) or on your private computer where you stored critical data.

This recipe show you how to install fresh system where other system exist and running. It's really cool and amazing but very risky!

If you want to go into chaos of monkey read on.

## Why I created it?

I like experiments because I love to know how things work. GNU/Linux allow me to understand and show me some of the more tricky concepts. That's all.

## How it works?

Set your archive with system backup to restore:

```bash
_build="/mnt/system-backup.tgz"
```

Set path to temporary system (optional):

```bash
_base="/mnt/minimal-base"
```

  > If you do not set this parameter, the temporary system will be downloaded automatically.

Set path to main system disk:

```bash
_disk="/dev/vda"
```

Run `reload.sh`:

```bash
./bin/reload.sh --base "$_base" --build "$_build" --disk "$_disk"
```

## Contributing

Before adding a pull request, please see the **[contributing guidelines](CONTRIBUTING.md)**. All **suggestions/PR** are welcome!

## See also

* [`takeover.sh`](https://github.com/marcan/takeover.sh)

## Credits

| [![twitter/trimstray](https://avatars2.githubusercontent.com/u/31127917?s=140&v=4)](https://twitter.com/trimstray "Follow @trimstray on Twitter") |
|---|
| <p align="center"><a href="https://github.com/trimstray">trimstray</a></p> |

## License

GPLv3 : <http://www.gnu.org/licenses/>
